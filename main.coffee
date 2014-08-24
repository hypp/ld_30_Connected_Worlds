
CANVAS_WIDTH = 600
CANVAS_PLAY_WIDTH = 400
CANVAS_HEIGHT = 400
CANVAS_HALF_WIDTH = CANVAS_WIDTH/2
CANVAS_HALF_HEIGHT= CANVAS_HEIGHT/2

CANVAS_NAME = 'game_canvas'
SCORE_NAME = 'score'


class AudioStuff
	constructor: ->
		@success_samples = []
		@failure_samples = []
		@game_over_samples = []

		@load_music()
		@load_success_samples()
		@load_failure_samples()
		@load_game_over_sample()

	load_audio_files: (samples_to_load, target) ->
		for name in samples_to_load
			sample = new buzz.sound name,
				formats: [ "ogg", "mp3", "wav" ]
				preload: true
				loop: false
				autoplay: false
			target.push sample


	load_music: ->
		music = new buzz.sound 'da_regex',
			formats: [ "ogg", "mp3", "wav" ]
			preload: true
			loop: false
			autoplay: true
		music.setVolume 50

		# Try to restart when its done
		music.bind 'ended', (e) ->
			music.load().play()
			music.setVolume 50

	load_success_samples: ->
		samples_to_load = ['yeah','super', 'give_me_five', 'alright']
		@load_audio_files samples_to_load, @success_samples

	load_failure_samples: ->
		samples_to_load = ['error', 'that_is_not_correct', 'try_again']
		@load_audio_files samples_to_load, @failure_samples

	load_game_over_sample: ->
		samples_to_load = ['game_over']
		@load_audio_files samples_to_load, @game_over_samples

	play_success: ->
		sample_no = Math.floor Math.random() * @success_samples.length
		@success_samples[sample_no].load().play()

	play_failure: ->
		sample_no = Math.floor Math.random() * @failure_samples.length
		@failure_samples[sample_no].load().play()

	play_game_over: ->
		sample_no = Math.floor Math.random() * @game_over_samples.length
		@game_over_samples[sample_no].load().play()

audio_stuff = new AudioStuff()

padding = 8
font_canvas = document.createElement 'canvas'
font_context = font_canvas.getContext '2d'

string_to_image = (das_text, color) ->
	font_context.font = 'bold 18pt Courier New'
	font_context.textAlign = 'left'
	font_context.fillStyle = 'black'
	metrics = font_context.measureText das_text
	font_canvas.width = metrics.width+padding
	font_canvas.height = 21 + padding

	font_context.rect 0,0,font_canvas.width,font_canvas.height
	font_context.stroke()

	font_context.fillStyle = color
	font_context.font = 'bold 18pt Courier New'
	font_context.textAlign = 'left'
	font_context.fillText das_text, padding/2, font_canvas.height-padding/2-4

	image = new Image()
	# I have to set width and height or it won't work in Safari and Firefox
	image.width = font_canvas.width
	image.height = font_canvas.height
	image.src = font_canvas.toDataURL()
	return image

class Player
	constructor: ->
		@score = 0
		@score_div = document.getElementById SCORE_NAME

	add_score: (more) ->
		@score += more
#		@score_div.innerHTML = @score.toString() + ' points'

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
			y: -block_height
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
		num_digits = Math.floor Math.random() * 10
		@string = ''
		if num_digits > 0
			for i in [0..num_digits] by 1
				val = Math.floor Math.random() * 10
				@string += val.toString()
			@img = string_to_image @string, 'red'
		else
			@string = ''
			@img = string_to_image '     ', 'red'

# Matches a-z, A-Z, 0-9, including the _ 
class Letters extends Block
	constructor: ->
		letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'
		num_digits = 1 + Math.floor Math.random() * 9
		@string = ''
		for i in [0..num_digits] by 1

			val = Math.floor Math.random() * letters.length
			@string += letters.charAt val
		@img = string_to_image @string, 'red'

# Matches a-z, A-Z, 0-9, including the _ and contains a .
class LettersDot extends Block
	constructor: ->
		letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'
		num_digits = 1 + Math.floor Math.random() * 9
		@string = ''
		for i in [0..num_digits] by 1

			if i == Math.floor num_digits / 2
				@string += '.'
			val = Math.floor Math.random() * letters.length
			@string += letters.charAt val
		@img = string_to_image @string, 'red'

class Backslash extends Block
	constructor: ->
		@string = '\\'
		@img = string_to_image @string, 'red'

class Mathias extends Block
	constructor: ->
		val = Math.floor Math.random() * 10
		if val == 0
			@string = 'Mathias'
		else
			@string = 'Mattias'
		@img = string_to_image @string, 'red'

# Matches 1-3 of a-z, A-Z, 0-9, including the _
# followed by 1-3 of 0-9 
class LettersDigits extends Block
	constructor: ->
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
		@img = string_to_image @string, 'red'

class EndsWithzaS extends Block
	constructor: ->
		letters = 'abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_!"#€%&()='
		num_digits = 1 + Math.floor Math.random() * 9
		@string = ''
		for i in [0..num_digits] by 1

			val = Math.floor Math.random() * letters.length
			@string += letters.charAt val
		@string += 'zaS'
		@img = string_to_image @string, 'red'

class StartsWithpow extends Block
	constructor: ->
		letters = 'abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_!"#€%&()='
		num_digits = 1 + Math.floor Math.random() * 9
		@string = 'pow'
		for i in [0..num_digits] by 1

			val = Math.floor Math.random() * letters.length
			@string += letters.charAt val
		@img = string_to_image @string, 'red'

# Contains aa
class Containsaa extends Block
	constructor: ->
		letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_!"#€%&()=?/\\@^$'
		num_digits = 1 + Math.floor Math.random() * 9
		@string = ''
		for i in [0..num_digits] by 1

			if i == Math.floor num_digits / 2
				@string += 'aa'
			val = Math.floor Math.random() * letters.length
			@string += letters.charAt val
		@img = string_to_image @string, 'red'

class GameRegex
	constructor: (regex) ->
		@regex_str = regex
		@regex = new RegExp(@regex_str)
		@img = string_to_image @regex_str, 'green'

	match: (string) ->
		result = @regex.test string
		console.log 'regex:',@regex,'string:',string,'result:',result
		return result

	score: ->
		return @regex_str.length * 2

num_blocks = 0

add_block = (world) ->

	num_blocks += 1

	type = Math.floor Math.random() * 10
	switch type
		when 0
			regex = new Backslash()
		when 1
			regex = new Digits()
		when 2
			regex = new Letters()
		when 3
			regex = new LettersDot()
		when 4
			regex = new Mathias()
		when 5
			regex = new EndsWithzaS()
		when 6
			regex = new StartsWithpow()
		when 7
			regex = new Containsaa()
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


all_regexes = ['^\\d*$','^\\w+$','^\\\\$','^\\w{1,3}\\d{1,3}$','^Mathias$','zaS$','^pow','aa','^...$','\\.']

generate_regex_menu = (world) ->

	spacing = 3
	border = 3
	current_y = 0

	for regex_str in all_regexes
		regex_obj= new GameRegex regex_str
		height = regex_obj.img.height
		width = regex_obj.img.width

		regex = Physics.body 'rectangle', 
				width: width
				height: height
				treatment: 'static'
				x: CANVAS_WIDTH - border - width/2
				y: current_y + spacing + height/2
				view: regex_obj.img
		regex.regex = regex_obj
		world.add regex

		# Move to next y
		current_y += spacing + height


domready -> init()

init = -> 
	player = new Player()

	Physics (world) ->
		# create a canvas renderer
		renderer = Physics.renderer 'canvas',
		    el: CANVAS_NAME
		    width: CANVAS_WIDTH
		    height: CANVAS_HEIGHT
		    #debug: true
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
			if counter > 50*2
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

			if num_blocks > 60
				# Game over
				world.pause()
				canvas = document.getElementById CANVAS_NAME
				font_context = canvas.getContext '2d'
				font_context.fillStyle = "black"
				font_context.font = 'bold 60pt Courier New'
				font_context.textAlign = 'center'
				font_context.fillText "Game Over", canvas.width / 2, canvas.height / 2				
				font_context.font = 'bold 48pt Courier New'
				font_context.fillText player.score.toString() + ' points', canvas.width / 2, canvas.height / 2 + 60	

				audio_stuff.play_game_over()			


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
				tracking.oldView = tracking.view
				tracking.view = null

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
						audio_stuff.play_success()
						world.remove(tracking)
						num_blocks -= 1
						console.log 'from msg to regex', tracking.object.string
					when hit.object? and tracking.regex? and tracking.regex.match(hit.object.string)
						# Got a match, increase player score and remove block
						audio_stuff.play_success()
						player.add_score hit.object.score() * tracking.regex.score()
						world.remove(hit)
						num_blocks -= 1
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
						audio_stuff.play_failure()

			if tracking
				tracking.view = tracking.oldView
				tracking.oldView = null
			tracking = false

		mouse_out = (event) ->
			if tracking
				tracking.view = tracking.oldView
				tracking.oldView = null
			tracking = false

		canvas = document.getElementById CANVAS_NAME
		canvas.addEventListener "mousemove", mouse_move
		canvas.addEventListener "mousedown", mouse_down
		canvas.addEventListener "mouseup", mouse_up
		canvas.addEventListener "mouseout", mouse_out





