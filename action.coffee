$ = require 'bling'
empty = Object.freeze []

module.exports = class Action
	constructor: (@target) ->
	begin: (context) ->
		context.get(@target).react(context, @)
	end: (context) -> null
	log: (msg...) ->
		$.log @constructor.name + ":", msg...
class Action.IDLE extends Action
	constructor: (target, @dt) -> super target
	end: (context) ->
		@log "Idling for #{@dt}ms..."
class Action.MOVE extends Action
	constructor: (target, @from, @to) -> super target
	end: (context) ->
		@log "Moving #{@target} to #{@to}"
		context.get(@target).moveTo @to
class Action.HEAL extends Action
	constructor: (target, @health) -> super target
	end: (context) ->
		@log "Healing #{@target} by #{@health}"
		context.get(@target).adjustHp @health
class Action.MANA extends Action
	constructor: (target, @mana) -> super target
	end: (context) ->
		@log "Mana increasing on #{@target} by #{@mana}"
		context.get(@target).adjustMana @mana
class Action.DAMAGE extends Action
	constructor: (target, @type, @slot, @damage) -> super target
	end: (context) ->
		@log "Hurting #{@target} by #{@damage}"
		context.get(@target).adjustHp -1 * @damage
class Action.ADDSTATUS extends Action
	constructor: (target, @status) -> super target
	end: (context) ->
		@log "Adding status #{@status.constructor.name} to #{@target}"
		context.get(@target).addStatus @status
class Action.ENDSTATUS extends Action
	constructor: (target, @status) -> super target
	end: (context) ->
		@log "Removing status #{@status.constructor.name} from #{@target}"
		context.get(@target).removeStatus @status
class Action.PUSH extends Action
	constructor: (target, @dir, @dist) -> super target
	end: (context) ->
		owner = context.get('owner')
		target = context.get(@target)
		delta = target.pos.minus owner.pos

$.type.register 'action',
	is: is_action = (o) -> $.isType Action, o

class Action.Stack
	constructor: (items...) ->
		items = $(items).filter is_action
		$.extend @,
			push: (x) -> items.unshift x
			pushAll: (a) ->
				return unless $.is 'array', a
				a = a.filter is_action
				(items.unshift a.pop()) while a.length
			pop:      -> items.shift()
			isEmpty:  -> !items.length
			log: (m...) -> $.log "Action.Stack:", m...
			process:  (context) ->
				while not @isEmpty()
					item = items.pop()
					@log "starting item:", item.constructor.name
					@pushAll reactions = item.begin(context)
					@log "added #{reactions.length} reactions:", reactions
					item.end(context)
					@log "finished item:", item.constructor.name
				@log "done."
		@log "Starting new stack:", items.map($.type)
