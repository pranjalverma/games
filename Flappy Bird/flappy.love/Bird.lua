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
	self.FLAP_ACCELERATION = -6 -- fair: -6, kinda unfair: -7/-8

	self.score = 0
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
	--love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
end

-- collision detection for pipes; acc. to pipe type
-- given offsets of 4 and 8 in x-direction
function Bird:collides(pipe)
	if pipe.type == 'bottom' then
		if ((self.x >= pipe.x + 4 and self.x <= pipe.x + pipe.width - 4) or
			(self.x + self.width - 2 >= pipe.x + 4 and
				self.x + self.width <= pipe.x + pipe.width - 4)) and
			(self.y + self.height >= pipe.y) then

			return true
		end
	else
		if ((self.x >= pipe.x - pipe.width + 4 and self.x <= pipe.x - 8) or
			(self.x + self.width >= pipe.x - pipe.width + 8 and
				self.x + self.width <= pipe.x - 4)) and
			(self.y <= pipe.y) then

			return true
		end
	end
end

-- update bird's score
function Bird:addScore(pipePair)
	if self.x >= pipePair.bottom.x + pipePair.bottom.width then
		self.score = self.score + 1
		pipePair.scored = true
	end
end

