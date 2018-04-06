--[[

FLAPPY BIRD, IN LÖVE/Love2D
AUTHOR: PRANJAL VERMA

]]--

-- USE LÖVELYMOON

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

local gameOver = false

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
	gameOver = false

	-- creating table to track single key presses, frame by frame
	love.keyboard.keysPressed = {} 
end

-- Callback for updating game state
function love.update(dt)

	-- test code
	if gameOver then
		return
	end

	-- backdrop and ground scroll amount
	backdrop.scrollAmount = (backdrop.scrollAmount + backdrop.SCROLL_SPEED * dt)
							% backdrop.LOOPING_POINT
	ground.scrollAmount = (ground.scrollAmount + ground.SCROLL_SPEED * dt)
							% ground.LOOPING_POINT

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

		if not pipePair.scored then
			bird:addScore(pipePair)
		end

		-- collision detection
		if bird:collides(pipePair.top) or bird:collides(pipePair.bottom) then
			gameOver = true
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

	love.graphics.print('Score: ' .. bird.score, 5, 5)

end

-- Callback for game state and player controls
function love.keypressed(key)

	-- updating keysPressed tracker
	love.keyboard.keysPressed[key] = true

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
