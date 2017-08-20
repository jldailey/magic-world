{ compile } = require "../lib/renderer"
{ pow, PI } = Math
TWOPI = 2*PI

_wrap = (x, lo, hi) ->
	x += (hi - lo) while x < lo
	x -= (hi - lo) while x > hi
	x
	
#include "defines.h"

class Ent # any dynamic entity located in the world
	# attach ourselves into the entity chain
	spawnAfter: (@prevEnt) ->
		@nextEnt = @prevEnt.nextEnt
		@prevEnt.nextEnt = @
	despawn: ->
		@prevEnt? and @prevEnt.nextEnt = @nextEnt
		@prevEnt = @nextEnt = null
		@
	Ent.friction = .01 # percent velocity decay per ms
	
	constructor: (@id = "ent-"+$.random.string 8) ->
		# link into the global entity chain
		@prevEnt = @nextEnt = null
		@x = new Float64Array(4)
		@v = new Float64Array(4)
		@showAxis = false
	
	tick: (dt) ->
		{x,v} = @
		for i in [0...x.length] by 1
			x[i] += v[i]
		VEC_SCALE(v, Ent.friction)
		@
	
	# pre-compile a rendering function
	renderAxis = compile "bp m0,10 l2,8 m0,10 l-2,8 m0,10 l0,0 l10,0 s!#000000,2 cp"

	draw: (context, layerName) ->
		[x,y,z,r] = @x
		if @showAxis
			context.lineWidth = 2
			context.strokeStyle = 'black'
			renderAxis(context, x, y, z, r)
		@

Object.assign module.exports, { Ent }