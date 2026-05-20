'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('Bookings', 'payment_status', {
      type: Sequelize.STRING,
      defaultValue: 'unpaid', // 'unpaid', 'paid'
      allowNull: false
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.removeColumn('Bookings', 'payment_status');
  }
};
