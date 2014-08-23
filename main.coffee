
CANVAS_WIDTH = 600
CANVAS_PLAY_WIDTH = 400
CANVAS_HEIGHT = 400
CANVAS_HALF_WIDTH = CANVAS_WIDTH/2
CANVAS_HALF_HEIGHT= CANVAS_HEIGHT/2

CANVAS_NAME = 'game_canvas'

REGEX_TYPE_DIGITS = 0
REGEX_TYPE_LETTERS = 1
REGEX_TYPE_BACKSLASH = 2
REGEX_TYPE_LETTERS_DIGITS = 3

padding = 8
font_canvas = document.createElement 'canvas'
font_context = font_canvas.getContext '2d'

class Block
	constructor: ->

	string_to_image: (das_text) ->
		font_context.font = 'bold 18pt Courier New'
		font_context.textAlign = 'left'
		font_context.fillStyle = 'black'
		metrics = font_context.measureText das_text
		font_canvas.width = metrics.width+padding
		font_canvas.height = 21 + padding

		font_context.rect 0,0,font_canvas.width,font_canvas.height
		font_context.stroke()

		font_context.fillStyle = 'red'
		font_context.font = 'bold 18pt Courier New'
		font_context.textAlign = 'left'
		font_context.fillText das_text, padding/2, font_canvas.height-padding/2-4

		image = new Image()
		image.src = font_canvas.toDataURL('image/url')
		return image

	add_to_world: (world) ->

		block_width = @img.width
		block_height = @img.height
		x_start_pos = Math.random() * (CANVAS_PLAY_WIDTH - block_width)
		console.log 'x': x_start_pos

		block = Physics.body 'rectangle', 
			width: block_width
			height: block_height
			restitution: 0.95
			mass: 0.1
			x: x_start_pos
			y: 0
			view: @img

		rotation = (0.5 - Math.random()) * 0.001
		block.state.angular.acc = rotation
		block.regex_type = @type

		world.add block

# Matches 0-9
class Digits extends Block
	constructor: ->
		@type = REGEX_TYPE_DIGITS
		num_digits = Math.floor Math.random() * 10
		string = ''
		if num_digits > 0
			for i in [0..num_digits] by 1
				val = Math.floor Math.random() * 10
				string += val.toString()
		else
			string = '     '
		@img = @string_to_image string

# Matches a-z, A-Z, 0-9, including the _ 
class Letters extends Block
	constructor: ->
		@type = REGEX_TYPE_LETTERS
		letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'
		num_digits = 1 + Math.floor Math.random() * 9
		string = ''
		for i in [0..num_digits] by 1

			val = Math.floor Math.random() * letters.length
			string += letters.charAt val
		@img = @string_to_image string

class Backslash extends Block
	constructor: ->
		@type = REGEX_TYPE_BACKSLASH
		string = '\\'
		@img = @string_to_image string

# Matches 1-3 of a-z, A-Z, 0-9, including the _
# followed by 1-3 of 0-9 
class LettersDigits extends Block
	constructor: ->
		@type = REGEX_TYPE_LETTERS_DIGITS
		letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'
		string = ''
		num_digits = 1 + Math.floor Math.random() * 2
		for i in [0..num_digits] by 1

			val = Math.floor Math.random() * letters.length
			string += letters.charAt val

		num_digits = 1 + Math.floor Math.random() * 2		
		for i in [0..num_digits] by 1
			val = Math.floor Math.random() * 10
			string += val.toString()
		@img = @string_to_image string


add_block = (world) ->

	type = Math.floor Math.random() * 4
	switch type
		when 0
			regex = new Backslash()
		when 1
			regex = new Digits()
		when 2
			regex = new Letters()
		else
			regex = new LettersDigits()

	regex.add_to_world world

mouse_2_canvas_coords = (canvas, event) ->
	cx = 0
	cy = 0

	if event.pageX or event.pageY
		cx = event.pageX
		cy = event.pageY
	else
		cx = event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
		cy = event.clientY + document.body.scrollTop + document.documentElement.scrollTop

	cx -= canvas.offsetLeft
	cy -= canvas.offsetTop

	return [cx,cy]

generate_regex_menu = (world) ->

	spacing = 3
	border = 3
	height = 20
	width = 50

	regex_1_img = new Image()
	regex_1_img.src = "match_digits.png"

	regex_1 = Physics.body 'rectangle', 
			width: width
			height: height
			treatment: 'static'
			x: CANVAS_WIDTH - border - width/2
			y: (spacing + height) * 0 + spacing + height/2
			view: regex_1_img
	regex_1.regex = REGEX_TYPE_DIGITS
	world.add regex_1

	regex_2_img = new Image()
	regex_2_img.src = "match_letters.png"

	regex_2 = Physics.body 'rectangle', 
			width: width
			height: height
			treatment: 'static'
			x: CANVAS_WIDTH - border - width/2
			y: (spacing + height) * 1 + spacing + height/2
			view: regex_2_img
	regex_2.regex = REGEX_TYPE_LETTERS
	world.add regex_2

	regex_3_img = new Image()
	regex_3_img.src = "match_backslash.png"

	regex_3 = Physics.body 'rectangle', 
			width: width
			height: height
			treatment: 'static'
			x: CANVAS_WIDTH - border - width/2
			y: (spacing + height) * 2 + spacing + height/2
			view: regex_3_img
	regex_3.regex = REGEX_TYPE_BACKSLASH
	world.add regex_3

	width = 160
	regex_4_img = new Image()
	regex_4_img.src = "match_letters_digits.png"

	regex_4 = Physics.body 'rectangle', 
			width: width
			height: height
			treatment: 'static'
			x: CANVAS_WIDTH - border - width/2
			y: (spacing + height) * 3 + spacing + height/2
			view: regex_4_img
	regex_4.regex = REGEX_TYPE_LETTERS_DIGITS
	world.add regex_4

window.onload = -> 
	Physics (world) ->
		# create a canvas renderer
		renderer = Physics.renderer 'canvas',
		    el: CANVAS_NAME
		    width: CANVAS_WIDTH
		    height: CANVAS_HEIGHT
		    # debug: true
		world.add renderer

		generate_regex_menu world
		add_block(world)



		world.add Physics.behavior 'constant-acceleration',
			acc:
				x: 0
				y:	0.00002

		bounds = Physics.aabb(0, -CANVAS_HEIGHT, CANVAS_WIDTH, CANVAS_HEIGHT);
		world.add Physics.behavior 'edge-collision-detection',
			aabb: bounds
			restitution: 0.3

		world.add Physics.behavior 'body-impulse-response'

		world.add Physics.behavior 'body-collision-detection'

		world.add Physics.behavior 'sweep-prune'

		counter = 0

		world.on 'step', ->
			counter += 1
			if counter > 50*5
				counter = 0
				add_block(world)

			world.render()
			if tracking
				styles =
					strokeStyle: 'blue'
					lineWidth: 5
				dest_pos = 
					x: mousepos_x
					y: mousepos_y,									
				renderer.drawLine tracking.state.pos,dest_pos,styles

		Physics.util.ticker.on ( time, dt ) ->
			world.step(time)
    
		Physics.util.ticker.start()

		tracking = false
		mousepos_x = 0
		mousepos_y = 0

		mouse_down = (event) ->
			[cx,cy] = mouse_2_canvas_coords canvas, event
			[mousepos_x, mousepos_y] = [cx, cy]
			pos = Physics.vector(cx, cy)
			hit = world.findOne
				$at: pos

			if hit
				tracking = hit

		mouse_move = (event) ->
			if not tracking
				return
			[cx,cy] = mouse_2_canvas_coords canvas, event
			[mousepos_x, mousepos_y] = [cx, cy]

		mouse_up = (event) ->
			[cx,cy] = mouse_2_canvas_coords canvas, event
			[mousepos_x, mousepos_y] = [cx, cy]
			pos = Physics.vector(cx, cy)
			hit = world.findOne
				$at: pos

			if hit and hit != tracking
				console.log 'up:', hit
				if hit.regex? and hit.regex == tracking.regex_type
					# Got a match, increase player score and remove block
					world.remove(tracking)
					console.log 'from msg to regex'
				else if tracking.regex? and tracking.regex == hit.regex_type
					# Got a match, increase player score and remove block
					world.remove(hit)
					console.log 'from regex to hit'
				else
					# No match, decrease player score!

			tracking = false

		mouse_out = (event) ->
			tracking = false

		canvas = document.getElementById CANVAS_NAME
		canvas.addEventListener "mousemove", mouse_move
		canvas = document.getElementById CANVAS_NAME
		canvas.addEventListener "mousedown", mouse_down
		canvas = document.getElementById CANVAS_NAME
		canvas.addEventListener "mouseup", mouse_up
		canvas = document.getElementById CANVAS_NAME
		canvas.addEventListener "mouseout", mouse_out





