const db = require('../config/database');

// GET /chat/:solicitud_id
exports.getMensajes = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT m.*, u.nombre as emisor_nombre, u.avatar_url as emisor_avatar, u.rol as emisor_rol
       FROM mensajes m
       JOIN users u ON m.emisor_id = u.id
       WHERE m.solicitud_id = ?
       ORDER BY m.created_at ASC`,
      [req.params.solicitud_id]
    );
    // Marcar como leídos
    await db.query(
      'UPDATE mensajes SET leido=1 WHERE solicitud_id=? AND receptor_id=? AND leido=0',
      [req.params.solicitud_id, req.user.id]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// POST /chat/:solicitud_id
exports.enviarMensaje = async (req, res) => {
  try {
    const { contenido, tipo, receptor_id, latitud, longitud } = req.body;
    const imagenUrl = req.file ? `/uploads/${req.file.filename}` : null;

    const [result] = await db.query(
      'INSERT INTO mensajes (solicitud_id,emisor_id,receptor_id,contenido,tipo,imagen_url,latitud,longitud) VALUES (?,?,?,?,?,?,?,?)',
      [req.params.solicitud_id, req.user.id, receptor_id, contenido || null,
       tipo || 'texto', imagenUrl, latitud || null, longitud || null]
    );

    const [msg] = await db.query(
      `SELECT m.*, u.nombre as emisor_nombre, u.avatar_url as emisor_avatar
       FROM mensajes m JOIN users u ON m.emisor_id = u.id WHERE m.id = ?`,
      [result.insertId]
    );

    const io = req.app.get('io');
    io.to(`solicitud_${req.params.solicitud_id}`).emit('nuevo_mensaje', msg[0]);

    res.status(201).json(msg[0]);
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};
