$ = require 'bling'
$.extend module.exports, {
	empty_array: Object.freeze []
	empty_object: Object.freeze Object.create null
	empty_string: Object.freeze ''
	empty_bling: Object.freeze $ []
	empty_zeros: Object.freeze $ [0, 0, 0]
	immutable: (o) -> Object.freeze o
	getter: (o, name, prop, key) ->
		$.defineProperty o, name,
			get: -> @[prop][key]
}
