fs = require 'fs'
yaml = require 'js-yaml'
_ = require 'underscore'
flexgetConfig = require '../../lib/flexget-config'

inputPath = './input.yml'

writeInputFile = () ->
	config =
		tasks:
			download_tv:
				series:
					test1: {}
					test2: {}
					test3: {}
	
	contents = yaml.safeDump config, {schema: yaml.FAILSAFE_SCHEMA}
	fs.writeFileSync inputPath, contents

getRawYaml = (path) ->
	contents = fs.readFileSync path
	result = yaml.safeLoad contents
	
getNamesFromYaml = (path) ->
	config = getRawYaml path
	return null if not config?.tasks?.download_tv?.series?
	_.keys config.tasks.download_tv.series

testAllNames = (test, names, maxNum) ->
	for i in [1..maxNum]
		test.ok _.contains(names, "test#{i}")

testNewShow = (test, path, name, begin) ->
	names = getNamesFromYaml path
	test.ok names?
	testAllNames test, names, 4
	
	config = getRawYaml path
	show = config.tasks.download_tv.series[name]
	test.equal show.begin, begin
	test.ok _.contains(show.qualities, 'hdtv <720p !ac3 !dd5.1')
	test.ok _.contains(show.qualities, 'sdtv')

module.exports =
	setUp: (callback) ->
		writeInputFile()
		this.config = new flexgetConfig inputPath
		callback()
		
	tearDown: (callback) ->
		fs.unlinkSync inputPath if fs.existsSync inputPath
		callback()
		
	getAllWorks: (test) ->
		test.expect 4
		shows = this.config.getAll()
		test.ok shows?
		
		names = _.map shows, (x) -> x.name
		testAllNames test, names, 3
		test.done()

	addSingleDigitsWorks: (test) ->
		test.expect 8
		
		newShow =
			name: 'test4'
			season: 1
			episode: 1
		
		addPromise = this.config.add newShow
		
		addPromise.then (err) ->
			throw err if err?
			testNewShow test, inputPath, 'test4', 'S01E01'
			test.done()

	addDoubleDigitsWorks: (test) ->
		test.expect 8
		
		newShow =
			name: 'test4'
			season: 10
			episode: 10
		
		addPromise = this.config.add newShow
		
		addPromise.then (err) ->
			throw err if err?
			testNewShow test, inputPath, 'test4', 'S10E10'
			test.done()

	addShouldSkipExisting: (test) ->
		test.expect 4
		
		addPromise = this.config.add 'test3'
		
		addPromise.then (err) ->
			throw err if err?
			names = getNamesFromYaml inputPath
		
			test.ok names?
			testAllNames test, names, 3
			test.done()
	
	removeWorks: (test) ->
		test.expect 3
		
		deletePromise = this.config.delete 'test3'
		
		deletePromise.then (err) ->
			throw err if err?
			names = getNamesFromYaml inputPath
			
			test.ok names?
			testAllNames test, names, 2
			
			test.done()
	
	removeShouldSkipNonExisting: (test) ->
		test.expect 4
		
		removePromise = this.config.delete 'test4'
		
		removePromise.then (err) ->
			throw err if err?
			names = getNamesFromYaml inputPath
			
			test.ok names?
			testAllNames test, names, 3
			
			test.done()
