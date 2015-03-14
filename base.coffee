module.exports = class Base
	@has = (f) -> f.call @::, @::
