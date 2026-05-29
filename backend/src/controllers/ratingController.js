const db = require('../config/database');

// POST /ratings
exports.crearResena = async (req, res) => {
  try {
    const { solicitud_id, calificacion, comentario, tags } = req.body;
    if (!solicitud_id || !calificacion)
      return res.status(400).json({ error: 'solicitud_id y calificacion requeridos' });

    const [sol] = await db.query('SELECT * FROM solicitudes WHERE id=? AND cliente_id=? AND estado="finalizado"', [solicitud_id, req.user.id]);
    if (!sol.length) return res.status(400).json({ error: 'No puedes calificar este servicio' });

    await db.query(
      'INSERT INTO resenas (solicitud_id,cliente_id,tecnico_id,calificacion,comentario,tags) VALUES (?,?,?,?,?,?)',
      [solicitud_id, req.user.id, sol[0].tecnico_id, calificacion, comentario || null, JSON.stringify(tags || [])]
    );

    // Actualizar calificación promedio del técnico
    const [avg] = await db.query(
      'SELECT AVG(calificacion) as avg, COUNT(*) as total FROM resenas WHERE tecnico_id=?',
      [sol[0].tecnico_id]
    );
    await db.query(
      'UPDATE tecnicos_perfil SET calificacion_promedio=?, total_resenas=? WHERE user_id=?',
      [avg[0].avg.toFixed(2), avg[0].total, sol[0].tecnico_id]
    );

    res.status(201).json({ message: 'Reseña enviada exitosamente' });
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// GET /ratings/tecnico/:id
exports.getResenasTecnico = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT r.*, u.nombre as cliente_nombre, u.avatar_url as cliente_avatar
       FROM resenas r JOIN users u ON r.cliente_id = u.id
       WHERE r.tecnico_id = ? ORDER BY r.created_at DESC LIMIT 20`,
      [req.params.id]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};
