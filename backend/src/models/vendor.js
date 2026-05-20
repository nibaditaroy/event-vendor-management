'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Vendor extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
      Vendor.belongsTo(models.User, { foreignKey: 'user_id', as: 'user' });
      Vendor.belongsTo(models.Category, { foreignKey: 'category_id', as: 'category' });
      Vendor.hasMany(models.Service, { foreignKey: 'vendor_id', as: 'services' });
      Vendor.hasMany(models.Booking, { foreignKey: 'vendor_id', as: 'bookings' });
      Vendor.hasMany(models.Review, { foreignKey: 'vendor_id', as: 'reviews' });
    }
  }
  Vendor.init({
    user_id: DataTypes.INTEGER,
    business_name: DataTypes.STRING,
    category_id: DataTypes.INTEGER,
    description: DataTypes.TEXT,
    address: DataTypes.STRING,
    rating: DataTypes.FLOAT,
    verified: DataTypes.BOOLEAN
  }, {
    sequelize,
    modelName: 'Vendor',
  });
  return Vendor;
};