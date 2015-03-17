$ = require 'bling'
Action = require './action'
Status = require './status'
$.extend $.global, require "./globals"
$.extend $.global, require "./mixins"


# quick ES6 shim for Map
unless global.Map
	class Map
		constructor: ->
			data = Object.create null
			$.extend @,
				set: (k,v) -> data[k] = v
				get: (k) -> data[k]
				has: (k) -> k of data
				keys: -> Object.keys data

class Spell
	constructor: (@name, @cost, @effects...) ->
		@effects.unshift new Action.MANA 'self', -@cost

class Unit extends Mixable
	@has Logger
	@has Position
	@has InstanceList

class Wizard extends Unit
	@has ActiveEffects

	$.type.register 'wizard', is: (o) -> $.isType Wizard, o

	@has Attribute, 'str', 10, 25
	@has Attribute, 'int', 22, 25
	@has Attribute, 'dex', 15, 25

	@has Attribute, 'hp', 0, 100
	@has Attribute, 'mp', 0, 50
	@has Spellbook

	@has Levels

	constructor: (@name) ->
		@addInstance @
		@addStatus new Status.MPS 1, Infinity # innate mp regen
		@addStatus new Status.ARMOR 'skin', 10, Infinity
		@target = null
		@adjustMp @adjustMaxMp @currentInt * 4
		@adjustHp @adjustMaxHp @currentHp * 8

	destroy: ->
		@target = null
		@removeInstance @

	tick: (dt) ->
		context = new Action.Context @, {
			self: @
			target: @target
		}
		new Action.Stack(@tickStatus(context, dt)...).process(context)

	react: (context, action) ->
		@reactStatus(context, action)

	toString: ->
		effects = @active.select('constructor.name')
		"Wizard(#{@name}) h:#{@currentHp.toFixed 0}/#{@maxHp} m:#{@currentMp.toFixed 0}/#{@maxMp} effects: #{effects.join ', '}"

if require.main is module
	c = new Wizard('charlie')
	c.learn new Spell "Heal Self",  30, new Action.ADDSTATUS 'self', new Status.HPS 5, 3
	c.learn new Spell "Magic Bolt", 10, new Action.DAMAGE 'target', 'physical', 'skin', 30
	c.learn new Spell "Force Push", 20, new Action.PUSH 'target', 'away', 10
	d = new Wizard('darryll')
	d.learn new Spell "Zap", 10, new Action.DAMAGE 'target', 'shock', 'skin', 10
	$.interval 1300, ->
		d.cast "Zap", c
	$.delay 4000, ->
		c.cast "Heal Self", c
	start = $.now
	interval = $.interval 333, ->
		start += (dt = $.now - start)
		console.log(d.toString())
		console.log(c.toString())


