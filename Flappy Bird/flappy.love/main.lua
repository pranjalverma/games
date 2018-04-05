--[[

FLAPPY BIRD, IN LÖVE/Love2D
AUTHOR: PRANJAL VERMA

]]--

-- USE LÖVELYMOON

-- requires
class = require 'middleclass'
require 'Bird'
require 'Pipe'

-- Global game constants
WINDOW_WIDTH, WINDOW_HEIGHT = 1440, 900
GRAVITY = 20

-- Game inits
love.window.setTitle('Flappy Bird')
love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
	fullscreen = true,
	highdpi = true -- only for Retina Displays
	})

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
	spawnTimer = 0,
	pipes = {}
}

-- Callback for game init
function love.load()

	-- init nearest-neighbour filter and seed for pipes
	love.graphics.setDefaultFilter('nearest', 'nearest')
	math.randomseed(os.time())

	-- creating table to track single key presses, frame by frame
	love.keyboard.keysPressed = {} 
end

-- Callback for updating game state
function love.update(dt)

	-- backdrop and ground scroll amount
	backdrop.scrollAmount = (backdrop.scrollAmount + backdrop.SCROLL_SPEED * dt)
							% backdrop.LOOPING_POINT
	ground.scrollAmount = (ground.scrollAmount + ground.SCROLL_SPEED * dt)
							% ground.LOOPING_POINT

	-- track time elapsed (in seconds), spawn if 2 secs have passed
	pipesController.spawnTimer = pipesController.spawnTimer + dt
	if pipesController.spawnTimer > 3 then
		table.insert(pipesController.pipes, Pipe())
		pipesController.spawnTimer = 0
	end

	-- update bird
	bird:update(dt)

	-- update pipes
	for k, pipe in pairs(pipesController.pipes) do

		-- scroll pipes
		pipe:update(dt)

		-- delete pipes if they go past screen
		if pipe.x < -pipe.width then
			table.remove(pipesController.pipes, k)
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

	-- draw bird
	bird:render()

	-- draw pipes
	for _, pipe in pairs(pipesController.pipes) do
		pipe:render()
	end

	-- drawing ground with infinite scrolling; .png is 100x50 px
	for i=0,144 do
		love.graphics.draw(ground.image,
			i*100 - ground.scrollAmount, WINDOW_HEIGHT - 50)
	end

end

-- Callback for game state and player controls
function love.keypressed(key)

	-- updating keysPressed tracker
	love.keyboard.keysPressed[key] = true

	-- game quit
	if key == 'escape' or key == 'q' then
		love.event.quit()
	end
end

-- Query func for keysPressed to check if 'key' was pressed or not
function love.keyboard.wasPressed(key)
	return love.keyboard.keysPressed[key]
end
