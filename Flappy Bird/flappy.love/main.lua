--[[

FLAPPY BIRD, IN LÖVE/Love2D
AUTHOR: PRANJAL VERMA

]]--

-- Bugs:
-- Some text is not scaled!!

-- requires
class = require 'middleclass'
require 'Bird'
require 'Pipe'
require 'PipePair'

-- Global game constants
WINDOW_WIDTH, WINDOW_HEIGHT = 1440, 900
GRAVITY = 20

-- Game inits
love.window.setTitle('Flappy Bird')
love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
	fullscreen = true,
	highdpi = true -- only for Retina Displays
	})

-- Game State manager
local Gamestates = {
	gameMenu = true,
	gameInstruct = false,
	gameOver = false
}

-- Fonts manager
local fonts = {
	title = love.graphics.newFont('Fonts/flapfont.ttf', 200),
	normal = love.graphics.newFont('Fonts/flapfont.ttf', 20),
	small = love.graphics.newFont('Fonts/flapfont.ttf', 15)
}

-- Game backdrop object
local backdrop = {
	image = love.graphics.newImage('Images/backdrop.png'),
	scrollAmount = 0,
	SCROLL_SPEED = 30,
	LOOPING_POINT = WINDOW_WIDTH
}

-- Game ground object
local ground = {
	image = love.graphics.newImage('Images/ground.png'),
	scrollAmount = 0,
	SCROLL_SPEED = 4 * backdrop.SCROLL_SPEED,
	LOOPING_POINT = 100
}

-- Bird and pipes controller
local bird = Bird()
local pipesController = {
	SPAWN_TIME = 1.8,
	spawnTimer = 1.8, -- instantly start spawning
	pipePairs = {}
}

-- Callback for game init
function love.load()

	-- init nearest-neighbour filter and seed for pipes
	love.graphics.setDefaultFilter('nearest', 'nearest')
	math.randomseed(os.time())

	--reset bird
	bird = Bird()

	-- clear pipes
	pipesController.pipePairs = {}

	-- restart
	Gamestates.gameOver = false

	-- creating table to track single key presses, frame by frame
	love.keyboard.keysPressed = {} 
end

-- Callback for updating game state
function love.update(dt)

	-- test code
	if Gamestates.gameOver then
		return
	end

	-- game over if bird crashes to the ground
	if bird.y + bird.width > WINDOW_HEIGHT - 50 then
		Gamestates.gameOver = true
	end

	-- backdrop and ground scroll amount
	backdrop.scrollAmount = (backdrop.scrollAmount + backdrop.SCROLL_SPEED * dt)
							% backdrop.LOOPING_POINT
	ground.scrollAmount = (ground.scrollAmount + ground.SCROLL_SPEED * dt)
							% ground.LOOPING_POINT

	-- don't update sprites if on menu
	if Gamestates.gameMenu then
		return
	end

	-- track time elapsed (in seconds)
	-- spawn if SPAWN_TIME secs have passed
	pipesController.spawnTimer = pipesController.spawnTimer + dt
	if pipesController.spawnTimer > pipesController.SPAWN_TIME then
		table.insert(pipesController.pipePairs, PipePair())
		pipesController.spawnTimer = 0
	end

	-- update bird
	bird:update(dt)

	-- update pipes and collision detection
	for k, pipePair in pairs(pipesController.pipePairs) do

		-- scroll pipes
		pipePair.top:update(dt)
		pipePair.bottom:update(dt)

		-- delete pipes if they go past screen
		-- '*4' to prevent glitch in graphics as table deletion
		-- causes each other entry to shift in terms of their keys
		if pipePair.bottom.x < -pipePair.bottom.width * 4 then
			table.remove(pipesController.pipePairs, k)
		end

		-- check only those pipe pairs that havn't yet been scored on
		if not pipePair.scored then
			bird:addScore(pipePair)
		end

		-- collision detection
		if bird:collides(pipePair.top) or bird:collides(pipePair.bottom) then
			Gamestates.gameOver = true
		end

	end

	-- flushing single-key-presses tracker at end of every frame
	love.keyboard.keysPressed = {}

end

-- Callback for drawing updated game state on the screen
function love.draw()

	-- drawing backdrop with infinite scrolling
	love.graphics.draw(backdrop.image, -backdrop.scrollAmount, 0)
	love.graphics.draw(backdrop.image,
		backdrop.LOOPING_POINT - backdrop.scrollAmount, 0)

	-- game menu
	if Gamestates.gameMenu then
		love.graphics.setFont(fonts.title)
		love.graphics.print('Flappy Bird',
			WINDOW_WIDTH/2 - 540, WINDOW_HEIGHT/5)

		love.graphics.setFont(fonts.normal)
		love.graphics.print('Press Enter to start!',
			180, WINDOW_HEIGHT/2 - 60)
	end

	-- draw pipes
	for _, pipePair in pairs(pipesController.pipePairs) do
		pipePair.top:render()
		pipePair.bottom:render()
	end

	-- draw bird
	bird:render()

	-- drawing ground with infinite scrolling; .png is 100x50 px
	for i=0,144 do
		love.graphics.draw(ground.image,
			i*100 - ground.scrollAmount, WINDOW_HEIGHT - 50)
	end

	-- author name
	if Gamestates.gameMenu then
		love.graphics.setFont(fonts.small)
		love.graphics.print('Made with LOVE2D by Pranjal Verma',
			WINDOW_WIDTH - 295, WINDOW_HEIGHT - 20)
	end

	-- instructions message
	love.graphics.setFont(fonts.normal)
	love.graphics.print('Press i to toggle instructions',
		WINDOW_WIDTH - 330, 5)

	-- ingame handling
	if not Gamestates.gameMenu then

		-- game over screen
		if Gamestates.gameOver then
			love.graphics.setFont(fonts.title)
			love.graphics.print('Game Over',
				WINDOW_WIDTH/2 - 525, WINDOW_HEIGHT/5)
		end

		-- player's score
		love.graphics.setFont(fonts.normal)
		love.graphics.print('Score: ' .. bird.score, 5, 5)
	end

	-- toggle game instructions screen
	if Gamestates.gameInstruct then
		love.graphics.setFont(fonts.normal)

		love.graphics.print('SPACE - flap',
			5, WINDOW_HEIGHT/2 - 10)
		love.graphics.print('LSHIFT - restart',
			5, WINDOW_HEIGHT/2 + 10)
		love.graphics.print('Q or ESC - quit',
			5, WINDOW_HEIGHT/2 + 30)
	end

end

-- Callback for game state and player controls
function love.keypressed(key)

	-- updating keysPressed tracker
	love.keyboard.keysPressed[key] = true

	-- enter game from menu
	if key == 'return' then
		Gamestates.gameMenu = false
	end

	-- toggle game instructions screen
	if key == 'i' then
		Gamestates.gameInstruct = not Gamestates.gameInstruct
	end

	-- game quit
	if key == 'escape' or key == 'q' then
		love.event.quit()
	end

	-- game restart
	if key == 'lshift' then
		love.load()
	end
end

-- Query func for keysPressed to check if 'key' was pressed or not
function love.keyboard.wasPressed(key)
	return love.keyboard.keysPressed[key]
end
