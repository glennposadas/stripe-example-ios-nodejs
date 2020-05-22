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
const myUtil = require("../../utilities")

const passport = require('passport');
const JwtStrategy = require('passport-jwt').Strategy
const ExtractJwt = require('passport-jwt').ExtractJwt

const config = require("../../config/config")

const defaultAttributes = ["id", "fbid", "email", "firstName", "lastName", "photoUrl", "createdAt", "updatedAt"]

// Get the profile of the current user through JWT.
exports.getme = (req, res) => {
  db.User.findOne({
    where: { id: req.user.id },
    include: [
      {
        model: db.Role,
        as: "role"
      },
      {
        model: db.UserScore,
        as: "score"
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

// Retrieve all the data from the database.
exports.getAllUsers = (req, res) => {
  const page = myUtil.parser.tryParseInt(req.query.page, 0)
  const limit = myUtil.parser.tryParseInt(req.query.limit, 10)

  db.Question.findAndCountAll({
    where: {},
    offset: limit * page,
    limit: limit,
    order: [["id", "ASC"]],
  })
    .then(data => {
      res.json(myUtil.response.paging(data, page, limit))
    })
    .catch(err => {
      console.log("Error get questions: " + err.message)
      res.status(500).send({
        message: "An error has occured while retrieving data."
      })
    })
}

// Find an object with a user Id.
exports.findOne = (req, res) => {
  // The the id from the url path. (params)
  const id = req.params.id

  db.User.findByPk(id)
    .then(data => {
      res.send(data)
    })
    .catch(err => {
      res.status(500).send({
        message: err.message || "Error searching for data."
      })
    })
}

// Search for object, by specific params.
exports.search = (req, res) => {
  const q = req.query.q

  // Validate
  if (!q) {
    res.status(400).send({
      message: "Need a query."
    })
  }

  // Proceed with searching...
  const like1 = { firstName: { [op.like]: `%${q}%` } }
  const like2 = { lastName: { [op.like]: `%${q}%` } }
  const like3 = { email: { [op.like]: `%${q}%` } }

  // WHERE name LIKE q OR email LIKE q
  const condition = q ? { [op.or]: [like1, like2, like3] } : null

  db.User.findAll({ where: condition })
    .then(data => {
      res.send(data)
    })
    .catch(err => {
      res.status(500).send({
        message: err.message || "An error has occured while doing search."
      })
    })
}

// Update an object identified by id in the request.
exports.update = (req, res) => {
  // Validate the request body.
  if (!req.body) {
    res.status(400).send({
      message: "Content cannot be empty!"
    })
  }

  // Proceed with update...
  const id = req.params.id

  db.User.update(req.body, {
    where: { id: id }
  })
    .then(num => {
      if (num == 1) {
        res.send({
          message: "User record has been updated successfully!"
        })
      } else {
        res.send({
          message: "User " + id + " couldn't be updated."
        })
      }
    })
    .catch(err => {
      res.status(500).send({
        message: err.message || "Error updating object with id: " + id
      })
    })
}

// Delete an object with the specified id in the request
exports.delete = (req, res) => {
  const id = req.params.id

  Customer.destroy({ where: { id: id } })
    .then(num => {
      if (num == 1) {
        res.send({
          message: "A record has been DELETED successfully!"
        })
      } else {
        res.send({
          message: "Object id: " + id + " Couldn't be deleted."
        })
      }
    })
    .catch(err => {
      res.status(500).send({
        message: "Error DELETING boject with id " + id
      })
    })
}

// Delete all Customers from the database.
exports.deleteAll = (req, res) => {
  Customer.destroy({
    where: {},
    truncate: false
  })
    .then(num => {
      res.send({
        message: "ALL DELETED SUCCESSFULLY!"
      })
    })
    .catch(err => {
      res.status(500).send({
        message: "Error DELETING ALL RECORDS!"
      })
    })
}
