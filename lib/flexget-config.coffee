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
	
	newShow: (name, season, episode) ->
		season = "0#{season}" if season < 10
		episode = "0#{episode}" if episode < 10
		
		result =
			begin: "S#{season}E#{episode}"
			qualities: [
				'hdtv <720p !ac3 !dd5.1',
				'sdtv'
			]
	
	emptyPromise: () ->
		deferred = Q.defer()
		deferred.resolve()
		deferred.promise
	
	getAll: ->
		config = @fetchConfig()
		
		_.map config.tasks.download_tv.series, (v,k) -> k
		
	add: (name, season, episode) ->
		config = @fetchConfig()
		
		hasName = _.chain(config.tasks.download_tv.series)
			.keys()
			.has(name)
			.value()
			
		return @emptyPromise() if hasName
		
		show = @newShow name, season, episode
		config.tasks.download_tv.series[name] = show
		@saveConfig config
		
	delete: (id) ->
		config = @fetchConfig()
		hasId = _.has config.tasks.download_tv.series, id
		return @emptyPromise() if not hasId
			
		delete config.tasks.download_tv.series[id]
		@saveConfig config
	

module.exports = flexgetConfig
