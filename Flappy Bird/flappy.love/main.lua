--[[

FLAPPY BIRD, IN LÖVE/Love2D
AUTHOR: PRANJAL VERMA

]]--

-- Game Dimensions
WINDOW_WIDTH, WINDOW_HEIGHT = 1440, 900

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
}

-- Callback for game init
function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')
end

-- Callback for updating game state
function love.update(dt)

	-- backdrop scroll amount; fps independent
	backdrop.scrollAmount = (backdrop.scrollAmount + backdrop.SCROLL_SPEED * dt)
							% WINDOW_WIDTH

end

-- Callback for drawing updated game state on the screen
function love.draw()

	-- drawing backdrop with infinite scrolling
	love.graphics.draw(backdrop.image, -backdrop.scrollAmount, 0)
	love.graphics.draw(backdrop.image, WINDOW_WIDTH - backdrop.scrollAmount, 0)
end

-- Callback for game state controls
function love.keypressed(key)

	-- game quit
	if key == 'escape' or key == 'q' then
		love.event.quit()
	end
end
