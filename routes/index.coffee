bodyParser = require 'body-parser'
_ = require 'underscore'
config = require '../config'
flexgetConfig = require '../lib/flexget-config'

jsonEncodedParser = bodyParser.json()

module.exports = (app) ->
	validate = (json) ->
		json = _.pick json, 'name', 'episode', 'season'
		
		isValid = json.name and json.episode > 0 and json.season
		return null if not isValid
		json
	
	app.get '/', (req, res) ->
		config = new flexgetConfig config.yamlPath
		promise = config.getAll config.yamlPath
		promise.then (shows) -> res.render 'index.html', {shows: shows}
	
	app.post '/add', jsonEncodedParser, (req, res) ->
		newShow = validate req.json
		return res.send(500) if not newShow?
		
		config = new flexgetConfig config.yamlPath
		promise = config.add newShow.name, newShow.episode, newShow.season
		promise.then () -> res.render 'existing', newShow
		
	app.post '/delete', jsonEncodedParser, (req, res) ->
		return res.send(500) if not req.json.id?
	
		config = new flexgetConfig config.yamlPath
		promise = config.delete req.json.id
		promise.then () -> res.send 200
