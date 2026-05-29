const router = require('express').Router();
const ctrl = require('../controllers/technicianController');
const { verifyToken, requireRole } = require('../middleware/auth');

router.get('/nearby', verifyToken, ctrl.getNearby);
router.post('/offer', verifyToken, requireRole('tecnico'), ctrl.enviarOferta);
router.get('/offers/:solicitud_id', verifyToken, ctrl.getOfertas);
router.post('/accept-offer/:oferta_id', verifyToken, requireRole('cliente'), ctrl.aceptarOferta);
router.put('/location', verifyToken, requireRole('tecnico'), ctrl.updateLocation);
router.put('/availability', verifyToken, requireRole('tecnico'), ctrl.updateAvailability);
router.get('/marketplace', verifyToken, requireRole('tecnico'), ctrl.getMarketplace);

module.exports = router;
