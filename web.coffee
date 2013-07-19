express = require("express")
app = express()
app.use(express.logger())

app.get('/', (request, response) ->
	response.send("Hello world!")
)

port = process.env.PORT or 5000
app.listen(port, ->
	console.log("Listening on port #{ port }")
)

