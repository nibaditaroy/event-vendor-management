'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.bulkInsert('Categories', [
      { name: 'Catering', icon: 'restaurant', createdAt: new Date(), updatedAt: new Date() },
      { name: 'Photography', icon: 'camera_alt', createdAt: new Date(), updatedAt: new Date() },
      { name: 'Venue', icon: 'location_on', createdAt: new Date(), updatedAt: new Date() },
      { name: 'Decoration', icon: 'celebration', createdAt: new Date(), updatedAt: new Date() },
      { name: 'Music', icon: 'music_note', createdAt: new Date(), updatedAt: new Date() },
      { name: 'Lighting', icon: 'lightbulb', createdAt: new Date(), updatedAt: new Date() },
      { name: 'Florist', icon: 'local_florist', createdAt: new Date(), updatedAt: new Date() },
      { name: 'Transportation', icon: 'directions_car', createdAt: new Date(), updatedAt: new Date() },
      { name: 'Invitations', icon: 'mail', createdAt: new Date(), updatedAt: new Date() },
      { name: 'Makeup Artist', icon: 'face', createdAt: new Date(), updatedAt: new Date() }
    ], {});
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete('Categories', null, {});
  }
};
