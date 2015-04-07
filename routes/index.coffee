bodyParser = require 'body-parser'
config = require '../config'
flexgetConfig = require '../lib/flexget-config'

urlEncodedParser = bodyParser.urlencoded {extended: no}
jsonEncodedParser = bodyParser.json()

module.exports = (app) ->
	app.get '/', (req, res) ->
		config = new flexgetConfig config.yamlPath
		promise = config.getAll config.yamlPath
		
		promise.then (model) ->
			res.render 'index.html', model
			promise.end()
	
	app.post '/add', urlEncodedParser, (req, res) ->
		config = new flexgetConfig config.yamlPath
		promise = config.add req.body.txtShowName
		
		promise.then () ->
			res.redirect '/'
			promise.end()
		
	app.post '/delete', jsonEncodedParser, (req, res) ->
		config = new flexgetConfig cnfig.yamlPath
		promise = config.delete config.yamlPath
		
		promise.then () ->
			res.send 200
			promise.end()
