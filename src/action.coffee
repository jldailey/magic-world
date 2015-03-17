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
		@log "Healing #{@target} by #{@health.toFixed 2}"
		context.get(@target).adjustHp @health
class Action.MANA extends Action
	constructor: (target, @mana) -> super target
	end: (context) ->
		if (ret = context.get(@target).adjustMana @mana) > 0
			@log "Mana increasing on #{@target} by #{ret.toFixed 2}"
class Action.DAMAGE extends Action
	constructor: (target, @type, @slot, @damage) -> super target
	end: (context) ->
		@log "Hurting #{@target} (#{context.get(@target).name}) by #{@damage} hp"
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

class Action.Context
	constructor: (owner, targets) -> $.extend @,
		owner: owner,
		targets: targets = $.extend { owner: owner }, targets
		get: (target) ->
			return if $.is 'string', target then targets[target]
			else target

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
				if items.length > 0
					@log "processing items:", $(items).select('constructor.name').weave($(items).map(context.get).select('name')).join ' '
				while not @isEmpty()
					item = items.pop()
					@pushAll reactions = item.begin(context)
					item.end(context)
