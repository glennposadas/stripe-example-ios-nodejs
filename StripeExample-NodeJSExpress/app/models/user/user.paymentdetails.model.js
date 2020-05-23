const bcrypt = require('bcryptjs')

'use strict';
module.exports = (sequelize, DataTypes) => {
  const UserPaymentDetails = sequelize.define('UserPaymentDetails', {
    id: { type: DataTypes.BIGINT, allowNull: false, autoIncrement: true, unique: true, primaryKey: true },
    stripeId: DataTypes.STRING
  }, {
    
  });

  // Association
  UserPaymentDetails.associate = function (models) {
    UserPaymentDetails.belongsTo(models.User, {
      foreignKey: "userId", 
      targetKey: "id"
    })
  }
  return UserPaymentDetails
}