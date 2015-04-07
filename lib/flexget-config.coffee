Q = require 'q'
fs = require 'fs'
_ = require 'underscore'
yaml = require 'js-yaml'

class flexgetConfig
	constructor: (@path) ->

	fetchConfig: ->
		contents = fs.readFileSync @path
		yaml.safeLoad contents
	
	saveConfig: (config) ->
		contents = yaml.safeDump config, {schema: yaml.FAILSAFE_SCHEMA}
		Q.nfcall fs.writeFile, @path, contents
	
	getAll: ->
		config = @fetchConfig()
		
		_.map config.tasks.download_tv.series, (v,k) -> k
		
	add: (name) ->
		config = @fetchConfig()
		
		if _.has config.tasks.download_tv.series, name
			return
			
		config.tasks.download_tv.series[name] = newShow name
		@saveConfig config
		
	delete: (id) ->
		config = @fetchConfig()
		
		if not _.has config.tasks.download_tv.series, id
			return
			
		delete config.tasks.download_tv.series[id]
		@saveConfig config
	

module.exports = flexgetConfig
