express = require 'express'
hbs = require 'express-handlebars'
config = require './config'
routes = require './routes'

app = express()
app.set 'view engine', 'hbs'
app.use express.static('public')

routes(app)

server = app.listen config.appPort, () ->
	host = server.address().address
	port = server.address().port
	console.log "Example app listening at http://#{host}:#{port}"
