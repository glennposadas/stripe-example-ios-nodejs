const passport = require("passport")
const passportConf = require("../../middlewares/passport")
const controller = require("../../controllers/auth/auth.controller")
const router = require("express").Router()

// Contains all the auth related enpoints
module.exports = app => {
  
  // POST signup with email and password
  router.post("/signup", controller.signup)

  // POST signin with email and password
  router.post("/signin",
    passport.authenticate('local', { session: false }),
    controller.signin
  )

  app.use("/api/oauth", router)
}