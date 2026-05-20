const { Booking, Vendor, Service, User, BookingStatusHistory, Notification } = require('../models');

exports.createBooking = async (req, res) => {
  try {
    const { vendor_id, service_id, event_date, event_location, guest_count, special_note, total_amount } = req.body;

    const booking = await Booking.create({
      organizer_id: req.user.id,
      vendor_id,
      service_id,
      event_date,
      event_location,
      guest_count,
      special_note,
      total_amount,
      status: 'pending'
    });

    // Create history
    await BookingStatusHistory.create({
      booking_id: booking.id,
      status: 'pending',
      changed_by: req.user.id
    });

    // Notify Vendor
    const vendor = await Vendor.findByPk(vendor_id);
    if (vendor) {
      await Notification.create({
        user_id: vendor.user_id,
        title: 'New Booking Request',
        message: `You have a new booking request for ${event_date}.`,
        type: 'reminder'
      });
    }

    res.status(201).json({ success: true, data: booking });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.getBookings = async (req, res) => {
  try {
    const where = {};
    if (req.user.role === 'organizer') {
      where.organizer_id = req.user.id;
    } else if (req.user.role === 'vendor') {
      const vendor = await Vendor.findOne({ where: { user_id: req.user.id } });
      if (!vendor) return res.status(404).json({ success: false, message: 'Vendor profile not found' });
      where.vendor_id = vendor.id;
    }

    const bookings = await Booking.findAll({
      where,
      include: [
        { model: User, as: 'organizer', attributes: ['name', 'email', 'phone'] },
        { 
          model: Vendor, 
          as: 'vendor', 
          attributes: ['business_name'],
          include: [{ model: User, as: 'user', attributes: ['phone', 'profile_image'] }]
        },
        { model: Service, as: 'service', attributes: ['title', 'price', 'thumbnail'] },
        { model: require('../models').Review, as: 'review' }
      ],
      order: [['createdAt', 'DESC']]
    });
    res.json({ success: true, data: bookings });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.updateBookingStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const booking = await Booking.findByPk(req.params.id);
    if (!booking) return res.status(404).json({ success: false, message: 'Booking not found' });

    // Validate permission
    if (req.user.role === 'vendor') {
      const vendor = await Vendor.findOne({ where: { user_id: req.user.id } });
      if (booking.vendor_id !== vendor.id) return res.status(403).json({ success: false, message: 'Unauthorized' });
    } else if (req.user.role === 'organizer') {
      if (booking.organizer_id !== req.user.id) return res.status(403).json({ success: false, message: 'Unauthorized' });
    }

    await booking.update({ status });

    // Create history
    await BookingStatusHistory.create({
      booking_id: booking.id,
      status,
      changed_by: req.user.id
    });

    // Notify Organizer
    await Notification.create({
      user_id: booking.organizer_id,
      title: `Booking ${status.toUpperCase()}`,
      message: `Your booking status has been updated to ${status}.`,
      type: status === 'confirmed' ? 'success' : 'message'
    });

    res.json({ success: true, data: booking });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.updatePaymentStatus = async (req, res) => {
  try {
    const { payment_status } = req.body;
    const booking = await Booking.findByPk(req.params.id);
    if (!booking) return res.status(404).json({ success: false, message: 'Booking not found' });

    // Only vendor can mark as paid
    const vendor = await Vendor.findOne({ where: { user_id: req.user.id } });
    if (!vendor || booking.vendor_id !== vendor.id) {
      return res.status(403).json({ success: false, message: 'Unauthorized' });
    }

    await booking.update({ payment_status });

    // Notify Organizer
    await Notification.create({
      user_id: booking.organizer_id,
      title: 'Payment Received',
      message: `Vendor has marked your booking for ${booking.event_date} as paid.`,
      type: 'success'
    });

    res.json({ success: true, data: booking });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
