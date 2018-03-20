--[[

SPACE INVADERS, IN LÖVE/Love2D
AUTHOR: PRANJAL VERMA

]]--

-- ADD AESTHETICS; SOUNDS, BACKGROUND MAYBE (?)
-- ADD RETRO PARTICLE EXPLOSION EFFECT
-- MAYBE ADD A CONF.LUA FILE; LOOK INTO OTHER FILE TYPES FOR LOVE

-- Game dimensions
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()

-- game state controller
local SpaceInvaders = {
	gameIntro = true,
	gameInstruct = false,
	gamePause = false,
	gameWin = false,
	gameOver = false
}

-- Player object
local player = {
	x = 0,
	y = 0,
	width = 55,
	height = 20,
	health = 5,
	speed = 5,
	bullets = {},
	cooldown = 0
}

-- Controller object for enemies
local enemies_controller = {
	enemies = {},
	formX = screenWidth/6.35 - 20,
	formY = screenHeight/10,
	enemyFireProb = 0.9994, --Probability Threshold for firing
	enemyTypes = {'1', 'B', 'C', 'j', 'n'},
	enemyWidths = {53, 45, 40, 40, 40}
}

-- Callback for game init
function love.load()

	-- font and related vars
	titlefont = love.graphics.newFont('invaders.from.space.ttf', 500)
	mediumfont = love.graphics.newFont('ca.ttf', 30)
	smallfont = love.graphics.newFont('ca.ttf', 15)
	spritefont = love.graphics.newFont('INVADERS.TTF', 30)
	smallspritefont = love.graphics.newFont('INVADERS.TTF', 15)
	centerx, centery = screenWidth/2 - 45, screenHeight/2

	-- following three chunks, incase of a restart
	SpaceInvaders.gameWin, SpaceInvaders.gameOver = false, false

	-- init player
	player.x = screenWidth/2 - player.width/2 - 7
	player.y = 3.5*screenHeight/4
	player.health = 5
	player.bullets = {}

	-- delete all existing enemies
	enemies_controller.enemies = {}

	-- spawn new enemies with their sprites, acc. to types and widths
	local typeCounter = 0
	for i = enemies_controller.formX, enemies_controller.formX + 550, 60 do
		for j = enemies_controller.formY, enemies_controller.formY + 250, 60 do

			typeCounter = typeCounter + 1
			if typeCounter > #enemies_controller.enemyTypes then
				typeCounter = 1
			end

			enemies_controller:spawnEnemy(i, j,
				enemies_controller.enemyTypes[typeCounter],
				enemies_controller.enemyWidths[typeCounter])
		end
	end

end

-- Callback for updating game state
function love.update(dt)

	-- don't update when game is paused or on intro screen or on instruction screen
	if SpaceInvaders.gamePause or SpaceInvaders.gameIntro or SpaceInvaders.gameInstruct then
		return
	end

	-- game over if player dies
	if player.health <= 0 then
		SpaceInvaders.gameOver = true
	end 

	-- checking is num of enemies remaining is zero, for game win
	if #enemies_controller.enemies == 0 then
		SpaceInvaders.gameWin = true
	end

	-- player bullet management: gun cooldown and bullet movement loop
	player.cooldown = player.cooldown - 1
	for i, b in ipairs(player.bullets) do
		b.y = b.y - b.speed

		-- deleting out-of-screen bullets, if any
		if b.y < -10 then
			table.remove(player.bullets, i)
		end
	end

	-- enemy control: movement, bullet management and checking for game over
	for _, e in pairs(enemies_controller.enemies) do

		-- movement
		if not SpaceInvaders.gameIntro then
			e.y = e.y + e.speed
		end

		-- bullet movement loop
		for i, b in ipairs(e.bullets) do
			b.y = b.y + b.speed

			-- deleting out-of-screen bullets, if any
			if b.y > screenHeight + 10 then
				table.remove(e.bullets, i)
			end
		end

		-- randomised enemy fire, with given fire probability
		if love.math.random() >= enemies_controller.enemyFireProb then
			fire(e)
		end

		-- game over if any enemy goes past us
		if e.y + e.height >= player.y then
			SpaceInvaders.gameOver = true
		end
	end

	-- managing collision b/w:
	-- player bullets and enemies
	-- enemy bullets and player
	detectCollision()

	-- player movement
	if love.keyboard.isDown('right') then
		player.x = player.x + player.speed

		-- edge condition
		if player.x + player.width > screenWidth then
			player.x = screenWidth - player.width
		end

	elseif love.keyboard.isDown('left') then
		player.x = player.x - player.speed

		-- edge condition
		if player.x < 0 then
			player.x = 0
		end

	end

	-- player gunfire 
	if love.keyboard.isDown('lshift') then
		fire(player)
	end

end

-- Callback for drawing updated game state on the screen
function love.draw()
	love.graphics.setColor(255, 255, 255)

	-- game instructions screen
	if SpaceInvaders.gameInstruct then
		love.graphics.setFont(mediumfont)
		love.graphics.print('<- -> - Move', centerx - 110, centery - 35)
		love.graphics.print('lshift - Shoot', centerx - 110, centery + 5)
		return

	-- game intro screen
	elseif SpaceInvaders.gameIntro then
		love.graphics.setFont(titlefont)
		love.graphics.print('A', centerx - 213, centery - 200)

		love.graphics.setFont(smallfont)
		love.graphics.print('Press Enter to save the Earth!', centerx - 113, centery + 130)
		love.graphics.print('Press i to toggle instructions', screenWidth - 332, 7)

		love.graphics.print('Made with LÖVE by Pranjal Verma',
			screenWidth - 345, screenHeight - 17)
		return

	-- game win screen
	elseif SpaceInvaders.gameWin then
		love.graphics.setFont(mediumfont)
		love.graphics.print('You won!',
			centerx - 38, centery - 10)
		
	-- game over screen
	elseif SpaceInvaders.gameOver then
		love.graphics.setColor(255, 0, 0)
		love.graphics.setFont(mediumfont)
		love.graphics.print('Game Over', centerx - 63, centery - 10)
		return
	end

	-- drawing player lives
	love.graphics.setFont(smallfont)
	love.graphics.print('LIVES ', 5, 8)
	love.graphics.setFont(smallspritefont)
	for i=1, player.health do
		love.graphics.print('2', 35 + 30*i, 10)
	end

	-- drawing player sprite
	love.graphics.setFont(spritefont)
	love.graphics.print('2', player.x, player.y)

	-- drawing player bullets
	for _, b in pairs(player.bullets) do
		love.graphics.rectangle('fill', b.x, b.y, b.width, b.height)
	end

	-- drawing enemies and their bullets
	love.graphics.setColor(255, 0, 0)
	for i, e in ipairs(enemies_controller.enemies) do
		love.graphics.print(e.enemyType, e.x, e.y)

		-- drawing bullets
		for _, b in pairs(e.bullets) do 
			love.graphics.rectangle('fill', b.x, b.y, b.width, b.height)
		end
	end

	-- game pause screen
	if SpaceInvaders.gamePause then
		love.graphics.setColor(255, 255, 255)
		love.graphics.setFont(mediumfont)
		love.graphics.print('Paused', centerx - 28, centery - 10)
	end

end

-- Callback for game state controls
function love.keypressed(key)

	-- game start
	if key == 'return' and SpaceInvaders.gameIntro then
		SpaceInvaders.gameIntro = false
	end

	-- game restart
	if key == 'space' and (SpaceInvaders.gameOver or SpaceInvaders.gameWin) then
		love.load()
	end

	-- game pause
	if key == 'p' and
		(not SpaceInvaders.gameIntro and
		not SpaceInvaders.gameWin and
		not SpaceInvaders.gameOver) then

		SpaceInvaders.gamePause = not SpaceInvaders.gamePause
	end

	if key == 'i' then
		SpaceInvaders.gameInstruct = not SpaceInvaders.gameInstruct
	end

	-- game quit
	if key == 'escape' or key == 'q' then
		love.event.quit()
	end

end

-- Fire function for player and enemies
function fire(obj)

	-- fires after cooldown counter is 0
	if obj.cooldown <= 0 then
		obj.cooldown = 20

		-- bullet object
		bullet = {
			x = 0,
			y = 0,
			width = 5,
			height = 10,
			speed = 6
		}

		bullet.x = obj.x + obj.width / 2 - bullet.width / 2
		bullet.y = obj.y

		table.insert(obj.bullets, bullet)
	end

end

-- Function for spawning enemies
function enemies_controller:spawnEnemy(x, y, enemyType, enemyWidth)

	-- enemy object
	enemy = {
		x = x,
		y = y,
		width = enemyWidth, 
		height = 40,
		speed = 0.09,
		enemyType = enemyType,
		bullets = {},
		cooldown = 0
	}
	
	table.insert(self.enemies, enemy)
end


-- Collision detection b/w bullets and other game objects; naïve
function detectCollision()

	-- loop over all enemies
	for i, e in ipairs(enemies_controller.enemies) do

		-- collision b/w player bullets and enemies
		for j, pb in ipairs(player.bullets) do

			if ((pb.x >= e.x and pb.x <= e.x + e.width) or
				(pb.x + pb.width >= e.x and pb.x + pb.width <= e.x + e.width)) and
				(pb.y <= e.y + e.height) then

				table.remove(enemies_controller.enemies, i)
				table.remove(player.bullets, j)
			end

			-- collision b/w player bullets and enemy bullets
			for k, eb in ipairs(e.bullets) do

				if ((pb.x >= eb.x - 2 and pb.x <= eb.x + eb.width + 2) or
					(pb.x + pb.width >= eb.x - 2 and pb.x + pb.width <= eb.x + eb.width + 2)) and
					(pb.y <= eb.y + eb.height) then

					table.remove(e.bullets, k)
					table.remove(player.bullets, j)
				end

			end

		end

		-- collision b/w enemy bullets and player
		for k, b in ipairs(e.bullets) do

			if ((b.x >= player.x and b.x <= player.x + player.width) or
				(b.x + b.width >= player.x and b.x + b.width <= player.x + player.width)) and
				(b.y + b.height >= player.y) then

				table.remove(e.bullets, k)
				player.health = player.health - 1
			end

		end

	end
end
