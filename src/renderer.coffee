

module.exports.compile = (src) ->
	code = """
		var pp = 2*Math.PI;
		c.save();
		c.rotate(r);
		c.translate(x,y);
		c.scale(1+z);
		
	"""
	for op in src.replace(/\r|\n/g,' ').split(/ +/) then switch
		when op is "bp" then code += "c.beginPath();"
		when op is "cp" then code += "c.closePath();"
		when op is "s!" then code += "c.stroke();"
		when op is "f!" then code += "c.fill();"
		when op is "cr" then code += "c.arc(0,0,r,0,pp);"
		when (m = op.match /s!([a-zA-Z]+)*,*(#[a-fA-F0-9]{6})*,*([0-9.]*)/)
			if m[3]?.length > 0
				code += "c.lineWidth = #{m[3]};"
			if (ss = m[2] ? m[1])?.length > 0
				code += "c.strokeStyle = '#{ss}';"
			code += "c.stroke();"
		when (m = op.match /m([0-9.-]+),([0-9.-]+)/)
			code += "c.moveTo(#{m[1]},#{m[2]});"
		when (m = op.match /l([0-9.-]+),([0-9.-]+)/)
			code += "c.lineTo(#{m[1]},#{m[2]});"
		else console.warn "undefined op: '#{op}'"
	code += "c.restore()"
	return new Function "c", "x", "y", "z", "r", "ent", code


if require.main is module
	console.log [
		"s!black,2"
		"s!#000000,2"
		"s!black"
		"s!2"
	].map(module.exports.compile).map(String)