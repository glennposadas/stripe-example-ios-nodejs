'use strict';
module.exports = (sequelize, DataTypes) => {
  const Order = sequelize.define('Order', {
    id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      autoIncrement: true,
      field: "id"
    },
    total: DataTypes.FLOAT,
    status: DataTypes.STRING,
    notes: DataTypes.STRING
  }, {
  
  });
  Order.associate = function (models) {
    Order.belongsTo(models.User, {
      foreignKey: "userId", 
      targetKey: "id"
    })

    Order.hasMany(models.OrderDetail, {
      foreignKey: "orderId",
      sourceKey: "id"
    })

    Order.hasMany(models.OrderPayment, {
      foreignKey: "orderId",
      sourceKey: "id"
    })
  }
  return Order;
};