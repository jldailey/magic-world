$ = require 'bling'
empty = Object.freeze []

#include "defines.h"

module.exports = class Action
	constructor: (@target) ->
		@started = null
		@trace = false
	begin: (context) ->
		@started = $.now
		context.get(@target)?.react?(context, @)
	end: (context) ->
		$.log "Action.#{@constructor.name} trace took #{$.now - @started}ms."
	log: (msg...) ->
		$.log @constructor.name + ":", msg...
class Action.IDLE extends Action
	constructor: (target, @dt) -> super target
class Action.MOVE extends Action
	constructor: (target, @from, @to) -> super target
	end: (context) ->
		@log "Moving #{@target} to #{@to}"
		context.get(@target).moveTo @to
		super(context)
class Action.HEAL extends Action
	constructor: (target, @health) -> super target
	end: (context) ->
		@log "Healing #{@target} by #{@health.toFixed 2}"
		context.get(@target).adjustHp @health
		super(context)
class Action.MANA extends Action
	constructor: (target, @mana) -> super target
	end: (context) ->
		if (ret = context.get(@target).adjustMana @mana) > 0
			@log "Mana increasing on #{@target} by #{ret.toFixed 2}"
		super(context)
class Action.DAMAGE extends Action
	constructor: (target, @type, @slot, @damage) -> super target
	end: (context) ->
		@log "Hurting #{@target} (#{context.get(@target).name}) by #{@damage} hp"
		context.get(@target).adjustHp -1 * @damage
		super(context)
class Action.ADDSTATUS extends Action
	constructor: (target, @status) -> super target
	end: (context) ->
		@log "Adding status #{@status.constructor.name} to #{@target}"
		context.get(@target).addStatus @status
		super(context)
class Action.ENDSTATUS extends Action
	constructor: (target, @status) -> super target
	end: (context) ->
		@log "Removing status #{@status.constructor.name} from #{@target}"
		context.get(@target).removeStatus @status
		super(context)
class Action.PUSH extends Action
	constructor: (target, @dist) -> super target
	end: (context) ->
		owner = context.get('owner')
		target = context.get(@target)
		delta = target.pos.minus owner.pos
		delta = delta.normalize().scale(@dist)
		target.translate(delta)
		super(context)
class Action.ECHO extends Action
	constructor: (@msg) -> super null
	end: (context) ->
		console.log "ECHO:", @msg

$.type.register 'action',
	is: is_action = (o) -> $.isType Action, o

class Action.Context
	constructor: (owner, targets) -> $.extend @,
		owner: owner,
		targets: targets = $.extend { owner: owner }, targets
		get: (target) ->
			return if $.is 'string', target then targets[target]
			else target

#define LEFT(i)  (2*i+1)
#define RIGHT(i) (2*i+2)
#define PARENT(i) ((i-1)/2)
class Action.Heap
	constructor: (@capacity, @score = (x) -> x?.nice ? 0 ) ->
		@clear()
	clear: ->
		@data = new Array(@capacity)
		@length = 0
	peek: -> @data[0]
	pop: -> @remove(0)
	remove: (i) ->
		if @length <= i
			return null
		ret = @data[i]
		@data[i] = @data[@length - 1]
		@data[@length - 1] = null
		@length -= 1
		@trickleDown(i)
		ret
	insert: (item) ->
		if @length is 0
			@data[0] = item
			@length++
		else if @length <= @capacity
			@data[n = @length++] = item
			@bubbleUp(n)
		else @.log "Heap ignoring insert because it's full...", item
		@
	trickleDown: (i) ->
		si = @score(@data[i])
		li = LEFT(i)
		sli = @score(@data[li])
		ri = RIGHT(i)
		sri = @score(@data[ri])
		if sri > sli < si
			SWAP(@data[li], @data[i])
			@trickleDown li
		else if sli > sri < si
			SWAP(@data[ri], @data[i])
			@trickleDown ri
	bubbleUp: (i) ->
		p = PARENT(i)
		while i > 0 and @score(@data[i]) < @score(@data[p])
			SWAP(@data[i], @data[p])
			i = p
			p = PARENT(i)

heap = new Action.Heap 5000, (obj) -> obj?.nice ? 0
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
