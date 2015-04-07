fs = require 'fs'
yaml = require 'js-yaml'
_ = require 'underscore'
console = require 'console'
flexgetConfig = require '../../lib/flexget-config'

inputPath = './input.yml'
outputPath = './output.yml'

writeInputFile = () ->
	config =
		tasks:
			download_tv:
				series:
					test1: {}
					test2: {}
					test3: {}
	
	contents = yaml.safeDump config
	fs.writeFileSync inputPath, contents

module.exports =
	setUp: (callback) ->
		writeInputFile()
		this.config = new flexgetConfig inputPath
		callback()
		
	tearDown: (callback) ->
		fs.unlinkSync inputPath if fs.existsSync inputPath
		fs.unlinkSync outputPath if fs.existsSync outputPath
		callback()
		
	getAllWorks: (test) ->
		test.expect 4
		names = this.config.getAll()
		console.info names
		
		test.ok names?
		
		test.ok _.contains(names, 'test1')
		test.ok _.contains(names, 'test2')
		test.ok _.contains(names, 'test3')
		
		test.done()

	# PICK UP HERE
