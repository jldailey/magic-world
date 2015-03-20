$ = require 'bling'
$.extend module.exports, {
	empty_array: Object.freeze []
	empty_object: Object.freeze Object.create null
	empty_string: ''
	empty_bling: Object.freeze $ []
	empty_zeros: Object.freeze $ [0, 0, 0]
	Map: $.global.Map or Map
}

class Map
	constructor: ->
		data = Object.create null
		$.extend @,
			set: (k,v) -> data[k] = v
			get: (k) -> data[k]
			has: (k) -> k of data
			keys: -> Object.keys data
