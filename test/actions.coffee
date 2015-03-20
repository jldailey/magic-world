$ = require 'bling'
assert = require 'assert'
Action = require "../bin/action"

describe "Action Heap", ->
	it "orders based on a 'nice' property", ->
		Action.clear()
		obj = (prio) -> { nice: prio, msg: prio }
		Action.enqueue obj(10)
		Action.enqueue obj(7)
		Action.enqueue obj(12)
		assert.equal Action.current().msg, 7
	it "executes items in the heap", ->
		Action.clear()
		output = ""
		class Action.ECHO extends Action
			constructor: (@msg) -> super null
			end: (context) ->
				output += @msg
		echo = (msg) -> new Action.ECHO msg
		Action.enqueue echo "one"
		Action.enqueue echo "two"
		Action.execute(new Action.Context null, { })
		assert.equal output, "onetwo"

describe "Action.Context", ->
	describe "stores in-flight information about an action as it happens", ->
	it "has an owner", ->
		c = new Action.Context( {name: 'Joe' }, { })
		assert.equal c.owner.name, "Joe"
	describe ".get(name)", ->
		it "can reference other entities", ->
			c = new Action.Context( joe = { name: 'Joe' }, {
				self: joe
				target: { name: 'Jill' }
			})
			assert.equal c.get('owner').name, 'Joe'
			assert.equal c.get('target').name, 'Jill'
