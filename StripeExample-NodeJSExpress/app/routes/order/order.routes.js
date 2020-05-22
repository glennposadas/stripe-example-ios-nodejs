module.exports = app => {
  const controller = require("../../controllers/order/order.controller")

  const router = require("express").Router()

  const passport = require('passport');
  const passportJWT = passport.authenticate('jwt', { session: false });
  const config = require("../../config/config")

  // GET: my orders.
  router.get("/mine", passportJWT, controller.getMyOrders)

  app.use("/api/orders", router)
}
