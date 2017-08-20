
$ = require 'bling'
$.extend $.global, require '../lib/mixins'
assert = require 'assert'

collect_log_output = (f) ->
	save = $.log.out
	captured = []
	$.log.out = (a...) -> captured.push a
	f()
	$.log.out = save
	try return output = (line.join ' ' for line in captured).join '\n'
	# finally console.log "OUTPUT:", output

describe "Mixable", ->
	describe "mixing methods", ->
		class C extends Mixable
			@has -> class A then react: ->
			@has -> class B then react: ->

		assert $.is 'function', new C().react

describe "Logger", ->
	it "adds a log method to a class", ->
		class T extends Mixable
			@has Logger
		assert.equal typeof (new T().log), 'function'
	describe "prefixes lines with", ->
		it "class name", ->
			class T extends Mixable
				@has Logger
				constructor: (@name) ->
			assert /T foo$/.test collect_log_output ->
				new T().log("foo")
		it "instance name if available", ->
			class U extends Mixable
				@has Logger
				constructor: (@name) ->
			assert /U\(name\) bar$/.test collect_log_output ->
				new U('name').log("bar")

describe "Position", ->
	class P extends Mixable
		@has Position
	it "adds a .x property", ->
		assert.equal new P().x, 0
	it "adds a .y property", ->
		assert.equal new P().y, 0
	it "adds a .z property", ->
		assert.equal new P().z, 0
	it "adds a .pos property", ->
		assert.deepEqual new P().pos, [0, 0, 0, 0]
	it "adds a .moveTo function", ->
		assert.equal (typeof new P().moveTo), "function"
	it "adds a .translate function", ->
		assert.equal (typeof new P().translate), "function"

describe "Attribute", ->
	class A extends Mixable
		@has Attribute, 'attr', 10, 100
	it "adds a [min, max] property", ->
		assert.deepEqual new A().attr, [10, 100]
	describe ".currentAttr", ->
		it "gets the current value", ->
			assert.equal new A().currentAttr, 10
		it "sets the current value", ->
			a = new A()
			a.currentAttr = 20
			assert.equal a.currentAttr, 20
		it "cannot set the current value too small", ->
			a = new A()
			a.currentAttr = -1000
			assert.equal a.currentAttr, 0
		it "cannot set the current value too large", ->
			a = new A()
			a.currentAttr = 1000
			assert.equal a.currentAttr, a.maxAttr
		it "assignment does not leak across instances", ->
			a = new A()
			b = new A()
			b.currentAttr += 10
			assert.equal a.currentAttr, 10
			assert.equal b.currentAttr, 20
	describe ".maxAttr", ->
		it "gets the max value", ->
			assert.equal new A().maxAttr, 100
		it "sets the max value", ->
			a = new A()
			a.maxAttr = 1000
			assert.equal a.maxAttr, 1000
		it "limits the currentAttr", ->
			a = new A()
			a.maxAttr = 112
			a.currentAttr = 1000
			assert.equal a.currentAttr, 112

describe "ActiveEffects", ->
	class E extends Mixable
		@has ActiveEffects

	class FakeStatus
		react:(context, action) -> [action]

	describe ".active", ->
		it "is an array", ->
			assert.deepEqual (new E().active), []
		it "can .addStatus", ->
			s = new FakeStatus()
			e = new E()
			e.addStatus(s)
			assert.equal e.active.length, 1
		it "can .removeStatus", ->
			s = new FakeStatus()
			e = new E()
			e.addStatus(s)
			assert.equal e.active.length, 1
			e.removeStatus s
			assert.equal e.active.length, 0
		it "can .react", ->
			s = new FakeStatus()
			e = new E()
			e.addStatus(s)
			assert.deepEqual e.react({}, 42), [42]

describe "InstanceList", ->
	class I extends Mixable
		@has InstanceList

	it "provides a global instance list", ->
		a = new I()
		b = new I()
		assert.deepEqual I.getInstances(), [ a, b ]
		I.removeInstance a
		assert.deepEqual I.getInstances(), [ b ]

describe "Levels", ->
	class L extends Mixable
		@has Levels
		@has Logger
	it "adds an 'xp' attribute", ->
		a = new L()
		assert.equal a.currentXp, 0
		assert.equal a.maxXp, 5
		assert.deepEqual a.xp, [0, 5]
		assert.equal a.currentLevel, 1
	it "adding enough to xp will cause level increase", ->
		a = new L()
		a.gainXp 2
		assert.equal a.currentLevel, 1
		assert.equal a.currentXp, 2
		a.gainXp 47
		assert.equal a.currentLevel, 4
		assert.equal a.currentXp, 14
		assert.equal a.maxXp, 40
		a.gainXp 26
		assert.equal a.currentXp, 0
		assert.equal a.currentLevel, 5


