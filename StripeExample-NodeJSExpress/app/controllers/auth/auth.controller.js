const db = require("../../models")
const express = require("express")
const router = express.Router()
const util = require("util")

const config = require("../../config/config");
const jwt = require('jsonwebtoken');

signToken = user => {
  return jwt.sign({
    iss: 'stripeexample',
    sub: user.id,
    iat: new Date().getTime(), // current time
    exp: new Date().setDate(new Date().getDate() + 1) // current time + 1 day ahead
  }, config.JWT_SECRET);
}

module.exports = {
  // SIGN UP WITH EMAIL AND PASSWORD
  signup: async (req, res, next) => {
    const email = req.body.email
    const password = req.body.password
    const name = req.body.name
    const address = req.body.address

    if (!email || !password) {
      return res.status(403).send({
        message: "Error! Required parameters are: {email} and {password}."
      })
    }

    // Check if there is a user with the same email
    db.User.findOne({
      where: { email: email }
    })
      .then(data => {
        if (data) {
          return res.status(409).send({
            message: "Email is already in use."
          })
        }

        const newUser = {
          email: email,
          name: name,
          address: address,
          photoUrl: null,
          password: password
        }

        db.User.create(newUser)
        .then(data => {
          console.log("Created new user! ✅")
          // Generate the token
          const token = signToken(newUser)
          // Respond with token
          res.status(200).json({ token })
        })
        .catch(err => {
          console.log("Error creating a new user with email!!!." + err)
          return res.status(409).send({
            message: "An error has occured while creating a new user with email."
          })
        })
        
      })
      .catch(err => {
        console.log(err)
        res.status(500).send({
          message: "An error has occured while retrieving data."
        })
      })
  },

  // SIGN IN WITH EMAIL AND PASSWORD
  signin: async (req, res, next) => {
    // Generate token
    const token = signToken(req.user);
    res.status(200).json({ token });
  }
}