'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Notification extends Model {
    static associate(models) {
      Notification.belongsTo(models.User, { foreignKey: 'user_id' });
    }
  }
  Notification.init({
    user_id: DataTypes.INTEGER,
    title: DataTypes.STRING,
    message: DataTypes.TEXT,
    type: DataTypes.STRING, // 'success', 'message', 'payment', 'reminder'
    is_read: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    }
  }, {
    sequelize,
    modelName: 'Notification',
  });
  return Notification;
};