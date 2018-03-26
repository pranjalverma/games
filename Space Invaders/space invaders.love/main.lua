--[[

SPACE INVADERS, IN LÖVE/Love2D
AUTHOR: PRANJAL VERMA

]]--

-- Game dimensions and inits
love.window.setMode(1440, 900)
love.window.setFullscreen(true)
love.window.setTitle('Space Invaders')
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()

-- game state controller
local SpaceInvaders = {
	gameIntro = true,
	gameInstruct = false,
	gameBoss = false,
	gamePause = false,
	gameMute = false,
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
	cooldown = 0,
	hitOnce = false
}

-- Controller object for enemies
local enemies_controller = {
	enemies = {},
	formX = (screenWidth - 590)/2,
	formY = screenHeight/4,
	enemyFireProb = 0.9994, --Probability Threshold for firing
	enemyTypes = {'s', 'B', 'C', 'j', 'n'},
	bossType = '1',
	enemyWidths = {45, 50, 40, 40, 40},
	dead = {}
}

-- font and related vars
local titlefont = love.graphics.newFont('Sprites/invaders.from.space.ttf', 500)
local explosionfont = love.graphics.newFont('Sprites/invaders.from.space.ttf', 40)
local mediumfont = love.graphics.newFont('Fonts/ca.ttf', 30)
local smallfont = love.graphics.newFont('Fonts/ca.ttf', 15)
local spritefont = love.graphics.newFont('Sprites/INVADERS.TTF', 30)
local smallspritefont = love.graphics.newFont('Sprites/INVADERS.TTF', 15)
local centerx, centery = screenWidth/2 - 45, screenHeight/2

-- game sounds and music
local fireSound = love.audio.newSource('Audio/fire_sound.ogg')
fireSound:setVolume(0.05)
local gameMusic = love.audio.newSource('Audio/space_invaders.ogg')
gameMusic:setVolume(1)
gameMusic:setLooping(true)

-- Callback for game init
function love.load()

	-- start game music
	gameMusic:rewind()
	gameMusic:play()

	-- following three chunks, incase of a restart
	SpaceInvaders.gameWin, SpaceInvaders.gameOver = false, false

	-- init player
	player.x = screenWidth/2 - player.width/2 - 7
	player.y = 3.5*screenHeight/4
	player.health = 5
	player.bullets = {}

	-- init boss
	SpaceInvaders.gameBoss = false

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

	-- Muting game music; fireSound can't be paused like this cuz it needs to be playing to be paused
	if SpaceInvaders.gameMute then
		love.audio.pause(gameMusic)
	else
		love.audio.resume(gameMusic)
	end

	-- don't update when game is paused or on intro screen or on instruction screen
	if SpaceInvaders.gamePause or SpaceInvaders.gameIntro or SpaceInvaders.gameInstruct then
		return
	end

	-- game over if player dies
	if player.health <= 0 then
		SpaceInvaders.gameOver = true
	end

	-- sprite management if player is hit
	if player.hitOnce then
		love.timer.sleep(0.5)
		player.hitOnce = false
	end

	-- checking is num of enemies remaining is zero, for boss phase
	if #enemies_controller.enemies == 0 and not SpaceInvaders.gameBoss then
		SpaceInvaders.gameBoss = true
		enemies_controller:spawnBoss()
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

	-- enemy control: movement, bullet management and checking for game win/over
	for j, e in ipairs(enemies_controller.enemies) do

		-- managing enemy fire cooldown
		e.cooldown = e.cooldown - 1

		-- boss management; movement; stepsY used for smooth Y motion
		if SpaceInvaders.gameBoss then

			if e.x <= 250 or e.x >= screenWidth - 250 then
				if e.stepsY == e.maxStepsY then
					e.speedx = (-1) * e.speedx
					e.x = e.x + e.speedx
					e.stepsY = 1
				else
					e.y = e.y + e.speedy
					e.stepsY = e.stepsY + 1
				end
			else
				e.x = e.x + e.speedx
				fire(e)
			end

			-- checking if boss defeated, for game win!
			if e.health <= 0 then
				table.insert(enemies_controller.dead, e)
				table.remove(enemies_controller.enemies, j)
				SpaceInvaders.gameWin = true
				return
			end

		-- normal enemy movement
		elseif not SpaceInvaders.gameIntro then
			e.y = e.y + e.speedy
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

	-- player gunfire acc. to gameMute
	if love.keyboard.isDown('lshift') then
		if not SpaceInvaders.gameMute then
			fireSound:play()
		end

		fire(player)
	end

end

-- Callback for drawing updated game state on the screen
function love.draw()
	love.graphics.setColor(255, 255, 255)

	-- game instructions screen
	if SpaceInvaders.gameInstruct then
		love.graphics.setFont(mediumfont)
		love.graphics.print('<- -> - Move', centerx - 110, centery - 95)
		love.graphics.print('lshift - Shoot', centerx - 110, centery - 55)
		love.graphics.print('M - Mute', centerx - 110, centery - 15)
		love.graphics.print('SPACE - Restart', centerx - 110, centery + 25)
		love.graphics.print('ESC or Q - Exit', centerx - 110, centery + 65)
		love.graphics.print('P - Pause', centerx - 110, centery + 105)
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

	-- drawing player sprite and managing sprite if hit
	if player.hitOnce then
		love.graphics.setFont(explosionfont)
		love.graphics.print('X', player.x, player.y)
	else
		love.graphics.setFont(spritefont)
		love.graphics.print('2', player.x, player.y)
	end

	-- drawing player bullets
	for _, b in pairs(player.bullets) do
		love.graphics.rectangle('fill', b.x, b.y, b.width, b.height)
	end

	-- drawing enemies and their bullets
	love.graphics.setColor(255, 0, 0)
	love.graphics.setFont(spritefont)
	for i, e in ipairs(enemies_controller.enemies) do
		love.graphics.print(e.enemyType, e.x, e.y)

		-- drawing bullets
		for _, b in pairs(e.bullets) do 
			love.graphics.rectangle('fill', b.x, b.y, b.width, b.height)
		end
	end

	-- drawing explosions for dead enemies
	love.graphics.setFont(explosionfont)
	for i, e in ipairs(enemies_controller.dead) do
		love.graphics.print('Z', e.x, e.y)
		love.timer.sleep(0.05)
		table.remove(enemies_controller.dead, i)
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
	if key == 'space' and not (SpaceInvaders.gameIntro or SpaceInvaders.gameInstruct) then
		love.load()
	end

	-- game pause
	if key == 'p' and
		(not SpaceInvaders.gameIntro and
		not SpaceInvaders.gameWin and
		not SpaceInvaders.gameOver) then

		SpaceInvaders.gamePause = not SpaceInvaders.gamePause
	end

	-- game instructions
	if key == 'i' then
		SpaceInvaders.gameInstruct = not SpaceInvaders.gameInstruct
	end

	-- mute music and sounds
	if key == 'm' then
		SpaceInvaders.gameMute = not SpaceInvaders.gameMute
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
		local bullet = {
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
	local enemy = {
		x = x,
		y = y,
		width = enemyWidth, 
		height = 40,
		speedx = 0,
		speedy = 0.35, -- 0.35
		enemyType = enemyType,
		bullets = {},
		cooldown = 0
	}
	
	table.insert(self.enemies, enemy)
end

-- Function for spawning boss after all enemies are defeated
function enemies_controller:spawnBoss()

	--boss object
	local boss = {
		x = 0,
		y = 0,
		width = 53,
		height = 40,
		health = 47,
		speedx = 3,
		speedy = 3,
		stepsY = 1,
		maxStepsY = 50,
		enemyType = enemies_controller.bossType,
		bullets = {},
		cooldown = 0
	}

	boss.x = screenWidth/4 - boss.width/2
	boss.y = 0

	table.insert(self.enemies, boss)

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

				if SpaceInvaders.gameBoss then
					e.health = e.health - 1
				else
					table.insert(enemies_controller.dead, e)
					table.remove(enemies_controller.enemies, i)
				end
				
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
				player.hitOnce = true
			end

		end

	end
end
