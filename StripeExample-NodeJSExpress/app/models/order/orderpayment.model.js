'use strict';
module.exports = (sequelize, DataTypes) => {
  const OrderPayment = sequelize.define('OrderPayment', {
    id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      autoIncrement: true,
      field: "id"
    },
    type: DataTypes.STRING,
    paymentNote: DataTypes.STRING
  }, {
  
  });
  OrderPayment.associate = function (models) {
    OrderPayment.belongsTo(models.Order, { as: "order" })
  }
  return OrderPayment;
};