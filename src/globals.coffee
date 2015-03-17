$ = require 'bling'
$.extend module.exports, {
	empty_array: Object.freeze []
	empty_object: Object.freeze Object.create null
	empty_string: ''
	empty_bling: Object.freeze $ []
	empty_zeros: Object.freeze $ [0, 0, 0]
}
