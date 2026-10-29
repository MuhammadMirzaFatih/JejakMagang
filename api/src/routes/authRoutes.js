const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { verifyToken } = require('../middlewares/auth');

// Endpoint publik
router.post('/register', authController.register);
router.post('/login', authController.login);

// Endpoint privat (memerlukan token)
router.get('/me', verifyToken, authController.getMe);

module.exports = router;

