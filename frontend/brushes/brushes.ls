Color = net.brehaut.Color

# This is the class upon which all other brushes are based
class Brush
	# Constructor
	(radius, color, canvas) ->
		@type = "default"
		@isTool = false
		@radius = radius
		@color = Color color
		@canvas = canvas
		@action_data = []
	
	# This sets us up for drawing, but doesn't clear action data
	# It is useful for redraws
	actionInit: (x,y) !->
		@canvas.context.moveTo x, y
		# Set the line's color from the brush's color
		@canvas.context.strokeStyle = @color.toCSS!
		
		# Start a new path, because we're on a new action
		@canvas.context.beginPath!
		
		# Set the line width from the brush's current radius
		@canvas.context.line-width = @radius

		# get rid of those nasty turns
		@canvas.context.line-join = @canvas.context.line-cap = 'round'
	
	# This sets us up for drawing and clears action data;
	# It is for starting a new actions
	actionStart: (x, y) !->
		# Clear action data
		@action_data = {brushtype:@type, radius:@radius, color:(@color.toCSS!), coords:[]}
		@actionInit x, y
		# console.log @action_data
		@action_data.coords.push [x, y]
	
	# Reset action data
	actionReset: !->
		@action_data = {brushtype:@type, radius:@radius, color:(@color.toCSS!), coords:[]}
	
	# End of an action; just closes the current path
	actionEnd: !->
		
		@canvas.context.closePath!
	
	# Process a single new coordinate
	actionMove: (x, y) !->
		unless @action_data.coords.length == 0
			@canvas.context.line-to x, y
			@canvas.context.stroke!
		else
			@actionInit x, y
		@action_data.coords.push [x, y]
	
	# Process a set of new coordinates
	actionProcessCoords: (data) !->
		for p in data.coords
			@canvas.context.line-to p[0], p[1]
			@action_data.coords.push p[0], p[1]
		@canvas.context.stroke!
	
	# Redraw all coordinates so far
	actionRedraw: !->
		# console.log @action_data
		unless @action_data.coords.length == 0
			@actionInit @action_data.coords[0][0], @action_data.coords[0][1]
			for p in @action_data.coords
				@canvas.context.line-to p[0], p[1]
			@canvas.context.stroke!
	
	# Sets the action's data
	setActionData: (data) !->
		@action_data.brushtype = data.brushtype
		@action_data.radius = data.radius
		@action_data.color = data.color
		@action_data.coords = [x for x in data.coords]
		# console.log @action_data
	
	# Gets the action's data; useful for action history
	getActionData: (data) !->
		ret = {}
		ret.brushtype = @action_data.brushtype
		ret.radius = @action_data.radius
		ret.color = @action_data.color
		ret.coords = [x for x in @action_data.coords]
		return ret
	
	# Just takes action data given and draws it.
	doAction: (data) !->
		unless data.coords.length == 0
			@actionInit data.coords[0][0], data.coords[0][1]
			for p in data.coords
				@canvas.context.line-to p[0], p[1]
			@canvas.context.stroke!
			@actionEnd!

class WireframeBrush extends Brush
	(radius, color, canvas) ->
	
		super ...
		@type = "wireframe"

	actionInit: (x, y) !->
		@canvas.context.moveTo x, y
		# Set the line's color from the brush's color
		@canvas.context.strokeStyle = @color.toCSS!
		
		# Start a new path, because we're on a new action
		@canvas.context.beginPath!
		
		# Set the line width from the brush's current radius
		@canvas.context.line-width = @radius
	
	actionStart: (x, y) !->
		@action_data = {brushtype:@type, radius:@radius, color:(@color.toCSS!), coords:[]}
		@actionInit x, y
	
	actionEnd: !->
		
		@canvas.context.closePath!
	
	actionMove: (x, y) !->
	
		@canvas.context.line-to x, y
		numpoints = @action_data.coords.length
		if numpoints >= 4
			@canvas.context.lineTo @action_data.coords[numpoints-4][0], @action_data.coords[numpoints-4][1]
		@canvas.context.stroke!
		@action_data.coords.push [x, y]
	
	actionProcessCoords: (data) !->
		for i from 1 til data.coords.length by 1
				@canvas.context.lineTo data.coords[i][0], data.coords[i][1]
				nearpoint = data.coords[i-5]
				if nearpoint
					@canvas.context.moveTo nearpoint[0], nearpoint[1]
					@canvas.context.lineTo data.coords[i][0], data.coords[i][1]
				@action_data.coords.push data.coords[i][0], data.coords[i][1]
		@canvas.context.stroke!
	
	actionRedraw: !->
		@actionInit @action_data.coords[0][0], @action_data.coords[0][1]
		for i from 1 til @action_data.coords.length by 1
				@canvas.context.lineTo @action_data.coords[i][0], @action_data.coords[i][1]
				nearpoint = @action_data.coords[i-5]
				if nearpoint
					@canvas.context.moveTo nearpoint[0], nearpoint[1]
					@canvas.context.lineTo @action_data.coords[i][0], @action_data.coords[i][1]
		@canvas.context.stroke!
	
	doAction: (data) !->
		unless data.coords.length == 0
			@actionInit data.coords[0][0], data.coords[0][1]
			for i from 1 til data.coords.length by 1
				@canvas.context.lineTo data.coords[i][0], data.coords[i][1]
				nearpoint = data.coords[i-5]
				if nearpoint
					@canvas.context.moveTo nearpoint[0], nearpoint[1]
					@canvas.context.lineTo data.coords[i][0], data.coords[i][1]
			@canvas.context.stroke!
			@actionEnd!

class ColorSamplerBrush extends Brush
	(radius, color, canvas) ->
	
		super ...
		@type = "sampler"
	actionInit: (x, y) !->
		p = (@canvas.context.getImageData x, y, 1, 1).data
		
		# getImageData gives alpha as an int from 0-255, we need a float from 0.0-1.0
		a = p[3] / 255.0
		
		hex = "rgba(" + p[0] + "," +  p[1] + "," + p[2] + "," + a + ")"
		@canvas.doColorChange (Color hex)
		
	actionStart: (x, y) !->
		@actionInit x, y
		@action_data = {brushtype:@type, radius:@radius, color:(@color.toCSS!), coords:[]}

	actionEnd: !->
		return
		
	actionMove: (x, y) !->
		@actionInit x, y
	
	actionProcessCoords: (data) ->
		return
	
	actionRedraw: !->
		return
		
	doAction: (data) !->
		return

class Lenny extends Brush
	(radius, color, canvas) ->
		
		super ...
		@type = "lenny"
	
	actionInit: (x, y) !->
		@canvas.context.moveTo x, y
		# Set the line's color from the brush's color
		@canvas.context.fillStyle = @color.toCSS!
		@canvas.context.font = "bold " + @radius + "px arial"
		@canvas.context.fillText "( ͡° ͜ʖ ͡°)", x, y
		
	actionStart: (x, y) !->
		@actionInit x, y
		@action_data = {brushtype:@type, radius:@radius, color:(@color.toCSS!), coords:[]}
		@action_data.coords.push [x, y]

	actionEnd: !->
		return
	
	actionMove: (x, y) !->
		
		@canvas.context.fillText "( ͡° ͜ʖ ͡°)", x, y
		@action_data.coords.push [x, y]
	
	actionProcessCoords: (data) !->
		for p in data.coords
			@canvas.context.fillText "( ͡° ͜ʖ ͡°)", p[0], p[1]
			@action_data.coords.push p[0], p[1]
	
	actionRedraw: !->
		unless @action_data.coords.length == 0
			@actionInit @action_data.coords[0][0], @action_data.coords[0][1]
			for p in @action_data
				@canvas.context.fillText "( ͡° ͜ʖ ͡°)", p[0], p[1]
		
	doAction: (data) !->
		unless data.coords.length == 0
			@actionInit data.coords[0][0], data.coords[0][1]
			for p in data.coords
				@canvas.context.fillText "( ͡° ͜ʖ ͡°)", p[0], p[1]
		
class EraserBrush extends Brush
	(radius, color, canvas) ->
		super ...
		@type = "eraser"
	
	actionInit: (x, y) !->
		corner_x = if (x - @radius) >= 0 then (x - @radius) else 0
		corner_y = if (y - @radius) >= 0 then (y - @radius) else 0
		@canvas.context.clearRect corner_x, corner_y, @radius * 2, @radius * 2
		@action_data = {brushtype:@type, radius:@radius, color:(@color.toCSS!), coords:[]}
		@action_data.coords.push [x, y]
	
	actionStart: (x, y) !->
		@actionInit x, y
	
	actionEnd: !->
		return
	
	actionMove: (x, y) !->
		corner_x = if (x - @radius) >= 0 then (x - @radius) else 0
		corner_y = if (y - @radius) >= 0 then (y - @radius) else 0
		@canvas.context.clearRect corner_x, corner_y, @radius * 2, @radius * 2
		@action_data.coords.push [x, y]
	
	actionProcessCoords: (data) !->
		for p in data.coords
			corner_x = if (p[0] - @radius) >= 0 then (p[0] - @radius) else 0
			corner_y = if (p[1] - @radius) >= 0 then (p[1] - @radius) else 0
			@canvas.context.clearRect corner_x, corner_y, @radius * 2, @radius * 2
			@action_data.coords.push p[0], p[1]
	
	actionRedraw: !->
		@actionInit @action_data.coords[0][0], @action_data.coords[0][1]
		for p in @action_data
			corner_x = if (p[0] - @radius) >= 0 then (p[0] - @radius) else 0
			corner_y = if (p[1] - @radius) >= 0 then (p[1] - @radius) else 0
			@canvas.context.clearRect corner_x, corner_y, @radius * 2, @radius * 2
	
	doAction: (data) !->
		unless data.coords.length == 0
			for p in data.coords
				corner_x = if (p[0] - @radius) >= 0 then (p[0] - @radius) else 0
				corner_y = if (p[1] - @radius) >= 0 then (p[1] - @radius) else 0
				@canvas.context.clearRect corner_x, corner_y, @radius * 2, @radius * 2

class CopyPasteBrush extends Brush
	(radius, color, canvas) ->
		super ...
		@type = "copypaste"
		@imgData = void
	actionInit: (x, y) !->
		corner_x = if (x - @radius) >= 0 then (x - @radius) else 0
		corner_y = if (y - @radius) >= 0 then (y - @radius) else 0
		@imgData = @canvas.context.getImageData corner_x, corner_y, @radius * 2, @radius * 2
		@action_data = {brushtype:@type, radius:@radius, color:(@color.toCSS!), coords:[]}
		@action_data.coords.push [x, y]
	
	actionStart: (x, y) !->
		@actionInit x, y
	
	actionEnd: !->
		return
	
	actionMove: (x, y) !->
		corner_x = if (x - @radius) >= 0 then (x - @radius) else 0
		corner_y = if (y - @radius) >= 0 then (y - @radius) else 0
		@canvas.context.putImageData @imgData, corner_x, corner_y
		@action_data.coords.push [x, y]
	
	actionProcessCoords: (data) !->
		for p in data.coords
			corner_x = if (p[0] - @radius) >= 0 then (p[0] - @radius) else 0
			corner_y = if (p[1] - @radius) >= 0 then (p[1] - @radius) else 0
			@canvas.context.putImageData @imgData, corner_x, corner_y
			@action_data.coords.push p[0], p[1]
	
	actionRedraw: !->
		@actionInit @action_data.coords[0][0], @action_data.coords[0][1]
		for p in @action_data
			corner_x = if (p[0] - @radius) >= 0 then (p[0] - @radius) else 0
			corner_y = if (p[1] - @radius) >= 0 then (p[1] - @radius) else 0
			@canvas.context.putImageData @imgData, corner_x, corner_y
		
	doAction: (data) !->
		unless data.coords.length == 0
			corner_x = if (data.coords[0][0] - @radius) >= 0 then (data.coords[0][0] - @radius) else 0
			corner_y = if (data.coords[0][1] - @radius) >= 0 then (data.coords[0][1] - @radius) else 0
			@imgData = @canvas.context.getImageData corner_x, corner_y, @radius * 2, @radius * 2
			for p in data.coords
				corner_x = if (p[0] - @radius) >= 0 then (p[0] - @radius) else 0
				corner_y = if (p[1] - @radius) >= 0 then (p[1] - @radius) else 0
				@canvas.context.putImageData @imgData, corner_x, corner_y

class SketchBrush extends Brush
	(radius, color, canvas) ->
	
		super ...
		@type = "sketch"

	actionInit: (x, y) !->
		@canvas.context.moveTo x, y
		# Set the line's color from the brush's color
		@canvas.context.strokeStyle = @color.toCSS!
		
		# Start a new path, because we're on a new action
		@canvas.context.beginPath!
		
		# Set the line width from the brush's current radius
		@canvas.context.line-width = @radius
		
		# get rid of those nasty turns
		@canvas.context.line-cap = 'round'
	
	actionStart: (x, y) !->
		@actionInit x, y
		@action_data = {brushtype:@type, radius:@radius, color:(@color.toCSS!), coords:[]}
	
	actionEnd: !->
		@canvas.context.closePath!
	
	actionMove: (x, y) !->
		numpoints = @action_data.coords.length
		if numpoints > 1
			lastpoint = @action_data.coords[numpoints - 1]
			@canvas.context.moveTo lastpoint[0], lastpoint[1]
			@canvas.context.line-to x, y
			@canvas.context.stroke!
			@canvas.context.closePath!
			@canvas.context.strokeStyle = (@color.setAlpha ((@color.getAlpha!) / 3.0)).toCSS!
			for p in @action_data.coords
				dx = p[0] - x;
				dy = p[1] - y;
				d = dx * dx + dy * dy;

				if d < 1000 && (!((p[0] == lastpoint[0]) && (p[1] == lastpoint[1])))
					@canvas.context.beginPath!
					@canvas.context.moveTo(x + (dx * 0.2), y + (dy * 0.2))
					@canvas.context.lineTo(p[0] - (dx * 0.2), p[1] - (dy * 0.2))
				@canvas.context.stroke!
				@canvas.context.closePath!
			@canvas.context.beginPath!
			@canvas.context.strokeStyle = @color.toCSS!
		@action_data.coords.push [x, y]
	
	actionProcessCoords: (data) !->
		for p in data.coords
			@canvas.context.line-to p[0], p[1]
			@action_data.coords.push p[0], p[1]
		@canvas.context.stroke!
		@canvas.context.closePath!
		@canvas.context.strokeStyle = (@color.setAlpha ((@color.getAlpha!) / 3.0)).toCSS!
		for i from 1 til data.coords.length by 1
			for p in data.coords
				dx = p[0] - data.coords[i][0];
				dy = p[1] - data.coords[i][1];
				d = dx * dx + dy * dy;

				if d < 1000 && (!((p[0] == data.coords[i-1][0]) && (p[1] == data.coords[i-1][1])))
					@canvas.context.beginPath!
					@canvas.context.moveTo(data.coords[i][0] + (dx * 0.2), data.coords[i][1] + (dy * 0.2))
					@canvas.context.lineTo(p[0] - (dx * 0.2), p[1] - (dy * 0.2))
			@canvas.context.stroke!
			@canvas.context.closePath!
		@canvas.context.beginPath!
		@canvas.context.strokeStyle = @color.toCSS!
	
	actionRedraw: !->
		@actionInit @action_data.coords[0], @action_data.coords[1]
		for p in @action_data
			@canvas.context.line-to p[0], p[1]
		@canvas.context.stroke!
		@canvas.context.closePath!
		@canvas.context.strokeStyle = (@color.setAlpha ((@color.getAlpha!) / 3.0)).toCSS!
		for i from 1 til @action_data.coords.length by 1
			for p in @action_data
				dx = p[0] - @action_data.coords[i][0];
				dy = p[1] - @action_data.coords[i][1];
				d = dx * dx + dy * dy;

				if d < 1000 && (!((p[0] == @action_data.coords[i-1][0]) && (p[1] == @action_data.coords[i-1][1])))
					@canvas.context.beginPath!
					@canvas.context.moveTo(@action_data.coords[i][0] + (dx * 0.2), @action_data.coords[i][1] + (dy * 0.2))
					@canvas.context.lineTo(p[0] - (dx * 0.2), p[1] - (dy * 0.2))
			@canvas.context.stroke!
			@canvas.context.closePath!
		@canvas.context.beginPath!
		@canvas.context.strokeStyle = @color.toCSS!

	doAction: (data) !->
		unless data.coords.length == 0
			@actionStart data.coords[0][0], data.coords[0][1]
			for p in data.coords
				@canvas.context.line-to p[0], p[1]
			@canvas.context.stroke!
			@canvas.context.closePath!
			@canvas.context.strokeStyle = (@color.setAlpha ((@color.getAlpha!) / 3.0)).toCSS!
			for i from 1 til data.coords.length by 1
				for p in data.coords
					dx = p[0] - data.coords[i][0];
					dy = p[1] - data.coords[i][1];
					d = dx * dx + dy * dy;

					if (d < 1000) && (!((p[0] == data.coords[i-1][0]) && (p[1] == data.coords[i-1][1])))
						@canvas.context.beginPath!
						@canvas.context.moveTo(data.coords[i][0] + (dx * 0.2), data.coords[i][1] + (dy * 0.2))
						@canvas.context.lineTo(p[0] - (dx * 0.2), p[1] - (dy * 0.2))
						@canvas.context.stroke!
						@canvas.context.closePath!

getBrush = (brushtype, radius, color, canvas) ->
	| brushtype == 'default' => new Brush radius, color, canvas
	| brushtype == 'wireframe' => new WireframeBrush radius, color, canvas
	| brushtype == 'sampler' => new ColorSamplerBrush radius, color, canvas
	| brushtype == 'lenny' => new Lenny radius, color, canvas
	| brushtype == 'eraser' => new EraserBrush radius, color, canvas
	| brushtype == 'copypaste' => new CopyPasteBrush radius, color, canvas
	| brushtype == 'sketch' => new SketchBrush radius, color, canvas
