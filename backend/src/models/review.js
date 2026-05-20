'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Review extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      Review.belongsTo(models.Booking, { foreignKey: 'booking_id', as: 'booking' });
      Review.belongsTo(models.User, { foreignKey: 'organizer_id', as: 'organizer' });
      Review.belongsTo(models.Vendor, { foreignKey: 'vendor_id', as: 'vendor' });
    }
  }
  Review.init({
    booking_id: DataTypes.INTEGER,
    organizer_id: DataTypes.INTEGER,
    vendor_id: DataTypes.INTEGER,
    rating: DataTypes.FLOAT,
    comment: DataTypes.TEXT
  }, {
    sequelize,
    modelName: 'Review',
  });
  return Review;
};