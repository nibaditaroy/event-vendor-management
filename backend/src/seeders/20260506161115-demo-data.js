'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    // Add Services for Artisan Catering (Vendor ID 1)
    await queryInterface.bulkInsert('Services', [
      {
        vendor_id: 1,
        title: 'Gourmet Wedding Banquet',
        description: '5-course formal dinner for high-end weddings.',
        price: 5000,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        vendor_id: 1,
        title: 'Executive Corporate Lunch',
        description: 'Bespoke buffet for corporate networking events.',
        price: 2500,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ], {});

    // Add Pending Bookings for Organizer (User ID 1) to Vendor (ID 1)
    await queryInterface.bulkInsert('Bookings', [
      {
        organizer_id: 1,
        vendor_id: 1,
        service_id: 1,
        event_date: '2026-08-20',
        event_location: 'Central Park Terrace, NY',
        guest_count: 150,
        status: 'pending',
        total_amount: 5000,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ], {});
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('Services', null, {});
    await queryInterface.bulkDelete('Bookings', null, {});
  }
};
