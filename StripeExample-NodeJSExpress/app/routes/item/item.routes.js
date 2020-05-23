module.exports = app => {
  const controller = require("../../controllers/item/item.controller")

  const router = require("express").Router()

  const passport = require('passport');
  const passportJWT = passport.authenticate('jwt', { session: false });
  const requireMinAccessLevel = require("../../middlewares/passport").requireMinAccessLevel
  const config = require("../../config/config")

  // GET: all items without pagination
  router.get("/", controller.getAllItems)

  app.use("/api/items", router)
}
