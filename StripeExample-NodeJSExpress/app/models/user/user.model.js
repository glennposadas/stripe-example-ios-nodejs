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

  User.prototype.validatePassword = function (password) {
    return bcrypt.compare(password, this.password)
  }

  // Before create
  User.beforeCreate((user, options) => {
    return bcrypt.hash(user.password, 10)
      .then(hash => {
        user.password = hash;
      })
      .catch(err => {
        throw new Error();
      })
  })

  // Association
  User.associate = function (models) {
    User.hasMany(models.Order, {
      foreignKey: "userId",
      sourceKey: "id"
    })
  }
  return User
}