
CANVAS_WIDTH = 400
CANVAS_HEIGHT = 600
CANVAS_HALF_WIDTH = CANVAS_WIDTH/2
CANVAS_HALF_HEIGHT= CANVAS_HEIGHT/2

CANVAS_NAME = 'game_canvas'

current_block = null

add_block = (world) ->

	block_width = 50 + Math.random() * (CANVAS_WIDTH * 0.25)
	x_start_pos = Math.random() * (CANVAS_WIDTH - block_width)
	console.log 'x': x_start_pos

	block = Physics.body 'rectangle', 
		width: block_width
		height: 15
		restitution: 0.95
		mass: 0.1
		x: x_start_pos
		y: 0

	rotation = (0.5 - Math.random()) * 0.001
	block.state.angular.acc = rotation

	world.add block

	current_block = block

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


window.onload = -> 
	Physics (world) ->
		# create a canvas renderer
		renderer = Physics.renderer 'canvas',
		    el: CANVAS_NAME
		    width: CANVAS_WIDTH
		    height: CANVAS_HEIGHT
		    #debug: true
		world.add renderer

		line_layer = renderer.addLayer 'line_layer'
		line_layer.render = -> 
			this.ctx.fillStyle = "red"
			this.ctx.fillRect 0,0,CANVAS_WIDTH,CANVAS_HEIGHT
			if tracking
				x = tracking.state.pos.x
				y = tracking.state.pos.y
				this.ctx.beginPath()
				this.ctx.strokeStyle = "yellow"
				this.ctx.moveTo x,y
				this.ctx.lineTo mousepos_x,mousepos_y
				this.ctx.stroke()

		add_block(world)

		world.add Physics.behavior 'constant-acceleration',
			acc:
				x: 0
				y:	0.00002

		bounds = Physics.aabb(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
		world.add Physics.behavior 'edge-collision-detection',
			aabb: bounds
			restitution: 0.3

		world.add Physics.behavior 'body-impulse-response'

		world.add Physics.behavior 'body-collision-detection'

		world.add Physics.behavior 'sweep-prune'

		world.on 'step', ->
			y = current_block.state.pos.y
			if y > CANVAS_HALF_HEIGHT
				add_block(world)

			world.render()

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
				console.log 'down:', hit

		mouse_move = (event) ->
			if not tracking
				return
			[cx,cy] = mouse_2_canvas_coords canvas, event
			[mousepos_x, mousepos_y] = [cx, cy]
			console.log 'move:', cx, cy

		mouse_up = (event) ->
			[cx,cy] = mouse_2_canvas_coords canvas, event
			[mousepos_x, mousepos_y] = [cx, cy]
			pos = Physics.vector(cx, cy)
			hit = world.findOne
				$at: pos

			if hit
				console.log 'up:', hit

			tracking = false


		canvas = document.getElementById CANVAS_NAME
		canvas.addEventListener "mousemove", mouse_move
		canvas = document.getElementById CANVAS_NAME
		canvas.addEventListener "mousedown", mouse_down
		canvas = document.getElementById CANVAS_NAME
		canvas.addEventListener "mouseup", mouse_up


