express = require 'express'
handlebars = require 'express-handlebars'
settings = require './settings'
router = require './lib/router'

hbsEngine = handlebars
	extname: 'hbs'
	partialsDir: 'views/partials/'

html = express.static "#{__dirname}/public"

app = express()
app.engine 'hbs', hbsEngine
app.set 'view engine', 'hbs'
app.use html
router(app)

server = app.listen settings.appPort, () ->
  host = server.address().address;
  port = server.address().port;	
  console.log "Example app listening at http://#{host}:#{port}"