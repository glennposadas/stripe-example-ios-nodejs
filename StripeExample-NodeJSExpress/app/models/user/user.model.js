const bcrypt = require('bcryptjs')

'use strict';
module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define('User', {
    id: { type: DataTypes.BIGINT, allowNull: false, autoIncrement: true, unique: true, primaryKey: true },
    email: DataTypes.STRING,
    password: DataTypes.STRING,
    name: DataTypes.STRING,
    address: DataTypes.STRING
  }, {
    
  });

  // Association
  User.associate = function (models) {
    User.hasMany(models.Order, {
      foreignKey: "userId",
      sourceKey: "id"
    })
  }
  return User
}