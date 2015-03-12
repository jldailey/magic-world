$ = require 'bling'
Action = require './action'
Status = require './status'

empty = Object.freeze []
decorator = ->
immutable = (o) -> Object.freeze o
getter = (o, name, prop, key) ->
	$.defineProperty o, name,
		get: -> o[prop][key]

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


decorator Position = ->
	getter @, 'x', 'pos', 0
	getter @, 'y', 'pos', 1
	getter @, 'z', 'pos', 2
	$.extend @, {
		pos: immutable $ 0,0,0
		moveTo: (pos) -> @pos = immutable pos
		translate: (pos) -> @pos = immutable @pos.plus pos
	}

decorator Attribute = (name, cur, max) -> ->
	caps = $.capitalize $.camelize name
	getter @, 'current'+caps, name, 0
	getter @, 'max'+caps, name, 1
	@[name] = immutable [cur, max]
	@['adjust'+caps] = (delta) ->
		m = @[name]
		n = Math.min m[0] + delta, m[1]
		if n != m[0]
			@[name] = immutable [ n, m[1] ]
	@['adjustMax'+caps] = (delta) ->
		@[name] = @[name].plus [0, delta]

decorator ActiveEffects = ->
	$.extend @, {
		active: $ [ ]
		addStatus: (status) ->
			@active.push status
			@log "Added Status:", status.constructor.name, status
		removeStatus: (status) ->
			if ~(i = @active.indexOf status)
				@active.splice i, 1
				@log "Removed Status:", status.constructor.name
	}

decorator Spellbook = ->
	$.extend @, {
		spells: Object.create null
		learn: (spell) ->
			obj = Object.create null
			obj[spell.name] = spell
			@spells = $.inherit @spells, obj
			@log "Learned spell:", spell.name
		cast: (name, target) ->
			spell = @spells[name]
			if not spell
				@log "Unknown spell:", name
			else if @currentMana < spell.cost
				@log "Not enough mana for:", spell.name, ", need", spell.cost, "have", @currentMana
			else
				@log "Casting spell:", name
				context = new Context @, {
					self: @
					target: target
				}
				@log "Creating new stack in cast()"
				new Action.Stack(spell.effects...).process(context)
			null
	}

decorator Logger = ->
	$.extend @, {
		log: (msg...) ->
			n = @constructor.name
			if @name
				n += "("+@name+")"
			$.log n+":", msg...
	}

class Base
	# two synonyms for applying decorators
	@is =  (f) -> f.call @::, @::
	@has = (f) -> f.call @::, @::

class Context
	constructor: (owner, targets) ->
		$.extend @, {
			owner: owner,
			targets: $.extend { owner: owner }, targets
		}
	get: (target) ->
		return if $.is 'string', target then @targets[target]
		else target

class Wizard extends Base
	@has Logger
	@has Position
	@has ActiveEffects
	@has Attribute 'hp', 100, 100
	@has Attribute 'mana', 100, 100
	@has Spellbook

	constructor: (@name) ->
		@addStatus new Status.MPS 1, Infinity # innate mana regen
		@addStatus new Status.ARMOR 'skin', 10, Infinity

	tick: (dt) ->
		@log "Ticking for #{dt}ms..."
		context = new Context @, {
			self: @
		}
		@log "Creating new Stack in tick()", @active.select('constructor.toString').call()
		reactions = @active.select('tick').call(context, dt).filter(null, false).filter(true,false).filter(false,false).flatten()
		@log "Reactions:", reactions
		new Action.Stack(reactions...).process(context)

	react: (context, action) ->
		@log "Reacting to", action.constructor.name
		@active.select('react').call(context, action).filter(null, false).flatten()

if require.main is module
	c = new Wizard('charlie')
	c.learn new Spell "Heal Self",  30, new Action.ADDSTATUS 'self', new Status.HPS 5, 3
	c.learn new Spell "Magic Bolt", 10, new Action.DAMAGE 'target', 30
	c.learn new Spell "Force Push", 20, new Action.PUSH 'target', 'away', 10
	c.cast "Heal Self", c
	start = $.now
	interval = $.interval 333, ->
		start += (dt = $.now - start)
		c.tick dt


