express = require("express")
everyauth = require("everyauth")
connectAssets = require("connect-assets")
redis = require("redis")
url = require("url")

# Connect to database
redisCloudURL = url.parse(process.env.REDISCLOUD_URL)
redisClient = redis.createClient(
	redisCloudURL.port, 
	redisCloudURL.hostname,
	{no_ready_check: true}
)
redisClient.auth(redisCloudURL.auth.split(":")[1])

# Setup Facebook auth
usersById = {} # This is our database lol
everyauth.everymodule
	.findUserById( (id, callback) ->
		redisClient.hgetall("user_"+id, (err, obj)->
			callback(null, obj)
		)
)
everyauth.facebook
	.appId(process.env.FB_APP_ID)
	.appSecret(process.env.FB_APP_SECRET)
	.scope("email")
	.fields("id,name,email,picture")
	.findOrCreateUser( (session, accessToken, accessTokenExtra, fbUserMetadata) ->
		promise = this.Promise()
		redisClient.hgetall("user_"+fbUserMetadata.id, (err, obj) ->
			if obj
				promise.fulfill(obj)
			else
				redisClient.hmset("user_"+fbUserMetadata.id, fbUserMetadata)
				promise.fulfill(fbUserMetadata)
		)
		return promise
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
