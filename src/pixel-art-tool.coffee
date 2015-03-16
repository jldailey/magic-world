
pixelArtTool = (src, tw, th, cb) ->
	htw = tw << 1
	hth = th << 1
	$.extend m = new Image(),
		src: src
		onload: ->
			$.synth("style '#pa_status { position: fixed; top: 0; right: 12px; background: transparent; }'").appendTo "head"
			$.synth("style '#pa_canvas { cursor: crosshair; background: transparent; }'").appendTo "head"
			$.synth("style 'body, canvas { padding: 0; margin: 0 } #pa_preview { border: 1px solid black; position: fixed; top: 1.1em; right: 12px; background: transparent; }'").appendTo "head"
			canvas = $.synth("canvas#pa_canvas[width=#{m.width}][height=#{m.height}]").appendTo "body"
			context = canvas.first().getContext('2d')
			context.drawImage m, 0, 0, m.width, m.height
			statusCanvas = $.synth("canvas#pa_preview[width=#{htw}][height=#{hth}]").appendTo("body")
			statusDiv = $.synth("div#pa_status '[0,0,0,0]'").appendTo("body").click toggle = ->
				canvas.toggle()
				statusCanvas.toggle()
			sContext = statusCanvas.first().getContext('2d')
			toolX = 0
			toolY = 0
			toolW = 0
			toolH = 0
			clamp = (min, max) -> (x) -> Math.max min, Math.max min, x
			clampW = clamp(1, htw)
			clampH = clamp(1, hth)
			updateStatus = ->
				statusDiv.text "[#{toolX}, #{toolY}, #{toolW}, #{toolH}]"
				sContext.clearRect 0, 0, htw, hth
				if boxMode
					imageData = context.getImageData toolX, toolY, clampW(toolW), clampH(toolH)
				else
					imageData = context.getImageData toolX-tw, toolY-th, htw, hth
				sContext.putImageData imageData, 0, 0, 0, 0, htw, hth
				if not boxMode # draw a crosshair
					sContext.strokeStyle = 'rgba(0,0,0,0.5)'
					sContext.lineWidth = 1
					crosshair = 8
					sContext.moveTo tw-crosshair, th
					sContext.lineTo tw+crosshair, th
					sContext.moveTo tw, th-crosshair
					sContext.lineTo tw, th+crosshair
					sContext.stroke()


			boxMode = false
			canvas.bind 'mousemove', (evt) ->
				evtX = (evt.clientX + window.scrollX - evt.target.offsetLeft)
				evtY = (evt.clientY + window.scrollY - evt.target.offsetTop)
				if boxMode
					toolW = evtX - toolX
					toolH = evtY - toolY
				else
					toolX = evtX
					toolY = evtY
				updateStatus()

			canvas.bind 'mousedown', ->
				if boxMode = !boxMode
					updateStatus()

			prevScrollX = 0
			prevScrollY = 0
			$([window, document]).bind 'scroll', (evt) ->
				dy = evt.pageY - prevScrollY
				dx = evt.pageX - prevScrollX
				prevScrollX = evt.pageX
				prevScrollY = evt.pageY
				toolY += dy
				toolX += dx
				updateStatus()
			
			toggle()

			cb? null, canvas, context
		onerror: (err) -> console.error err

$(document).ready ->
	pixelArtTool "./textures/tiles-tr2.png", 32, 32, ->

