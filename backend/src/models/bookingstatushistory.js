'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class BookingStatusHistory extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  }
  BookingStatusHistory.init({
    booking_id: DataTypes.INTEGER,
    status: DataTypes.STRING,
    changed_by: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'BookingStatusHistory',
  });
  return BookingStatusHistory;
};