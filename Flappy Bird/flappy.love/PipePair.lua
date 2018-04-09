--[[
	PIPEPAIR CLASS, USING middleclass.lua
	AUTHOR: PRANJAL VERMA
]]--

-- declare PipePair class and related constants
PipePair = class('PipePair')

-- init; procedural generation of pipes 
function PipePair:initialize()
	self.PIPE_Y_GAP = 150
	self.y = math.random(200, WINDOW_HEIGHT - 400)
	self.top = Pipe('top', self.y)
	self.bottom = Pipe('bottom', self.y + self.PIPE_Y_GAP)
	self.scored = false
end
