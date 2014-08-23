
CANVAS_WIDTH = 600
CANVAS_PLAY_WIDTH = 400
CANVAS_HEIGHT = 400
CANVAS_HALF_WIDTH = CANVAS_WIDTH/2
CANVAS_HALF_HEIGHT= CANVAS_HEIGHT/2

CANVAS_NAME = 'game_canvas'
SCORE_NAME = 'score'

REGEX_TYPE_DIGITS = 0
REGEX_TYPE_LETTERS = 1
REGEX_TYPE_BACKSLASH = 2
REGEX_TYPE_LETTERS_DIGITS = 3

padding = 8
font_canvas = document.createElement 'canvas'
font_context = font_canvas.getContext '2d'

string_to_image = (das_text) ->
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

class Player
	constructor: ->
		@score = 0
		@score_div = document.getElementById SCORE_NAME

	add_score: (more) ->
		@score += more
		@score_div.innerHTML = @score.toString() + ' points'

class Block
	constructor: ->

	add_to_world: (world) ->

		block_width = @img.width
		block_height = @img.height
		x_start_pos = Math.random() * (CANVAS_PLAY_WIDTH - block_width)

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
		block.object = this

		world.add block

	score: ->
		if @string.length == 0
			return 125
		else
			return @string.length

# Matches 0-9
class Digits extends Block
	constructor: ->
		@type = REGEX_TYPE_DIGITS
		num_digits = Math.floor Math.random() * 10
		@string = ''
		if num_digits > 0
			for i in [0..num_digits] by 1
				val = Math.floor Math.random() * 10
				@string += val.toString()
			@img = string_to_image @string
		else
			@string = ''
			@img = string_to_image '     '

# Matches a-z, A-Z, 0-9, including the _ 
class Letters extends Block
	constructor: ->
		@type = REGEX_TYPE_LETTERS
		letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'
		num_digits = 1 + Math.floor Math.random() * 9
		@string = ''
		for i in [0..num_digits] by 1

			val = Math.floor Math.random() * letters.length
			@string += letters.charAt val
		@img = string_to_image @string

class Backslash extends Block
	constructor: ->
		@type = REGEX_TYPE_BACKSLASH
		@string = '\\'
		@img = string_to_image @string

# Matches 1-3 of a-z, A-Z, 0-9, including the _
# followed by 1-3 of 0-9 
class LettersDigits extends Block
	constructor: ->
		@type = REGEX_TYPE_LETTERS_DIGITS
		letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'
		@string = ''
		num_digits = 1 + Math.floor Math.random() * 2
		for i in [0..num_digits] by 1

			val = Math.floor Math.random() * letters.length
			@string += letters.charAt val

		num_digits = 1 + Math.floor Math.random() * 2		
		for i in [0..num_digits] by 1
			val = Math.floor Math.random() * 10
			@string += val.toString()
		@img = string_to_image @string


class GameRegex
	constructor: (regex) ->
		@regex_str = regex
		@regex = new RegExp(@regex_str)
		@img = string_to_image @regex_str

	match: (string) ->
		result = @regex.test string
		console.log 'regex:',@regex,'string:',string,'result:',result
		return result

	score: ->
		return @regex_str.length * 2

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
	current_y = 0

	regex_1_obj = new GameRegex '^\\d*$'
	height = regex_1_obj.img.height
	width = regex_1_obj.img.width

	regex_1 = Physics.body 'rectangle', 
			width: width
			height: height
			treatment: 'static'
			x: CANVAS_WIDTH - border - width/2
			y: current_y + spacing + height/2
			view: regex_1_obj.img
	regex_1.regex = regex_1_obj
	world.add regex_1

	# Move to next y
	current_y += spacing + height

	regex_2_obj = new GameRegex '^\\w+$'
	height = regex_2_obj.img.height
	width = regex_2_obj.img.width

	regex_2 = Physics.body 'rectangle', 
			width: width
			height: height
			treatment: 'static'
			x: CANVAS_WIDTH - border - width/2
			y: current_y + spacing + height/2
			view: regex_2_obj.img
	regex_2.regex = regex_2_obj
	world.add regex_2

	# Move to next y
	current_y += spacing + height

	regex_3_obj = new GameRegex '^\\\\$'
	height = regex_3_obj.img.height
	width = regex_3_obj.img.width

	regex_3 = Physics.body 'rectangle', 
			width: width
			height: height
			treatment: 'static'
			x: CANVAS_WIDTH - border - width/2
			y: current_y + spacing + height/2
			view: regex_3_obj.img
	regex_3.regex = regex_3_obj
	world.add regex_3

	# Move to next y
	current_y += spacing + height

	regex_4_obj = new GameRegex '^\\w{1,3}\\d{1,3}$'
	height = regex_4_obj.img.height
	width = regex_4_obj.img.width

	regex_4 = Physics.body 'rectangle', 
			width: width
			height: height
			treatment: 'static'
			x: CANVAS_WIDTH - border - width/2
			y: current_y + spacing + height/2
			view: regex_4_obj.img
	regex_4.regex = regex_4_obj
	world.add regex_4

	# Move to next y
	current_y += spacing + height

window.onload = -> 
	player = new Player()

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
				y:	0.00004

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
				switch
					when hit.regex? and tracking.object? and hit.regex.match(tracking.object.string)
						# Got a match, increase player score and remove block
						player.add_score hit.regex.score() * tracking.object.score()
						world.remove(tracking)
						console.log 'from msg to regex', tracking.object.string
					when hit.object? and tracking.regex? and tracking.regex.match(hit.object.string)
						# Got a match, increase player score and remove block
						player.add_score hit.object.score() * tracking.regex.score()
						world.remove(hit)
						console.log 'from regex to hit'
					else
						# No match, decrease player score!
						if hit.object?
							score1 = hit.object.score()
						else
							score1 = hit.regex.score()
						if tracking.object?
							score2 = tracking.object.score()
						else
							score2 = tracking.regex.score()
						player.add_score -score1 * score2

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





