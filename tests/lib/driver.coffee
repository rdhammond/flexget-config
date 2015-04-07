test = require './flexget-config'

testMock =
	expect: () ->
	ok: () ->
	done: () ->

test.setUp () ->
test.getAllWorks testMock
test.tearDown () ->
