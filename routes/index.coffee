bodyParser = require 'body-parser'
_ = require 'underscore'
config = require '../config'
flexgetConfig = require '../lib/flexget-config'

jsonEncodedParser = bodyParser.json()

module.exports = (app) ->
	validate = (json) ->
		json = _.pick json, 'name', 'episode', 'season'
		
		if json.name and json.episode > 0 and json.season
			return json
		
		null
	
	app.get '/', (req, res) ->
		config = new flexgetConfig config.yamlPath
		promise = config.getAll config.yamlPath
		
		promise.then (model) ->
			res.render 'index.html', model
			promise.end()
	
	app.post '/add', jsonEncodedParser, (req, res) ->
		newShow = validate req.json
		return req.send(500) if not newShow?
		
		config = new flexgetConfig config.yamlPath
		promise = config.add newShow
		
		promise.then () ->
			res.render 'existing', newShow
			promise.end()
		
	app.post '/delete', jsonEncodedParser, (req, res) ->
		config = new flexgetConfig config.yamlPath
		promise = config.delete config.yamlPath
		
		promise.then () ->
			res.send 200
			promise.end()
