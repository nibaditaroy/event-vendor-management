'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Booking extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
      Booking.belongsTo(models.User, { foreignKey: 'organizer_id', as: 'organizer' });
      Booking.belongsTo(models.Vendor, { foreignKey: 'vendor_id', as: 'vendor' });
      Booking.belongsTo(models.Service, { foreignKey: 'service_id', as: 'service' });
      Booking.hasOne(models.Review, { foreignKey: 'booking_id', as: 'review' });
      Booking.hasMany(models.BookingStatusHistory, { foreignKey: 'booking_id', as: 'status_history' });
    }
  }
  Booking.init({
    organizer_id: DataTypes.INTEGER,
    vendor_id: DataTypes.INTEGER,
    service_id: DataTypes.INTEGER,
    event_date: DataTypes.DATE,
    event_location: DataTypes.STRING,
    guest_count: DataTypes.INTEGER,
    special_note: DataTypes.TEXT,
    status: DataTypes.STRING,
    total_amount: DataTypes.DECIMAL,
    payment_status: {
      type: DataTypes.STRING,
      defaultValue: 'unpaid'
    }
  }, {
    sequelize,
    modelName: 'Booking',
  });
  return Booking;
};