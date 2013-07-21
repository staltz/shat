// Generated by CoffeeScript 1.6.3
(function() {
  var app, connectAssets, everyauth, express, port, usersById;

  express = require("express");

  everyauth = require("everyauth");

  connectAssets = require("connect-assets");

  usersById = {};

  everyauth.everymodule.findUserById(function(id, callback) {
    return callback(null, usersById[id]);
  });

  everyauth.facebook.appId(process.env.FB_APP_ID).appSecret(process.env.FB_APP_SECRET).scope("email").fields("id,name,email,picture").findOrCreateUser(function(session, accessToken, accessTokenExtra, fbUserMetadata) {
    if (usersById[fbUserMetadata.id] !== void 0) {
      return usersById[fbUserMetadata.id];
    } else {
      return usersById[fbUserMetadata.id] = fbUserMetadata;
    }
  }).redirectPath('/');

  app = express();

  app.set("views", __dirname + "/../views");

  app.set("view engine", "jade");

  app.use(express.logger());

  app.use(express.bodyParser());

  app.use(express.cookieParser("foobie"));

  app.use(express.session());

  app.use(everyauth.middleware());

  app.use(connectAssets());

  app.use(express["static"](__dirname + "/../public"));

  app.get("/", function(req, res, params) {
    if (req.user) {
      res.render("main");
      console.log("user is " + (JSON.stringify(req.user)));
    } else {
      res.render("fblogin");
    }
    return void 0;
  });

  port = process.env.PORT || 5000;

  app.listen(port, function() {
    console.log("Listening on port " + port);
    return void 0;
  });

}).call(this);
