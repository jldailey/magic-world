
import assert from 'assert'
import Status from '../lib/status'

describe "Status", ->
	describe "::react(context, action)", ->
		it "responds with a list of actions", ->
			class S extends Status
			assert.deepEqual new S().react({}, {}), []
	it "can have a duration", ->
		class S extends Status
			constructor: -> super .1
		assert.deepEqual new S().react({}, { dt: 200 }).select('constructor.name'), [ 'ENDSTATUS' ]
		