'use strict';
module.exports = (sequelize, DataTypes) => {
  const OrderDetail = sequelize.define('OrderDetail', {
    id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      autoIncrement: true,
      field: "id"
    },
    quantity: DataTypes.INTEGER
  }, {
  
  });
  OrderDetail.associate = function (models) {
    OrderDetail.belongsTo(models.Order, { as: "order" })
    OrderDetail.belongsTo(models.Item, { as: "item" })

    OrderDetail.hasMany(models.ItemOrderDetail, {
      foreignKey: "orderId", 
      targetKey: "id"
    })
  }
  return OrderDetail;
};