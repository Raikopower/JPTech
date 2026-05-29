const db = require('../config/database');

const generarFolio = () => 'JP-' + Math.floor(1000 + Math.random() * 9000);

// POST /services - Crear solicitud
exports.crearSolicitud = async (req, res) => {
  try {
    const { categoria_id, descripcion, urgencia, fecha_servicio, horario_inicio, horario_fin, direccion, latitud, longitud } = req.body;
    if (!categoria_id || !descripcion || !direccion)
      return res.status(400).json({ error: 'Campos requeridos faltantes' });

    const folio = generarFolio();
    const imagenUrl = req.file ? `/uploads/${req.file.filename}` : null;

    const [result] = await db.query(
      `INSERT INTO solicitudes (folio,cliente_id,categoria_id,descripcion,urgencia,estado,
       fecha_servicio,horario_inicio,horario_fin,direccion,latitud_cliente,longitud_cliente,imagen_problema_url)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [folio, req.user.id, categoria_id, descripcion, urgencia || 'media', 'buscando',
       fecha_servicio || null, horario_inicio || null, horario_fin || null,
       direccion, latitud || null, longitud || null, imagenUrl]
    );

    // Notificar a técnicos cercanos via socket (se maneja en el socket handler)
    const io = req.app.get('io');
    io.to('tecnicos').emit('nueva_solicitud', {
      solicitud_id: result.insertId,
      folio,
      categoria_id,
      urgencia: urgencia || 'media',
      direccion,
      latitud, longitud
    });

    res.status(201).json({ message: 'Solicitud creada', solicitud_id: result.insertId, folio });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// GET /services/mis-solicitudes
exports.misSolicitudes = async (req, res) => {
  try {
    const campo = req.user.rol === 'cliente' ? 'cliente_id' : 'tecnico_id';
    const [rows] = await db.query(
      `SELECT s.*, c.nombre as categoria_nombre, c.icono as categoria_icono,
       u.nombre as tecnico_nombre, u.avatar_url as tecnico_avatar,
       tp.calificacion_promedio as tecnico_calificacion
       FROM solicitudes s
       JOIN categorias c ON s.categoria_id = c.id
       LEFT JOIN users u ON s.tecnico_id = u.id
       LEFT JOIN tecnicos_perfil tp ON s.tecnico_id = tp.user_id
       WHERE s.${campo} = ?
       ORDER BY s.created_at DESC`,
      [req.user.id]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// GET /services/:id
exports.getSolicitud = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT s.*, c.nombre as categoria_nombre,
       uc.nombre as cliente_nombre, uc.telefono as cliente_telefono, uc.avatar_url as cliente_avatar,
       ut.nombre as tecnico_nombre, ut.telefono as tecnico_telefono, ut.avatar_url as tecnico_avatar,
       tp.calificacion_promedio, tp.especialidad, tp.latitud as tecnico_lat, tp.longitud as tecnico_lng
       FROM solicitudes s
       JOIN categorias c ON s.categoria_id = c.id
       JOIN users uc ON s.cliente_id = uc.id
       LEFT JOIN users ut ON s.tecnico_id = ut.id
       LEFT JOIN tecnicos_perfil tp ON s.tecnico_id = tp.user_id
       WHERE s.id = ?`,
      [req.params.id]
    );
    if (!rows.length) return res.status(404).json({ error: 'Solicitud no encontrada' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// PUT /services/:id/estado
exports.actualizarEstado = async (req, res) => {
  try {
    const { estado } = req.body;
    const estadosValidos = ['pendiente','buscando','ofertando','confirmado','en_camino','en_progreso','finalizado','cancelado'];
    if (!estadosValidos.includes(estado))
      return res.status(400).json({ error: 'Estado inválido' });

    await db.query('UPDATE solicitudes SET estado = ? WHERE id = ?', [estado, req.params.id]);

    const io = req.app.get('io');
    io.to(`solicitud_${req.params.id}`).emit('estado_actualizado', { solicitud_id: req.params.id, estado });

    res.json({ message: 'Estado actualizado', estado });
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// POST /services/:id/finalizar - Técnico finaliza el servicio
exports.finalizarServicio = async (req, res) => {
  try {
    const { resumen_trabajo, materiales_usados, precio_final } = req.body;
    const imagenUrl = req.file ? `/uploads/${req.file.filename}` : null;

    await db.query(
      `UPDATE solicitudes SET estado='finalizado', resumen_trabajo=?, materiales_usados=?,
       precio_final=?, imagen_trabajo_url=? WHERE id = ? AND tecnico_id = ?`,
      [resumen_trabajo, materiales_usados, precio_final, imagenUrl, req.params.id, req.user.id]
    );

    // Actualizar contador del técnico
    await db.query('UPDATE tecnicos_perfil SET total_servicios = total_servicios + 1 WHERE user_id = ?', [req.user.id]);

    const io = req.app.get('io');
    io.to(`solicitud_${req.params.id}`).emit('servicio_finalizado', { solicitud_id: req.params.id });

    res.json({ message: 'Servicio finalizado exitosamente' });
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// GET /services/categorias
exports.getCategorias = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM categorias WHERE activo = 1');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};
