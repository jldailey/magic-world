Bling = $ = require 'bling'
$.extend $.global, require "./globals"

mixin = (klass) ->
	module.exports[klass.name] = klass

mixin class Mixable
	@has = (f, args...) -> f.call @, args...

mixin class Position then constuctor: ->
	getter @::, 'x', 'pos', 0
	getter @::, 'y', 'pos', 1
	getter @::, 'z', 'pos', 2
	$.extend @::, {
		pos: empty_zeros
		moveTo: (pos) -> @pos = immutable pos
		translate: (pos) -> @pos = immutable @pos.plus pos
	}

mixin class Attribute then constructor: (name, cur, max) ->
	caps = $.capitalize $.camelize name
	getter @::, 'current'+caps, name, 0
	getter @::, 'max'+caps, name, 1
	@::[name] = immutable [cur, max]
	@::['adjust'+caps] = (delta) ->
		m = @[name]
		c = m[0]
		n = Math.min c + delta, m[1]
		if n != c
			@[name] = immutable [ n, m[1]]
		delta = @[name][0] - c
	@::['adjustMax'+caps] = (delta) ->
		@[name] = @[name].plus [0, delta]
		delta

mixin class ActiveEffects then constructor: -> $.extend @::,
	active: empty_bling
	tickStatus: (context, dt) ->
		result = []
		for status in @active
			for reaction in status.tick(context,dt)
				result.push reaction
		result
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

mixin class Spellbook then constructor: -> $.extend @::,
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
		else if @currentMp < spell.cost
			@log "Not enough mp for:", spell.name, "need", spell.cost, "have", @currentMp
		else
			@log "Casting spell:", name
			context = new ActionContext @, {
				self: @
				target: @target
			}
			new Action.Stack(spell.effects...).process(context)
		null

mixin class Logger then constructor: -> $.extend @::,
	log: (msg...) ->
		n = @constructor.name
		if @name
			n += "("+@name+")"
		$.log n+":", msg...

mixin class InstanceList then constructor: ->
	instances = []
	$.extend @::, {
		addInstance: (t) ->
			if (i = instances.indexOf t) is -1
				instances.push i
		removeInstance: (t) ->
			if (i = instances.indexOf t) is -1
				instances.split i, 1
		getInstance: (i) -> instances[i]
	}

mixin class Levels then constructor: -> $.extend @::,
	xp: immutable $ 0, 0
	level: immutable $ 0, 0
	adjust
	adjustXp: (delta) ->
		oldLevel = @level[0]
		if @xp[0] + delta >= @xp[1]
			newLevel = oldLevel + 1
			@adjustMaxXp @xp[1]
