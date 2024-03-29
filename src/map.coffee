$ = require 'bling'

#include "defines.h"

islandMap = """
	W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W.
	W. w1 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w3 W. W. w1 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w3 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w7 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w9 W. W. w7 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w9 W.
	W. w0 w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w+ W. W. w0 w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w+ W.
	W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W.
	W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W.
	W. w1 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w3 W. W. w1 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w3 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w7 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w9 W. W. w7 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w9 W.
	W. w0 w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w+ W. W. w0 w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w+ W.
	W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W.
	W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W.
	W. w1 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w3 W. W. w1 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w3 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w7 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w9 W. W. w7 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w9 W.
	W. w0 w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w+ W. W. w0 w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w+ W.
	W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W.
	W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W.
	W. w1 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w3 W. W. w1 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w2 w3 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W. W. w4 g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. g. w6 W.
	W. w7 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w9 W. W. w7 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w8 w9 W.
	W. w0 w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w+ W. W. w0 w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w- w+ W.
	W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W. W.
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
		macro = parseTileGridString macros[macro]
		for j in [0...macro.length] by 1
			for i in [0...macro[j].length] by 1
				try map.data[ty+j][tx+i] = macro[j][i]
	else
		layer = new TileLayer macro, tx, ty, 32, 32, macros[macro]
		map.addLayer layer
	null

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

floor = Math.floor
ceil = Math.ceil

window.cacheImageData = (src, cb) ->
	$.extend m = new Image(),
		src: $.log "Caching image data from...", src
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
				(@row(y).join(' ') for y in [0...Math.min 4, @h] by 1).join '\n'
		}
	@parse: (str) ->
		lines = $(str.split /\n/).filter('', false)
		grid = new Grid lines[0].length, lines.length
		for y in [0...lines.length] by 1
			for x in [0...lines[y].length] by 1
				grid.set(x,y,lines[y][x])
		grid

Rect = (x,y,w,h) -> return $.extend [x,y,w,h], {x,y,w,h}

class Layer
	constructor: (@name, @dx, @dy) ->
	log: (msg...) -> $.log "[layer:#{@name}]", msg...
	draw: (map) ->
	redraw: (map) ->
	dirty: (x,y,w,h) ->
	toString: -> "[layer:#{@name}] at #{@dx},#{@dy} #{@w}x#{@h}"

class TileLayer extends Layer
	constructor: (@name, @dx, @dy, @tw, @th, data) ->
		@data = if $.is 'string', data then parseTileGridString data else data
		@w = @data[0].length * @tw
		@h = @data.length * @th
		# @log "creating...", @data[0].length,"x",@data.length,@w,"x",@h
		@dirty_stack = []
		@log "creating TileLayer", @name, @dx, @dy, @w, @h, data
	log: (msg...) -> $.log "[tileset:#{@name}]", msg...
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
		@log "redrawing dirty tiles..."
		di = floor (@dx / @tw)
		dj = floor (@dy / @th)
		while pair = @dirty_stack.shift()
			[ti, tj] = pair
			# @log "drawing dirty tile", ti, tj
			map.drawType @data[tj-dj][ti-di], ti, tj
		null
	dirty: (x, y, w, h) ->
		tx = floor (x / @tw)
		ty = floor (y / @th)
		dx = ceil  (w / @tw)
		dy = ceil  (h / @th)
		lx = floor (@dx / @tw)
		rx = floor ((@dx + @w) / @tw)
		uy = ceil  (@dy / @th)
		ly = ceil  ((@dy + @h) / @th)
		for ti in [tx..tx+dx] by 1
			for tj in [ty..ty+dy] by 1
				# @log lx,'<=',ti,'<',rx,'and',uy,'<=',tj,'<',ly
				if (lx <= ti < rx and uy <= tj < ly)
					# @log "marking [#{ti},#{tj}] as dirty"
					@dirty_stack.push [ti, tj]
		return @dirty_stack.length > 0

class TileGrid
	constructor: (@tileset, @w, @h, @tw, @th) ->
		@dirty_stack = []
		@layers = []
		@canvas = $.synth("canvas[width=#{@w}][height=#{@h}]").appendTo('body')
		$.extend @context = @canvas.first().getContext('2d'),
			drawRect: (x, y, w, h, color) ->
				@fillStyle = color
				@fillRect x, y, w, h
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
		@context.beginPath()
		for _x in [x...x+w] by @tw
			@context.moveTo _x, y
			@context.lineTo _x, y+h
		for _y in [y...y+h] by @th
			@context.moveTo x, _y
			@context.lineTo x+w, _y
		@context.strokeStyle = "rgba(0,0,0,.3)"
		@context.stroke()
		@context.closePath()
	dirtyTile: (tx, ty) ->
		@dirty_stack.push [ tx, ty, @tw, @th ]
		@redraw()
	dirty: (x, y, w, h) ->
		@dirty_stack.push [ x, y, w, h ]
		@redraw()
	redraw: $.debounce 17, ->
		dirty_layers = []
		while @dirty_stack.length > 0
			[x, y, w, h] = @dirty_stack.pop()
			for layer in @layers
				if layer.dirty x, y, w, h
					dirty_layers.push layer
		for layer in dirty_layers
			layer.redraw @
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
	draw: (context, symbol, dx, dy) ->
		if @tiles[symbol]?.length > 0
			tile = @tiles[symbol]
			args = [
				tile[0],
				tile[1],
				tile[2],
				tile[3],
				dx + tile[4] + (@tw * (1 - tile[6]) / 2),
				dy + tile[5] + (@th * (1 - tile[7]) / 2),
				@tw * tile[6],
				@th * tile[7]
			]
			context.drawImage @image, args...
	
class Sprite
	constructor: (@tileset, @name, @frame_dur, @poses) ->
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
		symbol = ""+@prefix+@poseIndex+@frame_index
		@tileset.draw context, symbol, dx, dy
	setPose: (@poseIndex) ->
		@frame_index = 0
	register: (prefix) ->
		@prefix = prefix
		for p, u of @poses
			@tileset.register prefix+p, u[0]
			for v,i in u
				@tileset.register prefix+p+i, v

cacheImageData "./textures/tiles.png", (err, image) ->
	if err
		return console.error err

	$.log "Creating new tileset..."
	tileset = new TileSet(image, 32, 32)

	$.log "Defining 'trees'..."
	tileset.register 't', trees = {
		1: [  0,   0, 64, 64, 0, -18, 2, 2]
		2: [592, 112, 64, 64, 0, -17, 1.9, 1.9]
	}

	$.log "Defining edges..."
	edges = { # this is a repeated layout used in the sprite
		1:   [ 0,  0, 0, 0, 0, 0, 0, 0]
		2:   [16,  0, 0, 0, 0, 0, 0, 0]
		3:   [32,  0, 0, 0, 0, 0, 0, 0]
		4:   [ 0, 16, 0, 0, 0, 0, 0, 0]
		5:   [16, 16, 0, 0, 0, 0, 0, 0]
		'.': [16, 16, 0, 0, 0, 0, 0, 0] # allow a low-profile alias for more readbale maps
		6:   [32, 16, 0, 0, 0, 0, 0, 0]
		7:   [ 0, 32, 0, 0, 0, 0, 0, 0]
		8:   [16, 32, 0, 0, 0, 0, 0, 0]
		9:   [32, 32, 0, 0, 0, 0, 0, 0]
		'0': [ 0, 48, 0, 0, 0, 0, 0, 0]
		'-': [16, 48, 0, 0, 0, 0, 0, 0]
		'+': [32, 48, 0, 0, 0, 0, 0, 0]
	}
	register_edge = (symbol, offset) ->
		for edge, v of edges
			tileset.register symbol+edge, $(v).plus(offset).toArray()
	register_edge 'd', [528, 272, 16, 16, 0, 0, 1, 1] # dirt
	register_edge 'g', [528, 341, 16, 16, 0, 0, 1, 1] # grass
	register_edge 'w', [161, 465, 15, 15, 0, 0, 1, 1] # grass_coast
	# register_edge 'k', [160, 529, 0, 0, 0, 0, 1, 1] # grass_cliff
	register_edge 'W', [  0, 688, 17, 17, 0, 0, 1, 1] # underwater
	register_edge 'o', [810,   0, 16, 16, 0, 0, 1, 1] # stone wall
	register_edge 'O', [809, 240, 16, 16, 0, 0, 1, 1] # sand stone wall
	register_edge '*', [597, 470, 16, 16, 0, 0, 1, 1] # iceball
	register_edge '+', [645, 470, 16, 16, 0, 0, 1, 1] # fireball
	register_edge 'f', [703, 311, 16, 16, 0, 0, 1, 1] # wooden fence
	register_edge 'F', [703, 247, 16, 16, 0, 0, 1, 1] # picket fence

	# heavy grass
	tileset.register 'GG', [528, 80, 48, 48, 0, 0, 1, 1]

	# the no-op tile
	tileset.register 'nn', [0,0,0,0,0,0,1,1]

	$.log "Defining corners..."
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
	register_corner 'C', [ 560, 323, 0, 0 ]


	new Sprite(tileset, 'baller', 100, {
		2: [
			[ 641, 730, 64, 64 ],
			[ 711, 730, 64, 64 ],
			[ 775, 730, 64, 64 ],
			[ 839, 730, 64, 64 ]
		]
		8: [
			[ 641, 530, 64, 64 ],
			[ 711, 530, 64, 64 ],
			[ 775, 530, 64, 64 ],
			[ 839, 530, 64, 64 ]
		]
	}).register('b')

	# football player: [ 645, 529, 64, 64 ], 4x4x64 grid

	# lamp post
	tileset.register 'lp', [ 690, 194, 48, 48, 0, -16, 2, 2 ]
	tileset.register 'l0', [ 690, 194, 48, 48, 0, -16, 2, 2 ]
	tileset.register 'l1', [ 743, 194, 48, 48, 0, -16, 2, 2 ]

	if err then console.error err
	else
		window.map = new TileGrid(tileset, window.innerWidth, window.innerHeight, 32, 32)
		window.map.context.imageSmoothingEnabled = false
		window.map.addLayer new TileLayer 'islandMap', 0, 0, 32, 32, islandMap
		window.map.addLayer new TileLayer 'twoTrees', 32, 32, 32, 32, """t1 t2"""
		window.map.addLayer new TileLayer 'frostBalls', 32*3, 32*2, 32, 32, """
			f1 f2 f3
			f4 l0 f6
			f7 f8 f9
		"""
		window.map.addLayer new TileLayer 'fireBalls', 32*5, 32*2, 32, 32, """
			F1 F2 F3
			F4 l1 F6
			F7 F8 F9
		"""
		window.map.addLayer new TileLayer '*s', 32*7, 32*2, 32, 32, """
			*1 *2 *3
			*4 *5 *6
			*7 *8 *9
		"""
		window.map.addLayer new TileLayer '+s', 32*9, 32*2, 32, 32, """
			+1 +2 +3
			+4 +5 +6
			+7 +8 +9
		"""
		window.map.addLayer new TileLayer 'baller', 32*5, 32*4, 32, 32, """
			b20 b21 b22 b23
			b80 b81 b82 b83
		"""
		window.map.draw()
		# draw a blemish
		map.context.drawRect 10, 10, 4, 4, 'blue'
		# then use it to test our dirty() redraw mechanism
		map.canvas.bind 'click', (evt) ->
			x = evt.clientX + window.scrollX - 48
			y = evt.clientY + window.scrollY - 48
			w = 96
			h = 96
			map.context.drawRect x,y,w,h,'rgba(0,0,255,.3)'
			map.dirty x,y,w,h
