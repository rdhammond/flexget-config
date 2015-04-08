yaml = require 'js-yaml'
fs = require 'fs'
router = require '../../routes'
config = require '../../config'

class AppMock
	constructor: () ->

	get: (path, encoder, cb) ->
		cb = encoder if not cb?
		@get[path] = cb
		
	post: (path, encoder, cb) ->
		cb = encoder if not cb?
		@post[path] = cb

class ReqMock
	constructor: (@json) ->
	
class ResMock
	constructor: (@renderName) ->
		@wasCalled = false
	
	render: (view, model) ->
		@viewCalled = view
		@modelCalled = model
		@wasCalled = true
		
	send: (code) =>
		@resultCode = code

inputPath = './config.yml'
config.yamlPath = inputPath
		
writeSampleFile = (path) ->
	yamlConfig =
		tasks:
			download_tv:
				series:
					dummy_show:
						begin: 'S01E02'
						quality: [
							'hdtv <720p !ac3 !dd5.1',
							'sdtv'
						]
	
	contents = yaml.safeDump yamlConfig, {schema: yaml.FAILSAFE_SCHEMA}
	fs.writeFileSync path, contents
		
module.exports =
	setUp: (callback) ->
		writeSampleFile inputPath
		this.app = new AppMock()
		this.router = router(this.app)
		callback()

	tearDown: (callback) ->
		fs.unlinkSync inputPath if fs.existsSync inputPath
		callback()

	getShouldWork: (test) ->
		test.expect 5
		
		req = new ReqMock {}
		res = new ResMock()
		this.app.get['/'] req, res
		
		test.ok res.wasCalled
		test.equal res.viewCalled, 'index.html'
		test.ok res.modelCalled.shows?
		test.equal res.modelCalled.shows.length, 1
		test.equal res.modelCalled.shows[0].name, 'dummy_show'
		test.done()
	
	postAddShouldWork: (test) ->
		test.expect 5
		
		req = new ReqMock {name:'testShow', season:2, episode:4}
		res = new ResMock()
		promise = this.app.post['/add'] req, res
		
		promise = promise.then ->
			test.ok res.wasCalled
			test.equal res.viewCalled, 'existing'
			
			test.equal res.modelCalled.name, req.json.name
			test.equal res.modelCalled.season, req.json.season
			test.equal res.modelCalled.episode, req.json.episode
			test.done()
			
		#promise.done()
	
	postAddShouldFilterNonsense: (test) ->
		test.expect 2
		
		show =
			name: 'testShow'
			season: 2
			episode: 3
			blah: 'hurf'
		
		req = new ReqMock show
		res = new ResMock()
		promise = this.app.post['/add'] req, res
		
		promise.then ->
			test.ok res.wasCalled
			test.ok not res.modelCalled.blah?
			test.done()
	
	postAddShouldErrorIfInvalid: (test) ->
		test.expect 1
		
		req = new ReqMock {}
		res = new ResMock()
		promise = this.app.post['/add'] req, res
		
		promise.then ->
			console.log res
			test.equal res.resultCode, 500
			test.done()
	
	deleteShouldWork: (test) ->
		test.expect 1
		
		req = new ReqMock {id: 'dummy_show'}
		res = new ResMock()
		promise = this.app.post['/delete'] req, res
		
		promise.then ->
			test.equal res.resultCode, 200
			test.done()
	
	deleteShouldErrorIfNoId: (test) ->
		test.expect 1
		
		req = new ReqMock {}
		res = new ResMock()
		promise = this.app.post['/delete'] req, res
		
		promise.then ->
			test.equal res.resultCode, 500
			test.done()
