const express = require('express');
const router = express.Router();
const lamaranController = require('../controllers/lamaranController');
const wawancaraController = require('../controllers/wawancaraController');
const berkasController = require('../controllers/berkasController');
const { verifyToken } = require('../middlewares/auth');

// Semua rute lamaran membutuhkan otentikasi JWT
router.use(verifyToken);

// --- Rute Pokok Lamaran ---
router.get('/', lamaranController.getAllLamaran);
router.post('/', lamaranController.createLamaran);
router.get('/:id', lamaranController.getLamaranById);
router.put('/:id', lamaranController.updateLamaran);
router.delete('/:id', lamaranController.deleteLamaran);

// --- Rute Khusus Status & Tahap ---
router.patch('/:id/tahap', lamaranController.updateTahap);
router.patch('/:id/prioritas', lamaranController.togglePrioritas);
router.patch('/:id/catatan-hasil', lamaranController.updateCatatanHasil);

// --- Rute Catatan Persiapan Wawancara ---
router.get('/:id/wawancara', wawancaraController.getCatatanWawancara);
router.post('/:id/wawancara', wawancaraController.createCatatanWawancara);
router.put('/:id/wawancara/:noteId', wawancaraController.updateCatatanWawancara);
router.delete('/:id/wawancara/:noteId', wawancaraController.deleteCatatanWawancara);

// --- Rute Berkas Persyaratan ---
router.get('/:id/berkas', berkasController.getBerkas);
router.patch('/:id/berkas/:berkasId', berkasController.toggleBerkasStatus);

module.exports = router;

