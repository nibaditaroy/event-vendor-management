const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');
const authMiddleware = require('../middlewares/authMiddleware');

router.post('/', authMiddleware, bookingController.createBooking);
router.get('/', authMiddleware, bookingController.getBookings);
router.put('/:id/status', authMiddleware, bookingController.updateBookingStatus);
router.put('/:id/payment', authMiddleware, bookingController.updatePaymentStatus);

module.exports = router;
