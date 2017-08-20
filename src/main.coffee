$ = require 'bling'

{ Clock } = require "../lib/time"
{ Ent } = require "../lib/ent"

class MyEnt extends Ent
	tick: (dt) ->
		dt = (if dt >= 0 then "+" else "") + dt
		console.log "[#{dt} Now: #{clock.toString()}]", @id, @x[0], @x[1]

class Context
	constructor: (@name) ->
	clear: -> $.log "Clearing layer:", @name

class Game extends Ent
	constructor: ->
		super()
		@clock = new Clock (dt) => @tick(dt)
		@layers = {
			ground: new Context 'ground'
			shadows: new Context 'shadows'
			entities: new Context 'entities'
			overlay: new Context 'overlay'
		}
	tick: (dt) ->
		ent = @
		while ent = ent.nextEnt
			ent.tick dt
		@
	draw: ->
		for name,layer in @layers
			layer.clear() # for now, re-draw everything every time
		ent = @
		while ent = ent.nextEnt
			ent.drawShadows @layers.shadows
			ent.draw @layers.entities
			ent.drawOverlay @layers.overlay
		@

game = new Game()

game.clock.start()
$.delay 1000, -> game.clock.stop()