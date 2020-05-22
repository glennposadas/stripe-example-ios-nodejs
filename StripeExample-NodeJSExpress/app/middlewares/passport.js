const passport = require('passport');
const JwtStrategy = require('passport-jwt').Strategy;
const LocalStrategy = require('passport-local').Strategy
const ExtractJwt = require('passport-jwt').ExtractJwt;
const util = require('util')

const config = require("../config/config");

const defaultAttributes = ["id", "email", "name", "address", "createdAt", "updatedAt"]

const db = require("../models")

// JSON WEB TOKENS STRATEGY
passport.use(new JwtStrategy({
  jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
  secretOrKey: config.JWT_SECRET
}, async (payload, done) => {
  db.User.findByPk(payload.sub, {
    /*
    include: [
      {
        model: db.Role,
        as: "role"
      },
      {
        model: db.UserScore,
        as: "score"
      }
    ],*/
    attributes: defaultAttributes
  })
    .then(data => {
      if (!data) {
        console.log("No user found!")
        return done(null, false)
      }

      console.log("Found user in passport.js 🎉")

      done(null, data)
    })
    .catch(err => {
      console.log("No user found! Error. " + err)
      done(err, false)
    })
}))

// LOCAL STRATEGY
passport.use(new LocalStrategy({
  usernameField: 'email'
}, async (email, password, done) => {
  try {
    // Find the user given the email
    db.User.findOne({
      where: { email: email }
    })
      .then(user => {
        // If not, handle it
        if (!user) {
          return done(null, false)
        }

        user.validatePassword(password)
          .then(isMatch => {
            // If not, handle it
            if (!isMatch) {
              return done(null, false);
            }

            // Otherwise, return the user
            done(null, user)

          })
      })
      .catch(err => {
        console.log(err)
        return done(err, false)
      })
  } catch (error) {
    done(error, false)
  }
}))