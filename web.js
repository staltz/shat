// Generated by CoffeeScript 1.3.3
(function() {
  var app, express, port;

  express = require("express");

  app = express();

  app.use(express.logger());

  app.get('/', function(request, response) {
    return response.send("Hello world!");
  });

  port = process.env.PORT || 5000;

  app.listen(port, function() {
    return console.log("Listening on port " + port);
  });

}).call(this);