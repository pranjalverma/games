--[[
	PIPE CLASS, USING middleclass.lua
	AUTHOR: PRANJAL VERMA
]]--

-- declare Pipe class and pipe constants
Pipe = class('Pipe')
local PIPE_IMG = love.graphics.newImage('Images/pipe.png')
local PIPE_SCROLL = -60

-- init
function Pipe:initialize()
	self.x = WINDOW_WIDTH
	self.y = math.random(WINDOW_HEIGHT / 4, WINDOW_HEIGHT - 40)
	self.width = PIPE_IMG:getWidth()
end

-- update pipe's state
function Pipe:update(dt)
	self.x = self.x + (PIPE_SCROLL * dt)
end

-- draw pipe
function Pipe:render()
	love.graphics.draw(PIPE_IMG, self.x, self.y)
end
