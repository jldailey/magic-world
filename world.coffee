$ = require 'bling'
Action = require './action'
Base = require './base'
Status = require './status'

empty = Object.freeze []
decorator = ->
immutable = (o) -> Object.freeze o
getter = (o, name, prop, key) ->
	$.defineProperty o, name,
		get: -> @[prop][key]

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
		c = m[0]
		n = Math.min c + delta, m[1]
		if n != c
			@[name] = immutable [ n, m[1]]
		delta = @[name][0] - c
	@['adjustMax'+caps] = (delta) ->
		@[name] = @[name].plus [0, delta]
		delta

decorator ActiveEffects = ->
	$.extend @, {
		active: immutable $ [ ]
		tickStatus: (context, dt) ->
			@active.select('tick').call(context, dt) \
				.map(Bling::reverse)
				.flatten()
		reactStatus: (context, action) ->
			@active.select('react').call(context, action) \
				.map(Bling::reverse)
				.flatten()
		addStatus: (status) ->
			if Object.isFrozen @active
				@active = $ @active.concat [ status ]
			else @active.push status
			@log "Added Status:", status.constructor.name
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
		cast: (name, target = @target) ->
			@target = target
			unless spell = @spells[name]
				@log "Unknown spell:", name
			else if @currentMana < spell.cost
				@log "Not enough mana for:", spell.name, ", need", spell.cost, "have", @currentMana
			else
				@log "Casting spell:", name
				context = new Context @, {
					self: @
					target: @target
				}
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

class Context
	constructor: (owner, targets) -> $.extend @,
		owner: owner,
		targets: targets = $.extend { owner: owner }, targets
		get: (target) ->
			return if $.is 'string', target then targets[target]
			else target

class Wizard extends Base
	@has Logger
	@has Position
	@has ActiveEffects
	@has Attribute 'hp', 100, 100
	@has Attribute 'mana', 50, 50
	@has Spellbook

	wizards = []
	@tick = (dt) -> w.tick(dt) for w in wizards

	constructor: (@name) ->
		@addStatus new Status.MPS 1, Infinity # innate mana regen
		@addStatus new Status.ARMOR 'skin', 10, Infinity
		@target = null
		wizards.push @

	destroy: ->
		if ~(i = wizards.indexOf @)
			wizards.splice i, 1
		@target = null

	tick: (dt) ->
		context = new Context @, {
			self: @
			target: @target
		}
		new Action.Stack(@tickStatus(context, dt)...).process(context)
		new Action.Stack(@active
			.select('tick')
			.call(context, dt) # get all the tick actions
			.map(Bling::reverse)
			.flatten()...
		).process(context) # execute all the actions

	react: (context, action) ->
		@reactStatus(context, action)

	toString: ->
		effects = @active.select('constructor.name')
		"Wizard(#{@name}) h:#{@currentHp.toFixed 0}/#{@maxHp} m:#{@currentMana.toFixed 0}/#{@maxMana} effects: #{effects.join ', '}"

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
		Wizard.tick dt
		console.log(d.toString())
		console.log(c.toString())


