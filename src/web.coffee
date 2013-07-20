nunjucks = require("nunjucks")
express = require("express")
everyauth = require("everyauth")

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
app.use(express.logger())
app.use(express.bodyParser())
app.use(express.cookieParser("foobie"))
app.use(express.session())
app.use(everyauth.middleware())
env = new nunjucks.Environment(new nunjucks.FileSystemLoader('views'))
env.express(app)

#app.configure( ->
#	app.set('view engine', 'jade')
#	app.set('views', everyauthRoot + '/example/views')
#)

app.get("/", (req, res, params) ->
	if req.user
		res.render("main.html")
		console.log "user is #{ req.user }"
	else
		res.render("fblogin.html")
	undefined
)

# Launch
port = process.env.PORT or 5000
app.listen(port, ->
	console.log("Listening on port #{ port }")
	undefined
)

