const router = require('express').Router();
const ctrl = require('../controllers/ratingController');
const { verifyToken, requireRole } = require('../middleware/auth');

router.post('/', verifyToken, requireRole('cliente'), ctrl.crearResena);
router.get('/tecnico/:id', verifyToken, ctrl.getResenasTecnico);

module.exports = router;
