const express = require('express');
const router = express.Router();
const statistikController = require('../controllers/statistikController');
const { verifyToken } = require('../middlewares/auth');

// Endpoint ringkasan statistik (perlu otentikasi)
router.get('/', verifyToken, statistikController.getStatistik);

module.exports = router;

