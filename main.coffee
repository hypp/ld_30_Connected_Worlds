
CANVAS_WIDTH = 600
CANVAS_HEIGHT = 600
CANVAS_HALF_WIDTH = CANVAS_WIDTH/2
CANVAS_HALF_HEIGHT= CANVAS_HEIGHT/2


do -> 
    window.requestAnimationFrame = window.requestAnimationFrame or
    window.mozRequestAnimationFrame or
    window.webkitRequestAnimationFrame or
    window.msRequestAnimationFrame or
    fallback

    prev = new Date().getTime()
    fallback = (fn) -> 
        curr = new Date().getTime()
        ms = Math.max 0, 16 - (curr - prev)
        window.setTimeout fn, ms
        prev = curr
        
window.onload = -> 
    canvas = document.getElementById('game_canvas')
    game = new Game(canvas)
    game.run()

class Game

    constructor: (canvas) -> 
        canvas.width = CANVAS_WIDTH
        canvas.height = CANVAS_HEIGHT
        @context = canvas.getContext '2d'
        
        @frame_count = 0

    run: -> 
        @update()
        @draw()
        window.requestAnimationFrame @run.bind this
    
    update: ->

    draw: -> 
        @context.fillStyle = "black"
        @context.fillRect 0,0,CANVAS_WIDTH,CANVAS_HEIGHT

