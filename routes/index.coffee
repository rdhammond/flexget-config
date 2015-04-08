bodyParser = require 'body-parser'
_ = require 'underscore'
config = require '../config'
flexgetConfig = require '../lib/flexget-config'
Q = require 'q'

jsonEncodedParser = bodyParser.json()

module.exports = (app) ->
	validate = (json) ->
		json = _.pick json, 'name', 'episode', 'season'
		
		isValid = json.name and json.episode > 0 and json.season
		return null if not isValid
		json
	
	app.get '/', (req, res) ->
		fgConfig = new flexgetConfig config.yamlPath
		shows = fgConfig.getAll config.yamlPath
		res.render 'index.html', {shows: shows}
	
	app.post '/add', jsonEncodedParser, (req, res) ->
		newShow = validate req.json
		return Q.fcall res.send, 500 if not newShow?
		
		config = new flexgetConfig config.yamlPath
		promise = config.add newShow
		promise.then () -> res.render 'existing', newShow
		
	app.post '/delete', jsonEncodedParser, (req, res) ->
		return Q.fcall(res.send, 500) if not req.json.id?
	
		config = new flexgetConfig config.yamlPath
		promise = config.delete req.json.id
		promise.then () -> res.send 200
