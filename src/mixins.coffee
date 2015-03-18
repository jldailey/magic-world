Bling = $ = require 'bling'
$.extend $.global, require "./globals"

#include "defines.h"

module.exports.Mixable = class Mixable extends $.EventEmitter
	@has = (f, args...) -> f.call @, args...
	constructor: -> super @

MIXIN(Logger) -> $.extend @::,
	log: -> $.log @constructor.name + (if @name? then "(#{@name})" else ""), arguments...

MIXIN(Position) ->
	PROP('x', @pos[0])
	PROP('y', @pos[1])
	PROP('z', @pos[2])
	$.extend @::,
		pos: empty_zeros
		moveTo: (pos) ->
			COPY_ON_WRITE(@pos)
			@pos = pos
		translate: (pos) ->
			COPY_ON_WRITE(@pos)
			@pos = @pos.plus pos


MIXIN(Attribute) (name, cur, max) ->
	caps = $.capitalize $.camelize name
	COW_ARRAY(name, cur, max)
	COW_PROP('current'+caps, @[name], 0, 0, @['max'+caps])
	COW_PROP('max'+caps,     @[name], 1, 0, 10000)

MIXIN(ActiveEffects) -> $.extend @::,
	active: empty_bling
	tickStatus: FLAT_MAP(@active, tick, context, dt)
	reactStatus: FLAT_MAP(@active, react, context, action)
	addStatus: COW_ARRAY_ADD(@active)
	removeStatus: COW_ARRAY_REMOVE(@active)

MIXIN(InstanceList) ->
	instances = []
	$.extend @, {
		addInstance: (t) ->
			ARRAY_ADD(instances, t)
			@
		removeInstance: (t) ->
			ARRAY_REMOVE(instances, t)
			@
		getInstance: (i) -> instances[i]
	}

MIXIN(Levels) ->
	COW_ARRAY('xp', 0, 5)
	COW_ARRAY('level', 1, 10000)
	$.defineProperty @::, 'currentXp',
		get: -> @xp[0]
		set: (xp) ->
			COPY_ON_WRITE(@xp)
			while xp >= @xp[1]
				@currentLevel += 1
				xp -= @xp[1]
				@xp[1] <<= 1 # double the max xp
			@xp[0] = CLAMP(xp, 0, @xp[1])
			@
	COW_PROP('maxXp', @xp, 1, 0, Infinity)
	COW_PROP('currentLevel', @level, 0, 0, 10000)

MIXIN(Spellbook) -> $.extend @::,
	spells: Object.create null
	learn: (spell) ->
		obj = Object.create null
		obj[spell.name] = spell
		@spells = $.inherit @spells, obj
		@log "Learned spell:", spell.name
		@
	cast: (name, target = @target) ->
		@target = target
		unless spell = @spells[name]
			@log "Unknown spell:", name
		else if @currentMp < spell.cost
			@log "Not enough mp for:", spell.name, "need", spell.cost, "have", @currentMp
		else
			@log "Casting spell:", name
			Action.enqueue spell.effects, new Action.Context @, {
				self: @
				target: @target
			}
		@
