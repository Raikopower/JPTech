const router = require('express').Router();
const ctrl = require('../controllers/serviceController');
const { verifyToken, requireRole } = require('../middleware/auth');
const upload = require('../middleware/upload');

router.get('/categorias', ctrl.getCategorias);
router.post('/', verifyToken, requireRole('cliente'), upload.single('imagen'), ctrl.crearSolicitud);
router.get('/mis-solicitudes', verifyToken, ctrl.misSolicitudes);
router.get('/:id', verifyToken, ctrl.getSolicitud);
router.put('/:id/estado', verifyToken, ctrl.actualizarEstado);
router.post('/:id/finalizar', verifyToken, requireRole('tecnico'), upload.single('imagen_trabajo'), ctrl.finalizarServicio);

module.exports = router;
