import $ from 'bling'
import Action from './action'
{min, max} = Math

clamp = (n, lo, hi) -> min hi, max lo, n

export default class Status
	constructor: (@sec) -> @ms = @sec * 1000
	isDone: -> @ms <= 0
	react: (context, action) ->
		ret = $()
		@ms -= action.dt ? 0
		if @sec > 0 and @ms <= 0
			ret.push new Action.ENDSTATUS 'owner', @
		ret
	log: (msg...) -> $.log "Status",@constructor.name, msg...

class Status.SPEED extends Status
	constructor: (@speed, sec) -> super sec
	react: (context, action) ->
		super(context, action).push switch action.constructor
			when Action.MOVE
				action.speed += @speed

class Status.ARMOR extends Status
	toString = (ac) ->
		(if ac > 0 then "+" else "") + ac
	constructor: (@ac, @slot, sec) ->
		super sec
		@pattern = { 'constructor': Action.DAMAGE, type: 'physical', slot: @slot }
	log: (msg...) ->
		@log "[#{@slot}, #{toString @ac}]", msg...
	react: (context, action) ->
		if $.matches @pattern, action
			@log "reducing damage by",
			dd = (clamp (1 - @ac/100), 0.05, 10.0), "to",
			action.damage *= dd
		super(context, action)

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

