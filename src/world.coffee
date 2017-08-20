$ = require 'bling'
Action = require './action'
Status = require './status'
$.extend $.global, require "./globals"

{
	Mixable, Logger, Position,
	InstanceList, ActiveEffects, Symbol,
	Attribute, Spellbook, Levels
} = require "./mixins"

#include "defines.h"

class Spell
	constructor: (@name, @cost, @effects...) ->
		@effects.unshift new Action.MANA 'self', -@cost

class Unit extends Mixable
	@has Logger
	@has Position
	@has InstanceList()

class Hero extends Unit
	@has ActiveEffects
	@has Symbol '@'

	$.type.register 'hero', is: (o) -> o and $.isType Hero, o

	@has Attribute 'str', 10, 25
	@has Attribute 'int', 22, 25
	@has Attribute 'dex', 15, 25

	@has Attribute 'hp', 0, 100
	@has Attribute 'mp', 0, 50
	@has Spellbook

	@has Levels

	constructor: (@name) ->
		super()
		@addStatus new Status.MPS 1, Infinity # innate mp regen
		@addStatus new Status.ARMOR 'skin', 1, Infinity
		@target = null
		@adjustMp @adjustMaxMp @currentInt * 4
		@adjustHp @adjustMaxHp @currentHp * 8

	destroy: ->
		@target = null

	toString: ->
		effects = @active.select('constructor.name')
		"Hero(#{@name}) h:#{@currentHp.toFixed 0}/#{@maxHp} m:#{@currentMp.toFixed 0}/#{@maxMp} effects: #{effects.join ', '}"

class World extends Mixable
	@has ActiveEffects
	constructor: ->
		super()
		@map = new TileGrid()
		@units = []
	addUnit: SET_ADDER(@units)
	removeUnit: SET_REMOVER(@units)

if require.main is module
	c = new Hero('charlie')
	c.learn new Spell "Heal Self",  30,
		new Action.ADDSTATUS 'self',
			new Status.HPS 5, 3
	c.learn new Spell "Magic Bolt", 10,
		new Action.DAMAGE 'target', 'physical', 'skin', 30
	c.learn new Spell "Force Push", 20,
		new Action.PUSH 'target', .1
	d = new Hero('darryll')
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


