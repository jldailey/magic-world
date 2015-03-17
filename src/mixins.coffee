Bling = $ = require 'bling'
$.extend $.global, require "./globals"

#include "defines.h"

MIXIN(Mixable) ->
	@has = (f, args...) -> f.call @, args...
	$.extend @::, $.EventEmitter()

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
	PROP('current'+caps, @[name][0])
	PROP('max'+caps, @[name][1])
	@::[name] = FROZEN $ [cur, max]
	@::['adjust'+caps] = (delta) ->
		COPY_ON_WRITE(@[name])
		m = @[name]
		c = m[0]
		m[0] = CLAMP(c + delta, 0, m[1])
		delta = m[0] - c
	@::['adjustMax'+caps] = (delta) ->
		COPY_ON_WRITE(@[name])
		@[name][1] += delta
		delta

#define MAP_ACTIVE(f,...) (__VA_ARGS__) -> t = []; (t.push r for r in s.f(__VA_ARGS__) for s in @active); t
#define COPY_ON_WRITE(v) if Object.isFrozen v then v = v.slice(0)

MIXIN(ActiveEffects) -> $.extend @::,
	active: empty_bling
	tickStatus: MAP_ACTIVE(tick, context, dt)
	reactStatus: MAP_ACTIVE(react, context, action)
	addStatus: (status) ->
		COPY_ON_WRITE(@active)
		ARRAY_ADD(@active, status)
		@
	removeStatus: (status) ->
		COPY_ON_WRITE(@active)
		ARRAY_REMOVE(@active, status)
		@

MIXIN(Logger) -> $.extend @::,
	log: $.logger "__FILE__:__LINE__"

MIXIN(InstanceList) ->
	instances = []
	$.extend @::, {
		addInstance: (t) ->
			ARRAY_ADD(instances, t)
			@
		removeInstance: (t) ->
			ARRAY_REMOVE(instances, t)
			@
		getInstance: (i) -> instances[i]
	}

MIXIN(Levels) -> $.extend @::,
	xp:    FROZEN $ 0, 0
	level: FROZEN $ 0, 0
	adjustXp: (delta) ->
		COPY_ON_WRITE(@xp)
		if (xp = @xp[0] + delta) >= @xp[1]
			@adjustLevel 1
			@adjustMaxXp @xp[1]
			xp = 0
		@xp[0] = xp
		@
	adjustMaxXp: (delta) ->
		COPY_ON_WRITE(@xp)
		@xp[1] += delta
		@
	adjustLevel: (delta) ->
		COPY_ON_WRITE(@level)
		@level[0] = CLAMP(@level[0] + delta, 0, @level[1])
		@

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
			context = new ActionContext @, {
				self: @
				target: @target
			}
			new Action.Stack(spell.effects...).process(context)
		@
