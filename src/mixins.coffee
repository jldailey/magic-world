Bling = $ = require 'bling'
$.extend $.global, require "./globals"

#include "defines.h"

compose = (f, g) ->
	return if typeof f is typeof g is 'function'
		->
			f.apply this, arguments
			g.apply this, arguments
	else g

merge = (a, b) ->
	for k in $.keysOf(b)
		continue if k is 'constructor'
		desc = Object.getOwnPropertyDescriptor(b, k)
		if not desc?
			a[k] = compose a[k], b[k]
		else if 'value' of desc
			a[k] = compose a[k], desc.value
		else if ('get' of desc) or ('set' of desc)
			Object.defineProperty a, k, desc

module.exports.Mixable = class Mixable
	@has = (mixin, args...) ->
		o = (mixin args...)
		# $.log "creating mix-in", o.name
		if o?
			# $.log "merging prototype fields..."
			merge(@::, o::)
			# $.log "merging static fields..."
			merge(@, o)
			if o::constructor isnt Function
				# $.log "adding constructor to mixins hook..."
				@mixins or= $.hook()
				@mixins.append o::constructor

	constructor: ->
		@constructor.mixins?.apply @, arguments
	destroy: -> null

MIXIN(Logger)
	log: (log = $.log) ->
		log @constructor.name + (if @name? then "(#{@name})" else ""), arguments...

MIXIN(Position)
	constructor: ->
		@pos = $ 0, 0, 0
	PROP('x', @pos, 0, -Infinity, Infinity)
	PROP('y', @pos, 1, -Infinity, Infinity)
	PROP('z', @pos, 2, -Infinity, Infinity)
	moveTo:    (pos) -> @pos = $ pos
	translate: (pos) -> @pos = @pos.plus pos

MIXIN(Attribute, name, cur, max)
	constructor: ->
		@[name] = $ cur, max
	caps = $.capitalize $.camelize name
	PROP('max'+caps,     @[name], 1, 0, 10000)
	PROP('current'+caps, @[name], 0, 0, @['max'+caps])
	@::['adjust'+caps] = (delta, overflow) ->
		expected = @[name][0] + delta
		@['current'+caps] += delta
		$.log 'adjust'+caps, 'delta', delta, 'expected', expected, 'result', @[name][0]
		if @[name][0] < expected
			overflow?.call @, (expected - @[name][0])

MIXIN(ActiveEffects)
	constructor: ->
		@active = $()
	react: FLAT_MAP(@active, react, context, action)
	addStatus: SET_ADDER(@active)
	removeStatus: SET_REMOVER(@active)

MIXIN(InstanceList)
	constructor: ->
		SET_ADD(instances, @)
	destroy: ->
		SET_REMOVE(instances, @)
	instances = []
	$.log "adding instances to ", @
	@addInstance = (t) ->
		SET_ADD(instances, t)
		@
	@removeInstance = (t) ->
		SET_REMOVE(instances, t)
		@
	@mapInstances = (f) -> instances.map(f)

MIXIN(Levels)
	constructor: ->
	@has Attribute, 'xp', 0, 5
	@has Attribute, 'level', 1, Infinity
	gainXP: (delta) ->
		@adjustXp delta, (overflow) ->
			@gainLevel()
			@maxXp *= 2
	gainLevel: (delta) ->
		@currentLevel += 1

MIXIN(Spellbook)
	constructor: ->
		@spells = new Map()
	learn: (spell) ->
		@spells.set(spell.name, spell)
		@log "Learned spell:", spell.name
		@
	cast: (name, target = @target) ->
		@target = target
		unless spell = @spells.get(name)
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
