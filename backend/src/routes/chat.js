const router = require('express').Router();
const ctrl = require('../controllers/chatController');
const { verifyToken } = require('../middleware/auth');
const upload = require('../middleware/upload');

router.get('/:solicitud_id', verifyToken, ctrl.getMensajes);
router.post('/:solicitud_id', verifyToken, upload.single('imagen'), ctrl.enviarMensaje);

module.exports = router;
