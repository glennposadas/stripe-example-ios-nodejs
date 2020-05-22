/**
 * APP ---> ROUTER
 * ROUTER ---> CONTROLLER
 * 
 * Params = url path -> url.com/api/user/param
 * Query = url query -> url.com/api/user/search?q="someq"
 * Body = data from the body.
 * 
 */

const db = require("../../models")
const op = db.Sequelize.Op

const passport = require('passport');
const JwtStrategy = require('passport-jwt').Strategy
const ExtractJwt = require('passport-jwt').ExtractJwt

const config = require("../../config/config")

// Get the profile of the current user through JWT.
exports.getMyOrders = (req, res) => {
  db.Order.findAll({
    where: { userId: req.user.id },
    include: [
      {
        model: db.OrderDetail,
        as: "orderDetails"
      },
      {
        model: db.OrderPayment,
        as: "paymentDetails"
      }
    ],
    attributes: defaultAttributes
  })
    .then(data => {
      res.send(data)
    })
    .catch(err => {
      console.log(err)
      res.status(500).send({
        message: "An error has occured while retrieving data."
      })
    })
}