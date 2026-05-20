const express = require('express');
const router = express.Router();
const vendorController = require('../controllers/vendorController');
const authMiddleware = require('../middlewares/authMiddleware');

router.get('/', vendorController.getVendors);
router.get('/profile', authMiddleware, vendorController.getVendorProfile);
router.get('/:id', vendorController.getVendorById);
router.post('/profile', authMiddleware, vendorController.createVendorProfile);
router.put('/profile', authMiddleware, vendorController.updateVendorProfile);

module.exports = router;
