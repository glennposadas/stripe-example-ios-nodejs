// config.js
const dotenv = require("dotenv")
dotenv.config()

module.exports = {
  accessLevels: {
    user: 1,
    admin: 2
  },
  JWT_SECRET: "stripeexample",
  port: process.env.PORT,
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000
  },
  "development": {
    "username": process.env.DEV_DB_USERNAME,
    "password": process.env.DEV_DB_PASSWORD,
    "database": process.env.DEV_DB_DATABASE,
    "host": process.env.DEV_DB_HOST,
    "dialect": process.env.DEV_DB_DIALECT,
    "operatorsAliases": 0
  },
  "test": {
    "username": process.env.DEV_DB_USERNAME,
    "password": process.env.DEV_DB_PASSWORD,
    "database": process.env.DEV_DB_DATABASE,
    "host": process.env.DEV_DB_HOST,
    "dialect": process.env.DEV_DB_DIALECT,
    "operatorsAliases": 0
  },
  "production": {
    "username": process.env.DEV_DB_USERNAME,
    "password": process.env.DEV_DB_PASSWORD,
    "database": process.env.DEV_DB_DATABASE,
    "host": process.env.DEV_DB_HOST,
    "dialect": process.env.DEV_DB_DIALECT,
    "operatorsAliases": 0
  }
}