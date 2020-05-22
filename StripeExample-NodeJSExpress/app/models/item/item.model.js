const bcrypt = require('bcryptjs')

'use strict';
module.exports = (sequelize, DataTypes) => {
  const Item = sequelize.define('Item', {
    id: { type: DataTypes.INTEGER, allowNull: false, autoIncrement: true, unique: true, primaryKey: true },
    title: DataTypes.STRING,
    description: DataTypes.STRING,
    price: DataTypes.FLOAT,
    photoURL: DataTypes.STRING
  }, {
    
  });
  // Association
  Item.associate = function (models) {
    Item.belongsTo(models.OrderDetail, { as: "orderDetail" })
  }
  return Item
}