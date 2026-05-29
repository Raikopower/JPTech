const jwt = require('jsonwebtoken');

module.exports = (io) => {
  io.use((socket, next) => {
    const token = socket.handshake.auth.token;
    if (!token) return next(new Error('Token requerido'));
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.user = decoded;
      next();
    } catch {
      next(new Error('Token inválido'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`🔌 Conectado: ${socket.user.id} (${socket.user.rol})`);
    socket.join(`user_${socket.user.id}`);
    if (socket.user.rol === 'tecnico') socket.join('tecnicos');

    socket.on('join_solicitud', (solicitud_id) => {
      socket.join(`solicitud_${solicitud_id}`);
    });

    socket.on('leave_solicitud', (solicitud_id) => {
      socket.leave(`solicitud_${solicitud_id}`);
    });

    socket.on('update_location', ({ solicitud_id, latitud, longitud }) => {
      if (solicitud_id) {
        io.to(`solicitud_${solicitud_id}`).emit('tecnico_ubicacion', {
          tecnico_id: socket.user.id, latitud, longitud, timestamp: new Date()
        });
      }
    });

    socket.on('en_camino', ({ solicitud_id }) => {
      io.to(`solicitud_${solicitud_id}`).emit('estado_actualizado', { solicitud_id, estado: 'en_camino' });
    });

    socket.on('llegue_destino', ({ solicitud_id }) => {
      io.to(`solicitud_${solicitud_id}`).emit('tecnico_llego', { solicitud_id });
    });

    socket.on('typing', ({ solicitud_id }) => {
      socket.to(`solicitud_${solicitud_id}`).emit('user_typing', { user_id: socket.user.id });
    });

    socket.on('stop_typing', ({ solicitud_id }) => {
      socket.to(`solicitud_${solicitud_id}`).emit('user_stop_typing', { user_id: socket.user.id });
    });

    socket.on('disconnect', () => {
      console.log(`🔌 Desconectado: ${socket.user.id}`);
    });
  });
};
