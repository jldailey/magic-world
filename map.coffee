sampleMap = """
GGGGGGGGGGgrrgGGGGGG
GGGGGGGGGGgrrgGGGGGG
GGGGtGGGGgrRrgGGGGGG
GGGGGGGGgrRrgGGGGGGG
GGGGGGGGgrRrgGGGGGGG
GGGGGGTGgrRrgGGGGGGG
GGGGGGGGGgrRrgGGGGGG
GGGGGGGGGggrrgGGGGGG
ggggggggggrrrggggggg
SSSSSSSSSSrSSSSSSSSS
ssssssssssssssssssss
wwwwwwwwwwwwwwwwwwww
WWWWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWWWW
"""

colors = {
	g: '#9c9'
	G: '#8c8'
	r: '#cc9'
	R: '#bb8'
	S: '#ffc'
	s: '#dde'
	w: '#88b'
	W: '#448'
}

tiles = {
	g: (context, x, y, tw, th) ->
		context.drawRect x, y, tw, th, colors.g
	G: (context, x, y, tw, th) ->
		context.drawRect x, y, tw, th, colors.G
	r: (context, x, y, tw, th) ->
		context.drawRect x, y, tw, th, colors.r
	R: (context, x, y, tw, th) ->
		context.drawRect x, y, tw, th, colors.R
	S: (context, x, y, tw, th) ->
		context.drawRect x, y, tw, th, colors.S
	s: (context, x, y, tw, th) ->
		context.drawRect x, y, tw, th, colors.s
	w: (context, x, y, tw, th) ->
		context.drawRect x, y, tw, th, colors.w
	W: (context, x, y, tw, th) ->
		context.drawRect x, y, tw, th, colors.W
	t: (context, x, y, tw, th) ->
		context.drawRect x, y, tw, th, colors.G
		context.drawImage treeSprites, treeSprites.t..., x, y, tw, th
	T: (context, x, y, tw, th) ->
		context.drawRect x, y, tw, th, colors.G
		context.drawImage treeSprites, treeSprites.T..., x, y, tw, th
}


drawTile = (context, type, x, y, tw, th) ->
	console.log 'tile', type, x, y, tw, th
	tiles[type]?(context, x, y, tw, th)

window.drawMap = (context, map, w, h, tw, th) ->
	context.fillStyle = 'lightgray'
	context.fillRect 0, 0, w, h
	for i in [0...w/tw] by 1
		for j in [0...h/th] by 1
			tile = map[j][i]
			drawTile context, tile, i*tw, j*th, tw, th

window.initMap = (map, tw, th) ->
	map = $(map.split /\n/).filter('', false).map (row) -> row.split ''
	w = map[0].length * tw
	h = map.length * th
	canvas = $.synth("canvas[width=#{w}][height=#{h}]").appendTo('body').first()
	context = canvas.getContext('2d')
	context.drawRect = (x, y, w, h, color) ->
		context.fillStyle = color
		context.fillRect x, y, w, h
	drawMap context, map, w, h, tw, th

treeSprites = $.extend new Image(),
	t: [0, 16, 16, 16]
	T: [32, 32, 16, 16]
	src: "./textures/tree-sprites-64-64.png"
	onload: ->
		initMap sampleMap, 16, 16
