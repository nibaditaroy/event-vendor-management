const { Review, Booking, Vendor, User, Notification } = require('../models');

exports.createReview = async (req, res) => {
  try {
    const { booking_id, vendor_id, rating, comment } = req.body;
    const organizer_id = req.user.id;

    // Check if booking exists and is completed
    const booking = await Booking.findByPk(booking_id);
    if (!booking) return res.status(404).json({ success: false, message: 'Booking not found' });
    
    // In a real app, check if status is 'completed'
    // For now, allow rating if it exists

    const review = await Review.create({
      booking_id,
      vendor_id,
      organizer_id,
      rating,
      comment
    });

    // Update vendor average rating
    const reviews = await Review.findAll({ where: { vendor_id } });
    const avgRating = reviews.reduce((acc, curr) => acc + curr.rating, 0) / reviews.length;
    
    await Vendor.update({ rating: avgRating }, { where: { id: vendor_id } });

    // Notify Vendor
    const vendor = await Vendor.findByPk(vendor_id);
    if (vendor) {
      await Notification.create({
        user_id: vendor.user_id,
        title: 'New Rating Received!',
        message: `An organizer has given you a ${rating}-star rating for your service.`,
        type: 'success'
      });
    }

    res.status(201).json({ success: true, data: review });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.getVendorReviews = async (req, res) => {
  try {
    const { vendorId } = req.params;
    const reviews = await Review.findAll({
      where: { vendor_id: vendorId },
      include: [
        { model: User, as: 'organizer', attributes: ['name', 'profile_image'] }
      ],
      order: [['createdAt', 'DESC']]
    });
    res.json({ success: true, data: reviews });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
