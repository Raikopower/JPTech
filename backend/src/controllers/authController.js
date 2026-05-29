const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

const generarFolio = () => 'JP-' + Math.floor(1000 + Math.random() * 9000);
const generarCodigo = () => Math.floor(100000 + Math.random() * 900000).toString();

const generarToken = (user) => jwt.sign(
  { id: user.id, correo: user.correo, rol: user.rol },
  process.env.JWT_SECRET,
  { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
);

// POST /auth/login
exports.login = async (req, res) => {
  try {
    const { correo, password, rol } = req.body;
    if (!correo || !password || !rol)
      return res.status(400).json({ error: 'Campos requeridos: correo, password, rol' });

    const [rows] = await db.query('SELECT * FROM users WHERE correo = ? AND rol = ? AND activo = 1', [correo, rol]);
    if (!rows.length)
      return res.status(401).json({ error: 'Credenciales inválidas' });

    const user = rows[0];
    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) return res.status(401).json({ error: 'Credenciales inválidas' });

    if (!user.verificado) return res.status(403).json({ error: 'Cuenta no verificada', need_verify: true });

    let perfil = null;
    if (rol === 'tecnico') {
      const [tp] = await db.query('SELECT * FROM tecnicos_perfil WHERE user_id = ?', [user.id]);
      perfil = tp[0] || null;
    }

    const token = generarToken(user);
    res.json({
      token,
      user: {
        id: user.id, nombre: user.nombre, correo: user.correo,
        telefono: user.telefono, rol: user.rol, avatar_url: user.avatar_url,
        verificado: user.verificado
      },
      perfil
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// POST /auth/register/cliente
exports.registerCliente = async (req, res) => {
  try {
    const { nombre, correo, telefono, password } = req.body;
    if (!nombre || !correo || !password)
      return res.status(400).json({ error: 'Nombre, correo y contraseña son requeridos' });

    const [exist] = await db.query('SELECT id FROM users WHERE correo = ?', [correo]);
    if (exist.length) return res.status(409).json({ error: 'El correo ya está registrado' });

    const hash = await bcrypt.hash(password, 10);
    const codigo = generarCodigo();
    const expira = new Date(Date.now() + 15 * 60 * 1000);

    const [result] = await db.query(
      'INSERT INTO users (nombre, correo, telefono, password_hash, rol, codigo_verificacion, codigo_expira) VALUES (?,?,?,?,?,?,?)',
      [nombre, correo, telefono || null, hash, 'cliente', codigo, expira]
    );

    console.log(`📧 Código verificación para ${correo}: ${codigo}`);
    res.status(201).json({ message: 'Registro exitoso. Revisa tu correo.', user_id: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// POST /auth/register/tecnico
exports.registerTecnico = async (req, res) => {
  try {
    const { nombre, correo, especialidad, anios_experiencia, password } = req.body;
    if (!nombre || !correo || !password || !especialidad)
      return res.status(400).json({ error: 'Campos requeridos faltantes' });

    const [exist] = await db.query('SELECT id FROM users WHERE correo = ?', [correo]);
    if (exist.length) return res.status(409).json({ error: 'El correo ya está registrado' });

    const hash = await bcrypt.hash(password, 10);
    const codigo = generarCodigo();
    const expira = new Date(Date.now() + 15 * 60 * 1000);
    const certUrl = req.file ? `/uploads/${req.file.filename}` : null;

    const conn = await db.getConnection();
    try {
      await conn.beginTransaction();
      const [result] = await conn.query(
        'INSERT INTO users (nombre, correo, password_hash, rol, codigo_verificacion, codigo_expira) VALUES (?,?,?,?,?,?)',
        [nombre, correo, hash, 'tecnico', codigo, expira]
      );
      await conn.query(
        'INSERT INTO tecnicos_perfil (user_id, especialidad, anios_experiencia, certificacion_url) VALUES (?,?,?,?)',
        [result.insertId, especialidad, anios_experiencia || 0, certUrl]
      );
      await conn.commit();
      console.log(`📧 Código verificación para ${correo}: ${codigo}`);
      res.status(201).json({ message: 'Registro exitoso. Revisa tu correo.', user_id: result.insertId });
    } catch (e) {
      await conn.rollback();
      throw e;
    } finally {
      conn.release();
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// POST /auth/verify
exports.verifyCode = async (req, res) => {
  try {
    const { correo, codigo } = req.body;
    const [rows] = await db.query(
      'SELECT * FROM users WHERE correo = ? AND codigo_verificacion = ? AND codigo_expira > NOW()',
      [correo, codigo]
    );
    if (!rows.length) return res.status(400).json({ error: 'Código inválido o expirado' });

    await db.query('UPDATE users SET verificado = 1, codigo_verificacion = NULL WHERE correo = ?', [correo]);
    const token = generarToken(rows[0]);
    res.json({ message: 'Cuenta verificada', token });
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// POST /auth/forgot-password
exports.forgotPassword = async (req, res) => {
  try {
    const { correo } = req.body;
    const [rows] = await db.query('SELECT id FROM users WHERE correo = ?', [correo]);
    if (!rows.length) return res.status(404).json({ error: 'Correo no encontrado' });

    const codigo = generarCodigo();
    const expira = new Date(Date.now() + 15 * 60 * 1000);
    await db.query('UPDATE users SET codigo_verificacion = ?, codigo_expira = ? WHERE correo = ?', [codigo, expira, correo]);
    console.log(`📧 Código recuperación para ${correo}: ${codigo}`);
    res.json({ message: 'Código enviado al correo' });
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// POST /auth/reset-password
exports.resetPassword = async (req, res) => {
  try {
    const { correo, codigo, nueva_password } = req.body;
    const [rows] = await db.query(
      'SELECT * FROM users WHERE correo = ? AND codigo_verificacion = ? AND codigo_expira > NOW()',
      [correo, codigo]
    );
    if (!rows.length) return res.status(400).json({ error: 'Código inválido o expirado' });

    const hash = await bcrypt.hash(nueva_password, 10);
    await db.query('UPDATE users SET password_hash = ?, codigo_verificacion = NULL WHERE correo = ?', [hash, correo]);
    res.json({ message: 'Contraseña actualizada exitosamente' });
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// GET /auth/profile
exports.getProfile = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT id,nombre,correo,telefono,rol,avatar_url,verificado,created_at FROM users WHERE id = ?', [req.user.id]);
    if (!rows.length) return res.status(404).json({ error: 'Usuario no encontrado' });
    let data = { ...rows[0] };
    if (data.rol === 'tecnico') {
      const [tp] = await db.query('SELECT * FROM tecnicos_perfil WHERE user_id = ?', [data.id]);
      data.perfil_tecnico = tp[0] || null;
    }
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: 'Error del servidor' });
  }
};
