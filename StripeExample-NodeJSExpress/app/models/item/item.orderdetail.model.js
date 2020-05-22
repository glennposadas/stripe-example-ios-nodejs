const bcrypt = require('bcryptjs')

'use strict';
module.exports = (sequelize, DataTypes) => {
  const ItemOrderDetail = sequelize.define('ItemOrderDetail', {
    id: { type: DataTypes.INTEGER, allowNull: false, autoIncrement: true, unique: true, primaryKey: true }
  }, {
    
  });
  // Association
  ItemOrderDetail.associate = function (models) {
    ItemOrderDetail.belongsTo(models.OrderDetail, { as: "orderDetail" })
    ItemOrderDetail.belongsTo(models.Item, { as: "item" })
  }
  return ItemOrderDetail
}