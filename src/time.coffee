
requestFrame = requestAnimationFrame ? $.partial $.delay, 32
class Clock
	constructor: (@tick) ->
		unless (typeof @tick) is 'function'
			throw new TypeError("new Clock() expects a function as argument")
		locked = true
		@time = 0
		Object.assign @,
			start: ->
				return unless locked
				locked = false
				last_tick = +new Date
				do frame = =>
					last_tick += dt = (+new Date) - last_tick
					@time += dt
					@tick dt
					if not locked then requestFrame frame
				@
			stop: ->
				locked = true
				@
			toString: ->
				"#{(@time / 1000.0).toFixed 3}s"

Object.assign module.exports, { Clock }