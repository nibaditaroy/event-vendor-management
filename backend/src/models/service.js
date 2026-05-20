'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Service extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
      Service.belongsTo(models.Vendor, { foreignKey: 'vendor_id', as: 'vendor' });
      Service.hasMany(models.Booking, { foreignKey: 'service_id', as: 'bookings' });
    }
  }
  Service.init({
    vendor_id: DataTypes.INTEGER,
    title: DataTypes.STRING,
    description: DataTypes.TEXT,
    price: DataTypes.DECIMAL,
    thumbnail: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'Service',
  });
  return Service;
};