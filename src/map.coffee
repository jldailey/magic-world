$ = require 'bling'

#include "defines.h"

islandMap = """
W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W.
W. w1 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w3 W.
W. w4 g. g. g. C4 g8 g8 C3 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
W. w4 g. g. g. g6 d1 d3 g4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
W. w4 g. g. C4 g9 d4 d6 g4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
W. w4 g. g. g6 d1 c1 d6 g4 g. g. C4 g8 g8 g8 g8 g8 g8 g8 C3 g. g. g. g. w6 W.
W. w4 g. g. g6 d4 d. d6 g4 g. g. g6 d1 d2 d2 d2 d2 d2 d3 g4 g. g. g. g. w6 W.
W. w4 g. g. g6 d4 c4 d9 g4 g. g. g6 d4 c4 d8 d8 d8 c3 d6 g4 C4 g8 g8 C3 w6 W.
W. w4 g. g. g6 d4 d6 g1 C1 g. g. g6 d4 d6 g1 g2 g3 d4 d6 g4 g6 d1 d3 g4 w6 W.
W. w4 g. g. g6 d4 d6 g4 g. g. g. g6 d4 d6 g4 g. g6 d4 d6 g7 g9 d4 d6 g4 w6 W.
W. w4 g. g. g6 d4 d6 g7 g8 g8 g8 g9 d4 d6 g4 g. g6 d4 c2 d2 d2 c1 d6 g4 w6 W.
W. w4 g. g. g6 d4 c2 d2 d2 d2 d2 d2 c1 d6 g4 g. g6 d7 d8 d8 d8 d8 d9 g4 w6 W.
W. w4 g. g. g6 d7 d8 d8 d8 d8 d8 d8 d8 d9 g4 g. C2 g2 g2 g2 g2 g2 g2 C1 w6 W.
W. w4 g. g. C2 g2 g2 g2 g2 g2 g2 g2 g2 g2 C1 g. g. g. g. g. g. g. g. g. w6 W.
W. w7 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w9 W.
W. w0 w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w+ W.
W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W.
"""

macros = {
	"road-w-e": """
		g8 g8 g8 g8
		d2 d2 d2 d2
		d8 d8 d8 d8
		g2 g2 g2 g2
	"""
	"road-w-n": """
		g9 d4 d6 g4
		d2 c1 d6 g4
		d8 d8 d9 g4
		g2 g2 g2 C1
	"""
	"road-w-s": """
		g8 g8 g8 C3
		d2 d2 d3 g4
		d8 c3 d6 g4
		g3 d4 d6 g4  
	"""
	"road-e-n": """
		g6 d4 d6 g7
		g6 d4 c2 d2
		g6 d7 d8 d8
		C2 g2 g2 g2
	"""
	"road-e-s": """
		C4 g8 g8 g8
		g6 d1 d2 d2
		g6 d4 c4 d8
		g6 d4 d6 g1
	"""
}
insertMacro = (map, macro, tx, ty, layer=false) ->
	if not layer
		macro = parseTileGridString macro
		for j in [0...macro.length] by 1
			for i in [0...macro[j].length] by 1
				try map.data[ty+j][tx+i] = macro[j][i]
	else
		layer = new Layer tx, ty, 32, 32, macro
		map.addLayer layer

parseTileGridString = (str) ->
	$(str.split /\n/).filter('', false).map((row) -> row.split /\s+/).filter('', false)

colors = {
	g: '#9c9'
	G: '#6a6'
	r: '#cc9'
	R: '#bb8'
	S: '#ffc'
	s: '#dde'
	w: '#88b'
	W: '#448'
}

window.cacheImageData = (src, cb) ->
	$.log "Caching image data from...", src
	$.extend m = new Image(),
		src: src
		onload:      -> cb null, m
		onerror: (e) -> cb e, null

class Grid
	constructor: (@w, @h) ->
		data = new Array(@w * @h)
		$.extend @, {
			get: (i, j) ->
				data[i + j * @w]
			set: (i, j, v) ->
				data[i + j * @w] = v
			col: (x) ->
				data[x + y * @w] for y in [0...@h] by 1
			row: (y) ->
				data[x + y * @w] for x in [0...@w] by 1
			toString: ->
				(@row(y).join(' ') for y in [0...@h] by 1).join '\n'
		}
	@parse: (str) ->
		lines = $(str.split /\n/).filter('', false)
		grid = new Grid lines[0].length, lines.length
		for y in [0...lines.length] by 1
			for x in [0...lines[y].length] by 1
				grid.set(x,y,lines[y][x])
		grid

Rect = (x,y,w,h) -> return $.extend [x,y,w,h], {x,y,w,h}

"""
class Layer
	constructor: (@rect, @tileset, data) ->
		@grid = Grid.parse data
		@layers = $()
	tick: (dt) ->
	draw: (context) ->
		@layers.select('draw').call(context)
	addLayer: (layer) -> @layers.push layer
	removeLayer: (layer) ->
		@layers.splice i, 1 unless ~(i = @layers.indexOf layer)
	dirty: (x, y, w, h) ->
"""
		

class Layer
	constructor: (dx, dy, @tw, @th, data) ->
		@data = if $.is 'string', data then parseTileGridString data else data
		@x = dx
		@y = dy
		@w = @data[0].length * @tw
		@h = @data.length * @th
		@dirty_stack = []
		$.log "creating Layer", @x, @y, @w, @h, data
	draw: (map) ->
		for i in [@x...@x+@w] by @tw
			for j in [@y...@y+@h] by @th
				$.log "drawing", i, j
				tx = Math.floor (i/@tw) - (@x/@tw)
				ty = Math.floor (j/@th) - (@y/@th)
				map.drawTile @data[ty][tx], @x+(tx*@tw), @y+(ty*@th), @tw, @th
	redraw: (map) ->
		while pair = @dirty_stack.shift()
			[i, j] = pair
			tx = Math.floor (i/@tw) - (@x/@tw)
			ty = Math.floor (j/@th) - (@y/@th)
			$.log "drawing (dirty)", i, j, tx, ty,
			map.drawTile @data[ty][tx], @x+(tx*@tw), @y+(ty*@th), @tw, @th
	dirty: (x, y, w, h) ->
		for i in [x...x+w] by @tw
			for j in [y...y+h] by @th
				if (@x < i < @x+@w and @y < j < @y+@h)
					@dirty_stack.push [i, j]
					break
		return @dirty_stack.length > 0


class TileGrid
	constructor: (data, @image, @tileset, @tw, @th) ->
		@data = if $.is 'string', data then parseTileGridString data else data
		@w = @data[0].length * @tw
		@h = @data.length * @th
		@dirty_stack = []
		@layers = []
		@canvas = $.synth("canvas[width=#{@w}][height=#{@h}]").appendTo('body')
		$.extend @context = @canvas.first().getContext('2d'),
			drawRect: (x, y, w, h, color) ->
				@fillStyle = color
				@fillRect x, y, w, h
	addLayer: (layer) ->
		@layers.unshift layer
		@
	drawTile: (type, x, y, tw, th) ->
		$.log "drawTile", type, x, y, tw, th
		if type of colors
			$.log "drawColor", colors[type]
			@context.drawRect x, y, tw, th, colors[type]
		@tileset.draw @context, type, x, y, tw, th
	draw: ->
		start = $.now
		[w, h, tw, th] = [@w, @h, @tw, @th]
		$.log "filling primer color"
		@context.fillStyle = '#ba8'
		@context.fillRect 0, 0, w, h
		$.log "drawing base tiles"
		for i in [0...w/tw] by 1
			for j in [0...h/th] by 1
				symbol = @data[j][i]
				# @tileset.draw(@context, symbol, i, j)
				@drawTile symbol, i*@tw, j*@th, @tw, @th
		for layer in @layers
			$.log "drawing layer..."
			layer.draw(@)
		$.log "frame time:", ($.now - start)
		@
	dirtyTile: (tx, ty) ->
		@dirty_stack.push [ tx, ty, @tw, @th ]
		@redraw()
	dirty: (x, y, w, h) ->
		@dirty_stack.push [ x, y, w, h ]
		@redraw()
	redraw: $.debounce 33, ->
		dirty_layers = []
		while @dirty_stack.length > 0
			[i, j, w, h] = @dirty_stack.pop()
			for x in [i...i+w] by @tw
				for y in [j...j+h] by @th
					tx = Math.floor x/@tw
					ty = Math.floor y/@th
					@drawTile @data[ty][tx], tx*@tw, ty*@th, @tw, @th
			for layer in @layers
				if layer.dirty i, j, w, h
					dirty_layers.push layer
		for layer in dirty_layers
			layer.redraw @
		@

cacheImageData "./textures/tiles-tr2.png", (err, image) ->
	if err
		return console.error err

	class TileSet
		constructor: (@tw, @th) ->
			@tiles = Object.create null
		register: (prefix, poses) ->
			switch $.type poses
				when "object"
					for p,v of poses
						$.log "Registering pose:", prefix+p, v
						@tiles[prefix+p] = v
				when "array","bling"
					$.log "Registering pose:", prefix, poses
					@tiles[prefix] = poses
				else $.log "Failed to load unknown type: ", $.type poses
			@
		draw: (context, symbol, dx, dy) ->
			if @tiles[symbol]?.length > 0
				context.drawImage image, @tiles[symbol]..., dx, dy, @tw, @th
	
	$.log "Creating new tileset..."
	tileset = new TileSet(32, 32)

	$.log "Loading 'trees'..."
	tileset.register 't', trees = {
		1: [1, 1, 64, 64]
		2: [592, 112, 64, 64]
	}

	$.log "Defining edges..."
	edges = { # this is a repeated layout used in the sprite
		1:   [ 0,  0, 16, 16]
		2:   [16,  0, 16, 16]
		3:   [32,  0, 16, 16]
		4:   [ 0, 16, 16, 16]
		5:   [16, 16, 16, 16]
		'.': [16, 16, 16, 16] # allow a non-descript alias for more readbale maps
		6:   [32, 16, 16, 16]
		7:   [ 0, 30, 16, 16]
		8:   [16, 30, 16, 16]
		9:   [32, 30, 16, 16]
		'0': [ 0, 47, 16, 16]
		'-': [16, 48, 15, 16]
		'+': [32, 48, 16, 16]
	}
	register_edge = (symbol, offset) ->
		for edge, v of edges
			tileset.register symbol+edge, $(v).plus(offset).toArray()
	$.log "Loading edges..."
	register_edge 'd', [528, 273, 0, 0] #dirt
	register_edge 'g', [528, 337, 0, 0] # grass
	register_edge 'w', [160, 464, 0, 0] # grass_coast
	# register_edge 'k', [160, 529, 0, 0] # grass_cliff
	register_edge 'W', [0, 688, 1, 1] # underwater
	register_edge 'o', [810, 0, 0, 0] # stone wall
	register_edge 'O', [809, 240, 0, 0] # sand stone wall
	register_edge 'f', [597, 470, 0, 0] # fireball

	# heavy grass
	tileset.register 'GG', [528, 80, 48, 48]

	# the no-op tile
	tileset.register 'nn', [0,0,0,0]

	$.log "Loading corners..."
	corners = { # the standard inner-corner layout
		1: [ 0.5, 0.5, 13, 13 ]
		2: [ 2.5, 0.5, 13, 13 ]
		3: [ 0.5, 2.5, 13, 13 ]
		4: [ 2.5, 2.5, 13, 13 ]
	}
	register_corner = (symbol, offset) ->
		for corner, v of corners
			tileset.register symbol+corner, $(v).plus(offset).toArray()
	register_corner 'c', [ 575, 257, 0, 0 ]
	register_corner 'C', [ 560, 320, 0, 0 ]

	class Sprite
		constructor: (@name, @frame_dur, @poses) ->
			$.assert @frame_dur > 0, "negative frame duration not allowed"
			@tx = @ty = 0
			@frame_left = @frame_dur
			@frame_index = 0
			@paused = false
		pause: -> @paused = true
		resume: -> @paused = false
		tick: (dt) ->
			return if @paused
			@frame_left -= dt
			while @frame_left <= 0
				@frame_left += @frame_dur
				@frame_index = (@frame_index + 1) % @poses[@poseIndex].length
		draw: (context, dx, dy) ->
			symbol = @prefix+@poseIndex+@frame_index
			tileset.draw context, symbol, dx, dy
		setPose: (@poseIndex) ->
		register: (prefix, tileset) ->
			@prefix = prefix
			for p, u of @poses
				tileset.register prefix+p, u[0]
				for v,i in u
					tileset.register prefix+p+i, v

	$.log "Loading blueman..."
	new Sprite('blueman', 100, {
		2:   [ [257, 531, 32, 32],[289, 531, 32, 32],[321, 531, 32, 32] ]
		4:   [ [257, 563, 32, 32],[289, 563, 32, 32],[321, 563, 32, 32] ]
		6:   [ [257, 595, 32, 32],[289, 595, 32, 32],[321, 595, 32, 32] ]
		8:   [ [257, 627, 32, 32],[289, 627, 32, 32],[321, 627, 32, 32] ]
	}).register('p', tileset)

	# football player: [ 645, 529, 64, 64 ], 4x4x64 grid

	# lamp post
	tileset.register 'lp', [ 777, 192, 32, 48 ]

	if err then console.error err
	else
		window.map = new TileGrid(islandMap, image, tileset, 32, 32)
		window.map.addLayer new Layer 100, 100, 32, 32, """t1 t2"""
		window.map.draw()
		# draw a blemish
		map.context.drawRect 10, 10, 4, 4, 'blue'
		# then use it to test our dirty() redraw mechanism
		map.canvas.bind 'click', (evt) ->
			x = evt.clientX + window.scrollX
			y = evt.clientY + window.scrollY
			map.dirty(x, y, 32, 32)
