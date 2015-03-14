Chalk = require 'chalk'
colors = {
	'heal'    : Chalk.green
	'fire'    : Chalk.red
	'(fire)'  : Chalk.red
	'arcane'  : Chalk.bold.blue
	'(arcane)': Chalk.bold.blue
	'ice'     : Chalk.blue
	'(ice)'   : Chalk.blue
	'burn'    : Chalk.red
	'(burn)'  : Chalk.red
	'burning' : Chalk.red
	'speed'   : Chalk.yellow
	'damage'  : Chalk.red
	'armor'   : Chalk.blue
	'self'    : Chalk.magenta
	'target'  : Chalk.magenta
	'area'    : Chalk.magenta
	'dir'     : Chalk.magenta
	'force'   : Chalk.yellow
	'to'      : Chalk.gray
	'for'     : Chalk.gray
	'over'    : Chalk.gray
	'on'      : Chalk.gray
	'with'    : Chalk.gray
	'head'    : Chalk.underline
	'left'    : Chalk.underline
	'right'   : Chalk.underline
	'hand'    : Chalk.underline
	'hands'   : Chalk.underline
	'arm'     : Chalk.underline
	'arms'    : Chalk.underline
	'leg'     : Chalk.underline
	'legs'    : Chalk.underline
}
module.exports = (s) ->
	s.split(' ').map((w) ->
		colors[w.toLowerCase()]?(w) or w
	).join ' '
