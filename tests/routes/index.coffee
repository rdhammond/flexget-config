yaml = require 'js-yaml'
fs = require 'fs'
router = require '../../routes'

class AppMock
	constructor: () ->

	get: (path, cb) ->
		@get[path] = cb
		
	post: (path, cb) ->
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
		
	send: (code) ->
		@resultCode = code

inputPath = './config.yml'
		
writeSampleFile = (path) ->
	config =
		tasks:
			download_tv:
				series:
					dummy_show:
						begin: 'S01E02'
						quality: [
							'hdtv <720p !ac3 !dd5.1',
							'sdtv'
						]
	
	contents = yaml.safeDump config, yaml. {schema: yaml.FAILSAFE_SCHEMA}
	fs.writeFileSync path, contents
		
module.exports =
	setUp: (callback) ->
		writeSampleFile inputPath
		this.app = new AppMock()
		this.router = router(app)
		callback()

	tearDown: (callback) ->
		fs.unlinkSync inputPath if fs.existsSync inputPath
		callback()

	getShouldWork: (test) ->
		test.expect 4
		
		req = new ReqMock {}
		res = new ResMock
		promise = app.get['/'] req, res
		
		promise.then ->
			test.ok res.wasCalled
			test.equal res.viewCalled, 'index.html'
			test.equal res.modelCalled.length, 1
			test.equal res.modelCalled[0].name, 'dummy_show'
			test.done()
	
	postAddShouldWork: (test) ->
		test.expect 6
		
		req = new ReqMock {name:'testShow', season:2, episode:4}
		res = new ResMock()
		promise = app.post['/add'] req, res
		
		promise.then ->
			test.ok res.wasCalled
			test.equal res.viewCalled, 'existing'
			test.equal res.modelCalled.length, 1
			
			mode = res.modelCalled[0]
			test.equal mode.name, req.name
			test.equal mode.season, req.season
			test.equal mode.episode, req.episode
			test.done()
	
	postAddShouldFilterNonsense: (test) ->
		test.expect 2
		
		show =
			name: 'testShow'
			season: 2
			episode: 3
			blah: 'hurf'
		
		req = new ReqMock show
		res = new ResMock()
		promise = app.post['/add'] req, res
		
		promise.then ->
			test.ok res.wasCalled
			test.ok not res.modelCalled.blah?
			test.done()
	
	postAddShouldErrorIfInvalid: (test) ->
		test.expect 1
		
		req = new ReqMock {}
		res = new ResMock()
		promise = app.post['/add'] req, res
		
		promise.then ->
			test.equal res.resultCode, 500
			test.done()
	
	deleteShouldWork: (test) ->
		test.expect 1
		
		req = new ReqMock {id: 'dummy_show'}
		res = new ResMock()
		promise = app.post['/delete'] req, res
		
		promise.then ->
			test.equal res.resultCode, 200
			test.done()
	
	deleteShouldErrorIfNoId: (test) ->
		test.expect 1
		
		req = new ReqMock {}
		res = new ResMock()
		promise = app.post['/delete'] req, res
		
		promise.then ->
			test.equal res.resultCode, 500
			test.done()
