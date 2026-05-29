const router = require('express').Router();
const ctrl = require('../controllers/authController');
const { verifyToken } = require('../middleware/auth');
const upload = require('../middleware/upload');

router.post('/login', ctrl.login);
router.post('/register/cliente', ctrl.registerCliente);
router.post('/register/tecnico', upload.single('certificacion'), ctrl.registerTecnico);
router.post('/verify', ctrl.verifyCode);
router.post('/forgot-password', ctrl.forgotPassword);
router.post('/reset-password', ctrl.resetPassword);
router.get('/profile', verifyToken, ctrl.getProfile);

module.exports = router;
