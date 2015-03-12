$ = require 'bling'
empty = Object.freeze []
Action = require './action'

module.exports = class Status
	constructor: (@sec) ->
		@ms = @sec * 1000
	tick: (context, dt) ->
		return (@ms -= dt) > 0
	react: (context, action) -> empty
	log: (msg...) -> $.log "Status."+@constructor.name+":", msg...

class Status.SPEED extends Status
	constructor: (@speed, sec) -> super sec
	react: (context, action) ->
		switch action.constructor
			when Action.MOVE
				before = action.speed
				action.speed += @speed
				log "SPEED(#{@speed}): increasing action speed from #{before} to #{action.speed}"
		super(conext, action)

class Status.ARMOR extends Status
	constructor: (@ac, @slot, sec) -> super sec
	react: (context, action) ->
		switch Action.constructor
			when Action.DAMAGE
				if action.type is 'physical' and action.slot is @slot
					before = action.damage
					action.damage *= (1 - @ac/100)
					log "ARMOR(#{@ac}): reducing damage from #{before} to #{action.damage}"
		super(context, action)

class Status.HPS extends Status
	constructor: (@hps, sec) -> super sec
	tick: (context, dt) ->
		@log "Ticking for #{dt}ms..."
		return if super(context, dt) then new Action.HEAL 'owner', @hps * (dt / 1000.0)
		else new Action.ENDSTATUS 'owner', @

class Status.MPS extends Status
	constructor: (@mps, sec) -> super sec
	tick: (context, dt) ->
		return if super(context, dt) then new Action.MANA 'owner', @mps * (dt / 1000)
		else new Action.ENDSTATUS 'owner', @

class Status.DPS extends Status
	constructor: (@dps, @type, @slot, sec) -> super sec
	tick: (context, dt) ->
		return if super(context, dt) then new Action.DAMAGE 'owner', @type, @slot, @dps * (dt / 1000)
		else new Action.ENDSTATUS 'owner', @


