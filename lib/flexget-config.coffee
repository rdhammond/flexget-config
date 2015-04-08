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
	
	newShow: (showInfo) ->
		showInfo.season = "0#{showInfo.season}" if showInfo.season < 10
		showInfo.episode = "0#{showInfo.episode}" if showInfo.episode < 10
		
		result =
			begin: "S#{showInfo.season}E#{showInfo.episode}"
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
		_.map config.tasks.download_tv.series, (v,k) -> {name: k}
		
	add: (showInfo) ->
		config = @fetchConfig()
		
		hasName = _.chain(config.tasks.download_tv.series)
			.keys()
			.has(showInfo.name)
			.value()
			
		return @emptyPromise() if hasName
		
		show = @newShow showInfo
		config.tasks.download_tv.series[showInfo.name] = show
		@saveConfig config
		
	delete: (id) ->
		config = @fetchConfig()
		hasId = _.has config.tasks.download_tv.series, id
		return @emptyPromise() if not hasId
			
		delete config.tasks.download_tv.series[id]
		@saveConfig config
	

module.exports = flexgetConfig
