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
