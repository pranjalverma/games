import pygame
from random import randrange

pygame.init()

#display management
display_width = display_height = 800
gameDisplay = pygame.display.set_mode((display_width, display_height))
pygame.display.set_caption('Slither!')
green = [0, 155, 0]

#clock and size of snake and apples
clock = pygame.time.Clock()
block_size = 20
FPS = 144

#fonts
smallfont = pygame.font.Font('game_over.ttf', 50)
mediumfont = pygame.font.Font('game_over.ttf', 75)
largefont = pygame.font.Font('game_over.ttf', 200)

#game sounds
sounds = []
sounds.append(pygame.mixer.Sound('undertale ost intro.wav'))
sounds.append(pygame.mixer.Sound('Super_Mario_coin_sound_.wav'))
sounds.append(pygame.mixer.Sound('donkey kong death sound.wav'))

#intro screen
def gameIntro():
	intro = True
	sounds[0].play(loops=-1)

	while intro:
		for event in pygame.event.get():
			if event.type == pygame.QUIT:
				pygame.quit()
				quit()

			elif event.type == pygame.KEYDOWN:
				if event.key == pygame.K_RETURN:
					intro = False

				elif event.key == pygame.K_q:
					pygame.quit()
					quit()

		gameDisplay.fill(pygame.Color('black'))

		for i in range(10):
			showMessage('~',
				pygame.Color('white'),
				(randrange(0, display_width), randrange(0, display_height)),
				'small')

		showMessage('Welcome to Slither!',
			green,
			(display_width/2, display_height/2 - 100),
			'large')

		showMessage('Press ENTER to start eating or Q to quit',
			pygame.Color('red'),
			(display_width/2, display_height/2),
			'medium')

		showMessage('Made by Pranjal Verma',
			pygame.Color('white'),
			(685, 785),
			'small')

		pygame.display.update()
		clock.tick(8)

#game screen
def gameLoop():
	gameExit = gameOver = False

	lead_x, lead_y = display_width/2, display_height/2
	lead_x_change = lead_y_change = 0

	appleX, appleY = genApple()

	snakeBody = []
	snakeLength = 1

	#main loop
	while not gameExit:

		#gameover loop
		while gameOver:
			sounds[0].stop()
			gameDisplay.fill(pygame.Color('black'))

			showMessage('Game Over', 
				pygame.Color('red'),
				(display_width/2, display_height/2 - 50),
				'large')

			showMessage('Press SPACE to play again or Q to quit',
				pygame.Color('white'),
				(display_width/2, display_height/2 + 50),
				'medium')

			showMessage('Score: ' + str(snakeLength - 1),
				pygame.Color('white'),
				(45, 15),
				'small')

			pygame.display.update()

			for event in pygame.event.get():
				if event.type == pygame.KEYDOWN:
					if event.key == pygame.K_q or event.key == pygame.K_ESCAPE:
						gameExit = True
						gameOver = False

					elif event.key == pygame.K_SPACE:
						sounds[2].stop()
						sounds[0].play(loops=-1)
						gameLoop()

				elif event.type == pygame.QUIT:
					gameExit = True
					gameOver = False

		#main loop event handling; moving snake
		for event in pygame.event.get():
			if event.type == pygame.QUIT:
				gameExit = True

			if event.type == pygame.KEYDOWN:
				if event.key == pygame.K_ESCAPE:
					gameExit = True

				elif event.key == pygame.K_p:
					pause(snakeBody, appleX, appleY)

				elif event.key == pygame.K_LEFT:
					lead_x_change = -block_size
					lead_y_change = 0

				elif event.key == pygame.K_RIGHT:
					lead_x_change = block_size
					lead_y_change = 0

				elif event.key == pygame.K_UP:
					lead_y_change = -block_size
					lead_x_change = 0

				elif event.key == pygame.K_DOWN:
					lead_y_change = block_size
					lead_x_change = 0

		#crossing edges
		if lead_x > display_width:
			lead_x = 0
		elif lead_x < 0:
			lead_x = display_width

		if lead_y > display_height:
			lead_y = 0
		elif lead_y < 0:
			lead_y = display_height
		
		lead_x += lead_x_change
		lead_y += lead_y_change

		gameDisplay.fill(pygame.Color('black'))
		gameDisplay.fill(pygame.Color('red'), rect=[appleX, appleY, block_size, block_size])

		#building snake
		snakeBody.append([lead_x, lead_y])

		#restricting snake length in accordance to apples eaten
		if len(snakeBody) > snakeLength:
			del snakeBody[0]

		#checking if snake ran into itself
		for bodyPart in snakeBody[:-1]:
			if bodyPart == snakeBody[-1]:
				sounds[2].play()
				gameOver = True

		drawSnake(block_size, snakeBody)

		showMessage('Score: ' + str(snakeLength - 1),
			pygame.Color('white'),
			(45, 15),
			'small')

		showMessage('Press P to pause game',
			pygame.Color('white'),
			(683, 15),
			'small')

		pygame.display.update()

		#collision detection for snake head and apple
		if ((appleX <= lead_x <= appleX + block_size and appleY <= lead_y <= appleY + block_size)
		or (appleX <= lead_x + block_size <= appleX + block_size and appleY <= lead_y + block_size <= appleY + block_size)
		or (appleX <= lead_x <= appleX + block_size and appleY <= lead_y + block_size <= appleY + block_size)
		or (appleX <= lead_x + block_size <= appleX + block_size and appleY <= lead_y <= appleY + block_size)):
			sounds[1].play()
			appleX, appleY = genApple()
			snakeLength += 1

		clock.tick(FPS)

	pygame.quit()
	quit()

#pause screen
def pause(snakeBody, appleX, appleY):
	paused = True
	gameDisplay.fill(pygame.Color('black'), rect=[560, 0, 250, 40])
	gameDisplay.fill(pygame.Color('red'), rect=[appleX, appleY, block_size, block_size])
	drawSnake(block_size, snakeBody)

	while paused:
		for event in pygame.event.get():
			if event.type == pygame.QUIT:
				pygame.quit()
				quit()

			if event.type == pygame.KEYDOWN:
				if event.key == pygame.K_ESCAPE:
					pygame.quit()
					quit()

				elif event.key == pygame.K_p:
					paused = False

			showMessage('Paused',
				pygame.Color('white'),
				(display_width/2, display_height/2 - 50),
				'large')

			showMessage('Press P to unpause game',
				pygame.Color('white'),
				(display_width/2, display_height/2),
				'small')

			pygame.display.update()
			clock.tick(5)

#showing snake on screen
def drawSnake(block_size, snakeBody):
	for bodyPart in snakeBody:
		gameDisplay.fill(green, rect=[bodyPart[0], bodyPart[1], block_size, block_size])

#generate an apple
def genApple():
	appleX = randrange(0, display_width - block_size)
	appleY = randrange(0, display_height - block_size)
	return appleX, appleY

#choose and render font
def text_objects(msg, color, size):
	if size == 'small':
		textSurface = smallfont.render(msg, True, color)
	elif size == 'medium':
		textSurface = mediumfont.render(msg, True, color)
	elif size == 'large':
		textSurface = largefont.render(msg, True, color)

	return textSurface, textSurface.get_rect()

#use rendered font to show message on screen
def showMessage(msg, color, coords, size):
	textSurface, textRect = text_objects(msg, color, size)
	textRect.center = coords
	gameDisplay.blit(textSurface, textRect)

gameIntro()
gameLoop()
