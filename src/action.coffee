$ = require 'bling'
{ Heap } = require './data-structures'

#include "defines.h"

export default class Action
	constructor: (@actor, @target, @ms) ->
		@started = null
		@trace = false
	begin: (context) ->
		@started = $.now
		context.react @
	apply: (context) ->
		$.log "Action.#{@constructor.name} trace took #{$.now - @started}ms."
		null
	log: (msg...) ->
		$.log @constructor.name + ":", msg...
class Action.TICK extends Action
	constructor: (actor, @dt) -> super actor, null
class Action.MOVE extends Action
	constructor: (actor, @from, @to) -> super actor, null
	apply: (context) ->
		@log "Moving #{@target} to #{@to}"
		dx = @to[0] - target.pos[0]
		dy = @to[1] - target.pos[1]
		return Mutation.adjust target, ['X', dx], ['Y', dy]
class Action.HEAL extends Action
	constructor: (target, @health) -> super null, target
	apply: (context) ->
		@log "Healing #{@target} by #{@health.toFixed 2}"
		return new Mutation @target,
			[ (if @health > 0 then '.increaseHp' else '.decreaseHp'), @health ]
class Action.MANA extends Action
	constructor: (target, @mana) -> super target
	apply: (context) ->
		return new Mutation @target, 
		if (ret = context[@target].adjustMana @mana) > 0
			@log "Mana increasing on #{@target} by #{ret.toFixed 2}"
		super(context)
class Action.DAMAGE extends Action
	constructor: (target, @type, @slot, @damage) -> super target
	apply: (context) ->
		target = context[@target]
		@log "Hurting #{@target} (#{target.name}) by #{@damage} hp"
		target.adjustHp -1 * @damage
		super(context)
class Action.ADDSTATUS extends Action
	constructor: (target, @status) -> super target
	apply: (context) ->
		@log "Adding status #{@status.constructor.name} to #{@target}"
		context[@target].addStatus @status
		super(context)
class Action.ENDSTATUS extends Action
	constructor: (target, @status) -> super target
	apply: (context) ->
		@log "Removing status #{@status.constructor.name} from #{@target}"
		context[@target].removeStatus @status
		super(context)
class Action.PUSH extends Action
	constructor: (target, @force) -> super target
	apply: (context) ->
		self = context.self
		target = context[@target]
		delta = target.pos.minus self.pos
		delta = delta.normalize().scale(@force)
		target.vel.add delta
		super(context)
class Action.ECHO extends Action
	constructor: (@msg) -> super null
	apply: (context) ->
		console.log "ECHO:", @msg

$.type.register 'action',
	is: is_action = (o) -> $.isType Action, o

class Action.Context
	constructor: (owner, targets) ->
		Object.assign @,
			owner: owner,
			targets: targets = $.extend { owner: owner }, targets
			get: (target) ->
				return if $.is 'string', target then targets[target]
				else target
			react: (action) ->
				$.valuesOf(targets).distinct().log('reacting').select('react').call(@, action).flatten()

# There is a default global Action Heap
heap = new Heap 5000, (obj) -> obj?.nice ? 0
Action.debug = -> console.log heap.data.slice(0,heap.length)
Action.clear = -> heap.clear()
Action.enqueue = (item) -> heap.insert item
Action.current = -> heap.peek()
Action.execute = (context) ->
	while action = heap.peek()
		if action.started
			action.end context
			heap.pop()
		else
			reactions = action.begin context
			if reactions?.length?
				heap.insert(r) for r in reactions
