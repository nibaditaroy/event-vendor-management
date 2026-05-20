'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('Bookings', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      organizer_id: {
        type: Sequelize.INTEGER
      },
      vendor_id: {
        type: Sequelize.INTEGER
      },
      service_id: {
        type: Sequelize.INTEGER
      },
      event_date: {
        type: Sequelize.DATE
      },
      event_location: {
        type: Sequelize.STRING
      },
      guest_count: {
        type: Sequelize.INTEGER
      },
      special_note: {
        type: Sequelize.TEXT
      },
      status: {
        type: Sequelize.STRING
      },
      total_amount: {
        type: Sequelize.DECIMAL
      },
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE
      }
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('Bookings');
  }
};