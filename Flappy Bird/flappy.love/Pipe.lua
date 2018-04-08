--[[
	PIPE CLASS, USING middleclass.lua
	AUTHOR: PRANJAL VERMA
]]--

-- declare Pipe class and related constants
Pipe = class('Pipe')
local PIPE_IMG = love.graphics.newImage('Images/pipe.png')
local PIPE_SCROLL = -160

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
end

-- update pipe's state
function Pipe:update(dt)
	self.x = self.x + (PIPE_SCROLL * dt)
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
