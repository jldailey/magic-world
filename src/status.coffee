$ = require 'bling'
empty = Object.freeze []
Action = require './action'

Math.sign = (n) ->
	return if n < 0 then "-"
	else if n > 0 then "+"
	else ""

module.exports = class Status
	constructor: (@sec) -> @ms = @sec * 1000
	isDone: -> @ms <= 0
	react: (context, action) ->
		ret = $()
		@ms -= action.dt ? 0
		if @sec > 0 and @ms <= 0
			ret.push new Action.ENDSTATUS 'owner', @
		ret
	log: (msg...) -> $.log "Status."+@constructor.name+":", msg...

class Status.SPEED extends Status
	constructor: (@speed, sec) -> super sec
	react: (context, action) ->
		super(context, action).push switch action.constructor
			when Action.MOVE
				action.speed += @speed

class Status.ARMOR extends Status
	constructor: (@ac, @slot, sec) ->
		super sec
		@pattern = { 'constructor': Action.DAMAGE, type: 'physical', slot: @slot }
	log: (msg...) ->
		$.log "ARMOR(#{@slot},#{Math.sign @ac}#{Math.abs @ac}):", msg...
	react: (context, action) ->
		try return super(context, action)
		finally if $.matches @pattern, action
			action.damage *= @log "reducing damage by", (1 - @ac/100)

class Status.HPS extends Status
	constructor: (@hps, sec) -> super sec
	react: (context, action) ->
		super(context, action).push new Action.HEAL 'owner', @hps * ((action.dt ? 0) / 1000.0)

class Status.MPS extends Status
	constructor: (@mps, sec) -> super sec
	react: (context, action) ->
		super(context, action).push new Action.MANA 'owner', @mps * ((action.dt ? 0) / 1000.0)

class Status.DPS extends Status
	constructor: (@dps, @type, @slot, sec) -> super sec
	react: (context, action) ->
		super(context, action).push new Action.DAMAGE 'owner', @type, @slot, @dps * ((action.dt ? 0) / 1000.0)

