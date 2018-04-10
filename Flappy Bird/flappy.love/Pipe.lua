--[[
	PIPE CLASS, USING middleclass.lua
	AUTHOR: PRANJAL VERMA
]]--

-- declare Pipe class and related constants
Pipe = class('Pipe')
local PIPE_IMG = love.graphics.newImage('Images/pipe.png')

-- init
function Pipe:initialize(type, y)
	self.type = type
	self.width = PIPE_IMG:getWidth()
	self.height = PIPE_IMG:getHeight()

	if self.type == 'bottom' then
		self.x = WINDOW_WIDTH
	else
		self.x = WINDOW_WIDTH + self.width
	end
	self.y = y

	self.PIPE_SCROLL_X = -160
	self.pipeScrollY = 50
	self.Y_SCROLL_TIME = 2 -- in seconds
	self.yScrollTimer = 0
	self.difficultyTimer = 0
	self.DIFFICULTY_RAISE_TIME = 3 
end

-- update pipe's state
function Pipe:update(dt, score)

	-- x direction scroll
	self.x = self.x + (self.PIPE_SCROLL_X * dt)

	-- y direction scroll for difficulty; using yScrollTimer
	if score > 5 then
		self.y = self.y + (self.pipeScrollY * dt)

		-- flip direction
		self.yScrollTimer = self.yScrollTimer + dt
		if self.yScrollTimer > self.Y_SCROLL_TIME then
			self.pipeScrollY = -self.pipeScrollY
			self.yScrollTimer = 0
		end
		
	end

end

-- draw pipe acc. to it's type
function Pipe:render()
	if self.type == 'bottom' then
		love.graphics.draw(PIPE_IMG, self.x, self.y)

		-- sanity checks
		--love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
	else
		love.graphics.draw(PIPE_IMG, self.x, self.y, math.rad(180))

		-- sanity checks
		--[[
		love.graphics.rotate(math.rad(180))
		love.graphics.rectangle('line', -self.x, -self.y, self.width, self.height)
		love.graphics.rotate(-math.rad(180))
		]]--
	end
end
