
class Layer
	constructor: (@name, @dx, @dy) ->
	log: (msg...) -> $.log "[layer:#{@name}]", msg...
	draw: (map) ->
	redraw: (map) ->
	dirty: (x,y,w,h) ->
	toString: -> "[layer:#{@name}] at #{@dx},#{@dy} #{@w}x#{@h}"

class TileLayer extends Layer
	constructor: (name, dx, dy, @tw, @th, data) ->
		super name, dx, dy
		@data = if $.is 'string', data then parseTileGridString data else data
		@w = @data[0].length * @tw
		@h = @data.length * @th
		# @log "creating...", @data[0].length,"x",@data.length,@w,"x",@h
		@dirtyQueue = new Queue()
		@log "creating TileLayer", @name, @dx, @dy, @w, @h, data
	draw: (map) ->
		di  = floor (@dx/@tw)
		din = di + floor (@w/@tw)
		dj  = floor (@dy/@th)
		djn = dj + floor (@h/@th)
		@log "drawing from",di,dj,"to",din,djn
		for ti in [di...din] by 1
			for tj in [dj...djn] by 1
				map.drawType @data[tj-dj][ti-di], ti, tj
		null
	redraw: (map) ->
		@log "redrawing dirty tiles...", @dirtyQueue.length
		di = floor (@dx / @tw)
		dj = floor (@dy / @th)
		while pair = @dirtyQueue.pop()
			[ti, tj] = pair
			if 0 <= tj-dj < @data.length
				if 0 <= ti-di < @data[tj-dj].length
					map.drawType @data[tj-dj][ti-di], ti, tj
		null
	dirty: (x, y, w, h) ->
		tx = floor (x / @tw)
		ty = floor (y / @th)
		dx = ceil  (w / @tw)
		dy = ceil  (h / @th)
		lx = floor (@dx / @tw) - 1
		rx = floor ((@dx + @w) / @tw) + 1
		uy = ceil  (@dy / @th) - 1
		ly = ceil  ((@dy + @h) / @th) + 1
		for ti in [tx..tx+dx] by 1
			for tj in [ty..ty+dy] by 1
				# @log lx,'<=',ti,'<',rx,'and',uy,'<=',tj,'<',ly
				if (lx <= ti < rx and uy <= tj < ly)
					@dirtyQueue.push [ti, tj]
		return @dirtyQueue.length > 0

class TileGrid
	constructor: (@tileset, @w, @h, @tw, @th) ->
		$.log "start of TileGrid constructor"
		@dirtyQueue = new Queue()
		@layers = []
		$.log "creating Canvas..."
		@canvas = $.synth("canvas[width=#{@w}][height=#{@h}]").appendTo('body')
		$.log "creating Context..."
		$.extend @context = @canvas.first().getContext('2d'),
			drawRect: (x, y, w, h, color) ->
				@fillStyle = color
				@fillRect x, y, w, h
				null
		$.log "end of TileGrid constructor", @dirtyQueue.length
	addLayer: (layer) ->
		@layers.push layer
		@
	drawType: (type, tx, ty) ->
		x = tx * @tw
		y = ty * @th
		if type[0] of colors
			@context.drawRect x, y, @tw, @th, colors[type]
		@tileset.draw @context, type, x, y, @tw, @th
		@
	draw: ->
		start = $.now
		[w, h, tw, th] = [@w, @h, @tw, @th]
		$.log "filling primer color"
		# @context.fillStyle = '#ba8'
		@context.fillStyle = 'red'
		@context.fillRect 0, 0, w, h
		for layer in @layers
			layer.draw(@)
		@drawRulerLines(0,0,w,h)
		$.log "frame time:", ($.now - start)
		@
	drawRulerLines: (x, y, w, h) ->
		c = @context
		c.beginPath()
		for _x in [x...x+w] by @tw
			c.moveTo _x, y
			c.lineTo _x, y+h
		for _y in [y...y+h] by @th
			c.moveTo x, _y
			c.lineTo x+w, _y
		c.strokeStyle = "rgba(0,0,0,.3)"
		c.stroke()
		c.closePath()
	dirtyTile: (tx, ty) ->
		@dirtyQueue.push [ tx, ty, @tw, @th ]
		@redraw()
	dirty: (x, y, w, h) ->
		@dirtyQueue.push [ x, y, w, h ]
		@redraw()
	redraw: $.debounce 17, ->
		dirty_layers = new Queue()
		while @dirtyQueue.length > 0
			[x, y, w, h] = @dirtyQueue.pop()
			for layer in @layers
				if layer.dirty x, y, w, h
					dirty_layers.push layer
		dirty_layers.each (layer) => layer.redraw @
		@

class TileSet
	constructor: (@image, @tw, @th) ->
		@tiles = Object.create null
	register: (prefix, poses) ->
		switch $.type poses
			when "object"
				for p,v of poses
					@tiles[prefix+p] = $.extend [0,0,@tw,@th,0,0,1,1], v
			when "array","bling"
				@tiles[prefix] = $.extend [0,0,@tw,@th,0,0,1,1], poses
			else $.log "Failed to load unknown type: ", $.type poses
		@
	scale = (a, b) ->
		try return c = []
		finally
			c.push(a[i]*b[i]) for i in [0...Math.min a.length, b.length] by 1
	origin: (symbol) ->
		@tiles[symbol]?.slice(0,4) ? [0,0,0,0]
	placement: (symbol, dx, dy) ->
		delta = @tiles[symbol]?.slice(4,8) ? [0,0,1,1]
		return [
			dx + delta[0] + (@tw * (1 - delta[2]) / 2), # if you make it wider, move it half that width back
			dy + delta[1] + (@th * (1 - delta[3]) / 2),
			@tw * delta[2],
			@th * delta[3]
		]
	draw: (context, symbol, dx, dy) ->
		if @tiles[symbol]?.length > 0
			context.drawImage @image, @origin(symbol)..., @placement(symbol, dx, dy)...
	
class Sprite
	constructor: (@tileset, @name, @frame_dur, @poses) ->
		$.assert @frame_dur > 0, "negative frame duration not allowed"
		@tx = @ty = 0
		@frame_left = @frame_dur
		@frame_index = 0
		@paused = false
	pause: -> @paused = true; @
	resume: -> @paused = false; @
	tick: (dt) ->
		return if @paused
		@frame_left -= dt
		while @frame_left <= 0
			@frame_left += @frame_dur
			@frame_index = (@frame_index + 1) % @poses[@poseIndex].length
		@
	draw: (context, dx, dy) ->
		@tileset.draw context, @getSymbol(), dx, dy
		@
	setPose: (@poseIndex) ->
		@frame_index = 0
		@
	getSymbol: -> ""+@prefix+@poseIndex+@frame_index
	register: (prefix) ->
		@prefix = prefix
		for p, u of @poses
			@tileset.register prefix+p, u[0]
			for v,i in u
				@tileset.register prefix+p+i, v
		@

class SpriteLayer extends TileLayer
	constructor: (sprite, dx, dy, tw, th) ->
		super sprite.name, dx, dy, tw, th, sprite.getSymbol()
		@sprite = sprite
		$.log "creating sprite layer:", @sprite.getSymbol()
	tick: (map, dt) ->
		before = @sprite.getSymbol()
		@sprite.tick dt
		after = @sprite.getSymbol()
		$.log "ticking sprite layer:", dt, before, after
		if before != after
			map.dirty @dx, @dy, @tw, @th
	draw: (map) ->
		$.log "drawing sprite layer"
		i = floor (@dx/@tw)
		j = floor (@dy/@th)
		map.drawType @sprite.getSymbol(), i, j
	redraw: (map) ->
		if @dirtyQueue.length > 0
			$.log "re-drawing sprite layer"
			# consume all of the dirtyQueue (it should only ever be our one sprite)
			while @dirtyQueue.pop()
				true
			@draw(map)
