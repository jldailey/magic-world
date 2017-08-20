import $ from 'bling'
import "./globals"
{ PI } = Math

#include "defines.h"

both = (f, g) -> # not compose (which would be g(f(x)), here we just want f(x),g(x)
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
			a[k] = both a[k], b[k]
		else if 'value' of desc
			a[k] = both a[k], desc.value
		else if ('get' of desc) or ('set' of desc)
			Object.defineProperty a, k, desc

export class Mixable
	@has = (o) ->
		if o?
			# apply one mixin to a class
			merge @::, o::
			merge @, o
			(o::constructor isnt Function) and
				(@mixins or= $.hook()).append o::constructor

	constructor: ->
		@constructor.mixins?.apply @, arguments

export Logger = (log = $.log) ->
	class Logger
		log: ->
			log @constructor.name + (if @name? then "(#{@name})" else ""), arguments...

export class Position
	constructor: ->
		@pos = $ 0, 0, 0, 0
	PROP('x', @pos, 0, -Infinity, Infinity)
	PROP('y', @pos, 1, -Infinity, Infinity)
	PROP('z', @pos, 2, -Infinity, Infinity)
	PROP('r', @pos, 3, -PI, PI)
	moveTo:    (x,y,z,r) ->
		@x = x ? @x
		@y = y ? @y
		@z = z ? @z
		@r = r ? @r
	translate: (dx,dy,dz,dr) ->
		@x = @x + (dx ? 0)
		@y = @y + (dy ? 0)
		@z = @z + (dz ? 0)
		@r = @r + (dr ? 0)

export class Velocity
	velocity_decay = .99
	constructor: ->
		@vel = $ 0, 0, 0, 0
	PROP('vx', @vel, 0, -Infinity, Infinity)
	PROP('vy', @vel, 1, -Infinity, Infinity)
	PROP('vz', @vel, 2, -Infinity, Infinity)
	PROP('vr', @vel, 3, -Infinity, Infinity)
	tickVelocity: (dt) ->
		@translate (v*dt for v in @vel)...
		f = pow(velocity_decay,dt)
		@vel = (v*f for v in @vel)

export Attribute = (name, cur, max) ->
	class Attribute
		constructor: ->
			@[name] = $ cur, max
		caps = $.capitalize $.camelize name
		PROP('max'+caps,     @[name], 1, 0, 10000)
		PROP('current'+caps, @[name], 0, 0, @['max'+caps])
		@::['increase'+caps] = (delta, overflow) ->
			expected = @[name][0] + delta
			@['current'+caps] += delta
			if @[name][0] < expected or @[name][0] == @[name][1]
				overflow?.call @, (expected - @[name][0])
		@::['decrease'+caps] = (delta, overflow) ->
			expected = @[name][0] - delta
			@['current'+caps] -= delta
			if @[name][0] > expected or @[name][0] == @[name][1]
				overflow?.call @, (expected - @[name][0])

export class ActiveEffects
	constructor: ->
		@active = $()
	react: FLAT_MAP(@active, react, context, action)
	addStatus: SET_ADDER(@active)
	removeStatus: SET_REMOVER(@active)

export InstanceList = ->
	instances = []
	class InstanceList
		constructor: -> SET_ADD(instances, @)
		destroy: ->
			SET_REMOVE(instances, @)
			super()
		@getInstances = -> instances.slice(0)

export class Levels
	@has Attribute, 'xp', 0, 5
	@has Attribute, 'level', 1, Infinity
	constructor: ->
	gainXp: (delta) ->
		do f = (d = delta) =>
			@adjustXp d, (overflow) =>
				@gainLevel()
				@currentXp = 0
				@maxXp *= 2
				if overflow > 0
					try f(overflow) # partial credit on stack overflow, instead of crash
				null
		@
	gainLevel: (delta) ->
		@currentLevel += 1
		@

export class Spellbook
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
			return applyEffectsToContext spell.effects, {
				self: @
				target: @target
			}
		@

export Symbol = (s) ->
	class Symbol
		constructor: ->
			@symbol = s
