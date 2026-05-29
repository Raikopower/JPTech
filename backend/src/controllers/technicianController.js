const db = require('../config/database');

// GET /technicians/nearby?lat=&lng=&radius=10
exports.getNearby = async (req, res) => {
  try {
    const { lat, lng, radius = 15, categoria_id } = req.query;
    if (!lat || !lng) return res.status(400).json({ error: 'lat y lng requeridos' });

    let query = `
      SELECT u.id, u.nombre, u.avatar_url,
             tp.especialidad, tp.calificacion_promedio, tp.total_resenas, tp.precio_por_hora,
             tp.latitud, tp.longitud,
             (6371 * acos(cos(radians(?)) * cos(radians(tp.latitud)) *
              cos(radians(tp.longitud) - radians(?)) +
              sin(radians(?)) * sin(radians(tp.latitud)))) AS distancia_km
      FROM users u
      JOIN tecnicos_perfil tp ON u.id = tp.user_id
      WHERE u.activo = 1 AND tp.disponible = 1
        AND tp.latitud IS NOT NULL AND tp.longitud IS NOT NULL`;

    const params = [lat, lng, lat];

    if (categoria_id) {
      query += ' AND tp.especialidad IN (SELECT nombre FROM categorias WHERE id = ?)';
      params.push(categoria_id);
    }

    query += ' HAVING distancia_km <= ? ORDER BY distancia_km ASC LIMIT 20';
    params.push(parseFloat(radius));

    const [rows] = await db.query(query, params);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// POST /technicians/offer - Técnico envía oferta
exports.enviarOferta = async (req, res) => {
  try {
    const { solicitud_id, precio, mensaje } = req.body;
    if (!solicitud_id || !precio) return res.status(400).json({ error: 'solicitud_id y precio requeridos' });

    const [exist] = await db.query(
      'SELECT id FROM ofertas WHERE solicitud_id = ? AND tecnico_id = ?',
      [solicitud_id, req.user.id]
    );
    if (exist.length) return res.status(409).json({ error: 'Ya enviaste una oferta' });

    const [result] = await db.query(
      'INSERT INTO ofertas (solicitud_id, tecnico_id, precio, mensaje) VALUES (?,?,?,?)',
      [solicitud_id, req.user.id, precio, mensaje || null]
    );

    // Actualizar estado solicitud
    await db.query("UPDATE solicitudes SET estado='ofertando' WHERE id = ?", [solicitud_id]);

    // Notificar al cliente
    const [sol] = await db.query('SELECT cliente_id FROM solicitudes WHERE id = ?', [solicitud_id]);
    const io = req.app.get('io');
    if (sol.length) {
      io.to(`user_${sol[0].cliente_id}`).emit('nueva_oferta', {
        oferta_id: result.insertId,
        solicitud_id,
        tecnico_id: req.user.id,
        precio
      });
    }

    res.status(201).json({ message: 'Oferta enviada', oferta_id: result.insertId });
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// GET /technicians/offers/:solicitud_id - Obtener ofertas de una solicitud
exports.getOfertas = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT o.*, u.nombre, u.avatar_url, tp.especialidad, tp.calificacion_promedio, tp.total_resenas
       FROM ofertas o
       JOIN users u ON o.tecnico_id = u.id
       JOIN tecnicos_perfil tp ON o.tecnico_id = tp.user_id
       WHERE o.solicitud_id = ? AND o.estado = 'pendiente'
       ORDER BY o.precio ASC`,
      [req.params.solicitud_id]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// POST /technicians/accept-offer/:oferta_id
exports.aceptarOferta = async (req, res) => {
  try {
    const conn = await db.getConnection();
    try {
      await conn.beginTransaction();
      const [oferta] = await conn.query('SELECT * FROM ofertas WHERE id = ?', [req.params.oferta_id]);
      if (!oferta.length) { await conn.rollback(); return res.status(404).json({ error: 'Oferta no encontrada' }); }

      const o = oferta[0];
      await conn.query("UPDATE ofertas SET estado='aceptada' WHERE id = ?", [o.id]);
      await conn.query("UPDATE ofertas SET estado='rechazada' WHERE solicitud_id = ? AND id != ?", [o.solicitud_id, o.id]);
      await conn.query(
        "UPDATE solicitudes SET tecnico_id=?, estado='confirmado', precio_oferta=? WHERE id=?",
        [o.tecnico_id, o.precio, o.solicitud_id]
      );
      await conn.commit();

      const io = req.app.get('io');
      io.to(`user_${o.tecnico_id}`).emit('oferta_aceptada', { solicitud_id: o.solicitud_id });
      io.to(`solicitud_${o.solicitud_id}`).emit('estado_actualizado', { estado: 'confirmado' });

      res.json({ message: 'Técnico confirmado exitosamente' });
    } catch (e) {
      await conn.rollback();
      throw e;
    } finally {
      conn.release();
    }
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// PUT /technicians/location - Actualizar ubicación técnico
exports.updateLocation = async (req, res) => {
  try {
    const { latitud, longitud, solicitud_id } = req.body;
    if (!latitud || !longitud) return res.status(400).json({ error: 'latitud y longitud requeridos' });

    await db.query(
      'UPDATE tecnicos_perfil SET latitud=?, longitud=?, ultima_ubicacion=NOW() WHERE user_id=?',
      [latitud, longitud, req.user.id]
    );
    await db.query(
      'INSERT INTO ubicaciones_tecnico (tecnico_id, solicitud_id, latitud, longitud) VALUES (?,?,?,?)',
      [req.user.id, solicitud_id || null, latitud, longitud]
    );

    // Broadcast a la solicitud
    if (solicitud_id) {
      const io = req.app.get('io');
      io.to(`solicitud_${solicitud_id}`).emit('tecnico_ubicacion', {
        tecnico_id: req.user.id, latitud, longitud
      });
    }

    res.json({ message: 'Ubicación actualizada' });
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// PUT /technicians/availability
exports.updateAvailability = async (req, res) => {
  try {
    const { disponible } = req.body;
    await db.query('UPDATE tecnicos_perfil SET disponible=? WHERE user_id=?', [disponible, req.user.id]);
    res.json({ message: 'Disponibilidad actualizada', disponible });
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// GET /technicians/marketplace
exports.getMarketplace = async (req, res) => {
  try {
    const { categoria } = req.query;
    let query = `
      SELECT ml.*, s.folio, s.descripcion, s.urgencia, s.direccion,
             s.latitud_cliente, s.longitud_cliente, s.created_at as solicitud_fecha,
             c.nombre as categoria_nombre, c.icono,
             tp.latitud as tec_lat, tp.longitud as tec_lng,
             (6371 * acos(cos(radians(tp.latitud)) * cos(radians(s.latitud_cliente)) *
              cos(radians(s.longitud_cliente) - radians(tp.longitud)) +
              sin(radians(tp.latitud)) * sin(radians(s.latitud_cliente)))) AS distancia_km
      FROM marketplace_leads ml
      JOIN solicitudes s ON ml.solicitud_id = s.id
      JOIN categorias c ON s.categoria_id = c.id
      JOIN tecnicos_perfil tp ON tp.user_id = ?
      WHERE ml.activo = 1 AND ml.desbloqueado_por IS NULL AND s.estado = 'buscando'`;

    const params = [req.user.id];
    if (categoria && categoria !== 'Todos') {
      query += ' AND c.nombre = ?';
      params.push(categoria);
    }
    query += ' ORDER BY s.urgencia DESC, ml.created_at DESC LIMIT 30';

    const [rows] = await db.query(query, params);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};
