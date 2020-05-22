const bodyParser = require("body-parser")
const config = require("./app/config/config")
const cors = require("cors")
const express = require("express")
const helmet = require("helmet")
const morgan = require("morgan")
const passport = require("passport")

const app = express()

var corsOptions = {
  "origin": "*",
  "methods": "GET,HEAD,PUT,PATCH,POST,DELETE",
  "preflightContinue": false,
  "optionsSuccessStatus": 204
}

// Disable the powered by header result.
app.disable('x-powered-by');

// morgan
app.use(morgan("dev"))

// body parser - parse requests of content-type - application/json
app.use(bodyParser.json())

// parse requests of content-type - application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: true }))

// cors
app.use(cors(corsOptions))

// helmet
app.use(helmet())

// passport
app.use(passport.initialize())
app.use(passport.session())

// simple route
app.get("/", (req, res) => {
  res.send("Welcome to Stripe-iOS-Node-Example REST API!")
});

const db = require("./app/models")

db.sequelize.sync({ force: true }).then(() => {
  console.log("Drop and re-sync db.")
  useRoutes()
})

function useRoutes() {
  console.log("Use routes...")
  require("./app/routes/auth/auth.routes")(app)
  require("./app/routes/order/order.routes")(app)
  require("./app/routes/item/item.routes")(app)
}

// set port, listen for requests
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`)
})