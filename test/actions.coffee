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
		Action.debug()
		echo = (msg) -> new Action.ECHO msg
		Action.enqueue echo "one"
		Action.debug()
		Action.enqueue echo "two"
		Action.debug()
		Action.execute(new Action.Context null, { })
