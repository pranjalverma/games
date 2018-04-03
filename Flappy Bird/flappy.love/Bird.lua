--[[
	BIRD CLASS, USING middleclass.lua
	AUTHOR: PRANJAL VERMA
]]--

-- declare Bird class
Bird = class('Bird')

-- init
function Bird:initialize()
	self.image = love.graphics.newImage('Images/bird.png')
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.x = WINDOW_WIDTH / 2 - self.width / 2
	self.y = WINDOW_HEIGHT / 2 - self.height / 2

	self.dy = 0
	self.FLAP_ACCELERATION = -5
end

-- update bird's state
function Bird:update(dt)

	-- apply gravity to bird at all times
	self.dy = self.dy + (GRAVITY * dt)
	self.y = self.y + self.dy

	-- flap
	if love.keyboard.wasPressed('space') then
		self.dy = self.FLAP_ACCELERATION
	end
end

-- draw Bird
function Bird:render()
	love.graphics.draw(self.image, self.x, self.y)
end
