express = require("express")
everyauth = require("everyauth")
connectAssets = require("connect-assets")

# Setup Facebook auth
usersById = {} # This is our database lol
everyauth.everymodule
	.findUserById( (id, callback) ->
		callback(null, usersById[id])
)
everyauth.facebook
	.appId(process.env.FB_APP_ID)
	.appSecret(process.env.FB_APP_SECRET)
	.scope("email")
	.fields("id,name,email,picture")
	.findOrCreateUser( (session, accessToken, accessTokenExtra, fbUserMetadata) ->
		if usersById[fbUserMetadata.id] != undefined
			return usersById[fbUserMetadata.id]
		else
			return usersById[fbUserMetadata.id] = fbUserMetadata
	)
	.redirectPath('/')

# Setup express middlewares
app = express()
app.set("views", __dirname + "/../views")
app.set("view engine", "jade")
app.use(express.logger())
app.use(express.bodyParser())
app.use(express.cookieParser("foobie"))
app.use(express.session())
app.use(everyauth.middleware())
app.use(connectAssets())
app.use(express.static(__dirname+"/../public"))

app.get("/", (req, res, params) ->
	if req.user
		res.render("main")
		console.log "user is #{ JSON.stringify(req.user) }"
	else
		res.render("fblogin")
	undefined
)

# Launch
port = process.env.PORT or 5000
app.listen(port, ->
	console.log("Listening on port #{ port }")
	undefined
)

