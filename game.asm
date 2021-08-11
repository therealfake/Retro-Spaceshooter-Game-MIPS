#####################################################################
#
# CSC258 Summer 2021 Assembly Final Project
# University of Toronto
#
# Student: Tianji Zhang, 1007405808, zha10311
# Student: Longyue Wang, 1007041915, wanglo18
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1
# - Milestone 2
# - Milestone 3 
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. Difficulty increase over time
# 2. Grazing
# 3. Scoring system

#
# Link to video demonstration for final submission:
# https://play.library.utoronto.ca/watch/c771f75cedd20ccc78f4f3281774c3cb
#
# Are you OK with us sharing the video with people outside course staff?
# yes
# Any additional information that the TA needs to know:
# - We added added a cool start screen that we would like to be considered for extra credit.
#
#####################################################################
#adresses
.eqv baseAddress 0x10008000 		# base address for the display
.eqv keystrokeAddress 0xffff0000 	# memory address for the keystroke event / if a key has been pressed
#colors
.eqv lightBrown 0xa0522d 		# asteroid color
.eqv darkBrown 0x654321 		# asteroid color
.eqv white 0xffffff 			# ship colour	
.eqv grey 0x808080 			#ship colour
.eqv red 0xff0000 			# game over message colour
.eqv green 0x00ff00 		# game over screen "score" colour
.eqv black 0x000000
.eqv yellow 0xffff00 
#ascii values for keyboard input
.eqv w_ASCII 0x77 			# ascii value for w in hex
.eqv a_ASCII 0x61			# ascii value for a in hex
.eqv s_ASCII 0x73 			# ascii value for s in hex
.eqv d_ASCII 0x64 			# ascii value for d in hex
.eqv p_ASCII 0x70 			# ascii value for p in hex

.data
ship: .word 6, 12		 	#x, y coordinates of the top right corner of the ship and then the y coordinates of the left and right wing.
obstacle: .word 0, 0		#x, y coordinates of the obstacle
health: .word 160 #160		# current health of the ship
positions: .word 0, 0, 0, 0, 0	#Contains the positions of all the obstacles, position [0] stores collisions
misc: .word 0, 0, 0, 0, 0		#contains various values that required storage, temporary or otherwise	
dspwn1: .word 0, 0, 0, 0, 0		#Contains the distance from the point at which the obstacle needs to vanish and be generated again elsewhere
screen: .word 31, 0			# x, y coordinates for drawing the screen black	
#start screen stuff
start: .word 25, 10 		# x,y coordinates of the top right of the word "start"
s_game: .word 23, 16 		# x,y coordinates of the top right of the word "game" 
# game over screen stuff
ggsMessage: .word 0,0
#obstacle: .word 0, 0 		#x, y coordinates of the obstacle
game: .word 18, 4 			# x,y coordinates of the top right of the word "game" 
over: .word 28, 10 			# x,y coordinates of the top right of the word "end"
score: .word 23, 16 		# x,y coordinates of the top right of the word "score"
symbol_1: .word 6, 23 		# x, y coordinates for drawing score symbols
symbol_2: .word 12, 23
symbol_3: .word 18, 23
symbol_4: .word 24, 23
symbol_5: .word 30, 23	
.text
startGamePhase:
	jal drawStartGame
	addi $0, $0, 0
	
	li $v0,32
	li $a0,1000
	syscall
	
	jal animateShip
	addi $0, $0, 0
	j createShip
	addi $0, $0, 0
	
animateShip:
	la $t0, ship
	lw $t1, 0($t0)
	beq $t1, 31, createShip
	addi $0, $0, 0
	la $t0, grey 			# load the grey colour
	addi, $sp, $sp, -4 			# move stack up
	sw $t0, 0($sp) 			# store white into the stack
	
	la $t0, white			# load the white colour
	addi, $sp, $sp, -4 			# move stack up
	sw $t0, 0($sp) 			# store white into the stack
	
	jal drawShip
	addi $0, $0, 0
	li $v0,32
	li $a0,50
	syscall
	jal clearShip
	addi $0, $0, 0
	
	la $t0, ship
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)
	
	j animateShip
	addi $0, $0, 0
	
createShip:
	jal drawBlackScreen
	la $t0, ship
	addi $t1, $zero, 6
	sw $t1, 0($t0)
	addi $t1, $zero, 12
	lw $t2, 0($t0)
	
	la $t0, grey 			# load the grey colour
	addi, $sp, $sp, -4 			# move stack up
	sw $t0, 0($sp) 			# store white into the stack
	
	la $t0, white			# load the white colour
	addi, $sp, $sp, -4 			# move stack up
	sw $t0, 0($sp) 			# store white into the stack
	
	jal drawShip
	addi $0, $0, 0
	
makeEnemies:				#Create three obstacles at three random locations	
	la $k0, positions			#Initialize the two arrys into registers
	la $k1, dspwn1					
	la $a3, misc
	jal enemyLocation
	addi $0, $0, 0
	jal enemyLocation
	addi $0, $0, 0
	jal enemyLocation
	addi $0, $0, 0
createHealth:
	jal drawHealth
	addi $0, $0, 0
main:
	li $t9, keystrokeAddress 		# load the keystroke event address into $t9
	lw $t8, 0($t9) 
	beq $t8, 1, keypress_happened 	# check if they keystroke event occurred.
	addi $0, $0, 0
	jal moveEnemies
	addi $0, $0, 0
	jal CheckCollision
	addi $0, $0, 0
	j main
	addi $0, $0, 0
	
#################################################################################################################################################
# Ship
#################################################################################################################################################
drawShip:
	lw $s0, 0($sp) 			# load the white color into $s0
	addi $sp, $sp, 4			# move stack down
	lw $s1, 0($sp) 			# load the white color into $s1
	addi $sp, $sp, 4			# move stack down
	la $s2, ship 			# $s2 load the top right corner of the ship
	lw $s3, 0($s2)			# $s3 has the x coordinate
	lw $s4, 4($s2)			# $s4 holds the y coordinate
	sll $s4, $s4, 5			# $s4 holds y * 32
	add $s4, $s4, $s3			# $s4 holds y * 32 + x
	sll $s4, $s4, 2 			# $s4 holds 4 * (y * 32 + x)
	add $s5, $s4, $zero
	la $s5, baseAddress		
	add $s5, $s5, $s4
	
	sw $s0, -8($s5)
	addi $s5, $s5, 128			# move to next row
	
	sw $s0, -8($s5)
	sw $s0, -12($s5)
	addi $s5, $s5, 128			# move to next row
	
	sw $s0, -4($s5)
	sw $s0, -8($s5)
	sw $s0, -12($s5)
	sw $s0, -16($s5)
	sw $s0, -24($s5)
	addi $s5, $s5, 128			# move to next row
	
	sw $s0, 0($s5)
	sw $s0, -4($s5)
	sw $s1, -8($s5)
	sw $s1, -12($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -24($s5)	
	addi $s5, $s5, 128			# move to next row
	
	sw $s0, -4($s5)
	sw $s0, -8($s5)
	sw $s0, -12($s5)
	sw $s0, -16($s5)
	sw $s0, -24($s5)
	addi $s5, $s5, 128			# move to next row
	
	sw $s0, -8($s5)
	sw $s0, -12($s5)
	addi $s5, $s5, 128			# move to next row
	
	sw $s0, -8($s5)
	
	jr $ra
	addi $0, $0, 0
#################################################################################################################################################
# Obstacles
#################################################################################################################################################
		
moveEnemies:				#Move the obstacles forward one pixel
	addi $sp, $sp, -4			# move stack up
	sw $ra, 0($sp)
	
	jal moveEnemy1			#Draw each obstacle while updating their position in the array
	addi $0, $0, 0
	jal moveEnemy2
	addi $0, $0, 0
	jal moveEnemy3
	addi $0, $0, 0
	
	li $v0, 32			#Sleep the simulator to slow eveerything down
	li $a0, 100
	syscall
	
	jal cleanEnemy1			#"Clear" the enemy by redrawing their position in black
	addi $0, $0, 0
	jal cleanEnemy2
	addi $0, $0, 0
	jal cleanEnemy3
	addi $0, $0, 0
	
	lw $t8, 0($k1)
	li $t9, 30
	bgt $t8, $t9, S3
	addi $0, $0, 0
	addi $t9, $t9, -15
	bgt $t8, $t9, S2
	addi $0, $0, 0
	j S1
	addi $0, $0, 0
	
S1:	li $t8, 1
	sw $t8, 0($a3)	

	lw $t8, 4($k0)			#Increment the positions of each obstacle by shifting them one pixel to the left
	addi $t8, $t8, -4
	sw $t8, 4($k0)
	
	lw $t8, 8($k0)
	addi $t8, $t8, -4
	sw $t8, 8($k0)
	
	lw $t8, 12($k0)
	addi $t8, $t8, -4
	sw $t8, 12($k0)
	j contt
	addi $0, $0, 0
	
S2: 	li $t8, 0
	sw $t8, 0($a3)	
	
	lw $t8, 4($k0)			#Increment the positions of each obstacle by shifting them two pixels to the left (speed 2)
	addi $t8, $t8, -8
	sw $t8, 4($k0)
	
	lw $t8, 8($k0)
	addi $t8, $t8, -8
	sw $t8, 8($k0)
	
	lw $t8, 12($k0)
	addi $t8, $t8, -8
	sw $t8, 12($k0)
	j contt
	addi $0, $0, 0
	
S3: 	li $t8, -1
	sw $t8, 0($a3)	
	
	li $t8, 1
	sw $t8, 12($a3)
	
	lw $t8, 4($k0)			#Increment the positions of each obstacle by shifting them three pixels to the left (speed 3)
	addi $t8, $t8, -12
	sw $t8, 4($k0)
	
	lw $t8, 8($k0)
	addi $t8, $t8, -12
	sw $t8, 8($k0)
	
	lw $t8, 12($k0)
	addi $t8, $t8, -12
	sw $t8, 12($k0)

	j contt
	addi $0, $0, 0
	
contt:	jal checkDespawn			#Jumps to the portion of the code which checks to see if an obstacle should be removed
	addi $0, $0, 0
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4			# move stack down
	#j main				#Jump back to the main loop
	jr $ra
	addi $0, $0, 0

enemyLocation:
	addi $sp, $sp, -4 			# move stack up
	sw $ra, 0($sp) 			# save the return address
	
	li $v0, 42         			# Service 42, random int range
	li $a0, 0          			# Select random generator 0
	li $a1, 26		   	# Upper bound of random number generator is 30
	syscall            			# Generate random int (returns in $a0)
	
	la $t0, obstacle 			#$t0 holds the address of the enemy's top right corner
	sw $a0, 4($t0) 			#save random y coordinate into enemy array
	
	li $v0, 42        			# Service 42, random int range
	li $a0, 0          			# Select random generator 0
	li $a1, 2	 			# Upper bound of random number generator is 2
	syscall            			# Generate random int (returns in $a0)
	
	addi $a0, $a0, 29 			# random int between 29 and 31
	sw $a0, 0($t0) 			#save random x coordinate (between 16 and 32) into the enemy array
	
	la $t0, darkBrown  			# $t0 stores the dark brown colour
	addi $sp, $sp, -4 			# move up stack
	sw $t0, 0($sp) 			#store the rdark brown colour into the stack
	
	la $t0, lightBrown 			# t0 stores the light brown colour
	addi $sp, $sp, -4 			# move up stack
	sw $t0, 0($sp) 			#store the light brown colour into the stack
	
	jal drawEnemy
	addi $0, $0, 0
	
	lw $ra, 0($sp) 			# restor this function's return adress
	addi $sp, $sp, 4 			# move the stack down
	
	jr $ra
	addi $0, $0, 0
	


drawEnemy: 
	lw $t0, 0($sp) 			# $t0 holds colour popped off from the stack
	addi $sp, $sp, 4 			# update stack down
	lw $t4, 0($sp) 			# $t4 holds colour popped off from the stack
	addi $sp, $sp, 4 			# update stack down
	la $t1, baseAddress 		# $t1 has the display address
	la $t2, obstacle 			# $t2 holds the top right corner of the enemy block
	lw $t2, 4($t2) 			# $t2 holds the y coordinate
	sll $t3, $t2, 5 			# $t3 holds y coordinate * 32
	la $t2, obstacle 			# $t2 holds the top right corner of the enemy block
	lw $t2, 0($t2) 			# $t2 holds the x coordinate
	add $t3, $t3, $t2 			# $t3 holds 32*y + x
	sll $t3, $t3, 2 			# $t3 holds 4*(32*y + x)
	add $t3, $t3, $t1 			# $t3 holds 4*(32*y + x) + baseAddress
	
	lw $t8, 4($k0)
	beqz $t8, LP1
	lw $t8, 8($k0)
	beqz $t8, LP2
	lw $t8, 12($k0)
	beqz $t8, LP3
	addi $0, $0, 0

LP1: 	sw $t3, 4($k0)			#Stores the position of the first obstacle in the first slot in the array, if there isn't one
	j C
	addi $0, $0, 0

LP2:	sw $t3, 8($k0)			#Stores the position of the second obstacle in the second slot in the array, if there isn't one
	j C
	addi $0, $0, 0

LP3:	sw $t3, 12($k0)			#Stores the position of the third obstacle in the third slot in the array, if there isn't one
	j C
	addi $0, $0, 0
	
C:	addi $t9, $t3, 0			#Calculate the number of pixels that the obstacle is from the left edge of the screen upon generation
	andi $t9, 0x7f
	srl $t9, $t9, 2
	addi $t9, $t9, -4

	lw $t8, 4($k1)
	beqz $t8, LD1
	lw $t8, 8($k1)
	beqz $t8, LD2
	lw $t8, 12($k1)
	beqz $t8, LD3
	addi $0, $0, 0

LD1: 	sw $t9, 4($k1)			#Stores the despawn distance of the first obstacle in the first slot in the array, if there isn't one
	j C1
	addi $0, $0, 0

LD2:	sw $t9, 8($k1)			#Stores the despawn distance of the second obstacle in the second slot in the array, if there isn't one
	j C1
	addi $0, $0, 0

LD3:	sw $t9, 12($k1)			#Stores the despawn distance of the third obstacle in the third slot in the array, if there isn't one
	j C1
	addi $0, $0, 0
	
	# first row
C1:	sw $t0, -4($t3)			#Draws the obstacle
	sw $t0, -8($t3)
	sw $t0, -12($t3)
	
	#set to next row, rightmost pixel
	addi $t3, $t3, 128
	
	# second row
	sw $t0, 0($t3)
	sw $t0, -4($t3)
	sw $t4, -8($t3)
	sw $t4, -12($t3)
	sw $t0, -16($t3)

	
	#set to next row, rightmost pixel
	addi $t3, $t3, 128
	
	# third row
	sw $t0, 0($t3)
	sw $t0, -4($t3)
	sw $t0, -8($t3)
	sw $t4, -12($t3)
	sw $t4, -16($t3)
	sw $t0, -20($t3)
	
	#set to next row, rightmost pixel
	addi $t3, $t3, 128
	
	# fourth row
	sw $t0, 0($t3)
	sw $t4, -4($t3)
	sw $t0, -8($t3)
	sw $t0, -12($t3)
	sw $t4, -16($t3)
	sw $t0, -20($t3)
	
	#set to next row, rightmost pixel
	addi $t3, $t3, 128
	
	# fifth row
	sw $t0, 0($t3)
	sw $t0, -4($t3)
	sw $t4, -8($t3)
	sw $t0, -12($t3)
	sw $t0, -16($t3)
	sw $t0, -20($t3)
	
	#set to next row, rightmost pixel
	addi $t3, $t3, 128
	
	# sixth row
	sw $t0, -4($t3)
	sw $t0, -8($t3)
	sw $t0, -12($t3)
	sw $t0, -16($t3)

	
	#return to line after function call
	jr $ra
	addi $0, $0, 0
	
	
moveEnemy1:				#Draws the obstacle and decrease the distance from despawn
	li $t0, lightBrown
	li $t4, darkBrown
	lw $s1, 4($k0)

	# first row
	sw $t0, -4($s1)
	sw $t0, -8($s1)
	sw $t0, -12($s1)
	
	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# second row
	sw $t0, 0($s1)
	sw $t0, -4($s1)
	sw $t4, -8($s1)
	sw $t4, -12($s1)
	sw $t0, -16($s1)
	
	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# third row
	sw $t0, 0($s1)
	sw $t0, -4($s1)
	sw $t0, -8($s1)
	sw $t4, -12($s1)
	sw $t4, -16($s1)
	sw $t0, -20($s1)
	
	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# fourth row
	sw $t0, 0($s1)
	sw $t4, -4($s1)
	sw $t0, -8($s1)
	sw $t0, -12($s1)
	sw $t4, -16($s1)
	sw $t0, -20($s1)
	
	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# fifth row
	sw $t0, 0($s1)
	sw $t0, -4($s1)
	sw $t4, -8($s1)
	sw $t0, -12($s1)
	sw $t0, -16($s1)
	sw $t0, -20($s1)
	
	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# sixth row
	#sw $t0, 0($s1)
	sw $t0, -4($s1)
	sw $t0, -8($s1)
	sw $t0, -12($s1)
	sw $t0, -16($s1)
	
	lw $t8, 4($k1)			#Decrease the distance from despawn
	addi $t8, $t8, -1
	sw $t8, 4($k1)
	
	
out1:	#return to line after function call
	jr $ra
	addi $0, $0, 0
	
moveEnemy2:				#Draws the obstacle and decrease the distance from despawn
	li $t0, lightBrown
	li $t4, darkBrown
	lw $s2, 8($k0)

	# first row
	sw $t0, -4($s2)
	sw $t0, -8($s2)
	sw $t0, -12($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# second row
	sw $t0, 0($s2)
	sw $t0, -4($s2)
	sw $t4, -8($s2)
	sw $t4, -12($s2)
	sw $t0, -16($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# third row
	sw $t0, 0($s2)
	sw $t0, -4($s2)
	sw $t0, -8($s2)
	sw $t4, -12($s2)
	sw $t4, -16($s2)
	sw $t0, -20($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# fourth row
	sw $t0, 0($s2)
	sw $t4, -4($s2)
	sw $t0, -8($s2)
	sw $t0, -12($s2)
	sw $t4, -16($s2)
	sw $t0, -20($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# fifth row
	sw $t0, 0($s2)
	sw $t0, -4($s2)
	sw $t4, -8($s2)
	sw $t0, -12($s2)
	sw $t0, -16($s2)
	sw $t0, -20($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# sixth row
	sw $t0, -4($s2)
	sw $t0, -8($s2)
	sw $t0, -12($s2)
	sw $t0, -16($s2)
	
	lw $t8, 8($k1)			#Decrease the distance from despawn
	addi $t8, $t8, -1
	sw $t8, 8($k1)

out2:	#return to line after function call
	jr $ra
	addi $0, $0, 0
	
moveEnemy3:				#Draws the obstacle and decrease the distance from despawn
	li $t0, lightBrown
	li $t4, darkBrown
	lw $s3, 12($k0)

	# first row
	#sw $t0, 0($s3)
	sw $t0, -4($s3)
	sw $t0, -8($s3)
	sw $t0, -12($s3)
	#sw $t0, -16($s3)
	#sw $t0, -20($s3)
	
	#set to next row, rightmost pixel
	addi $s3, $s3, 128
	
	# second row
	sw $t0, 0($s3)
	sw $t0, -4($s3)
	sw $t4, -8($s3)
	sw $t4, -12($s3)
	sw $t0, -16($s3)
	#sw $t0, -20($s3)
	
	#set to next row, rightmost pixel
	addi $s3, $s3, 128
	
	# third row
	sw $t0, 0($s3)
	sw $t0, -4($s3)
	sw $t0, -8($s3)
	sw $t4, -12($s3)
	sw $t4, -16($s3)
	sw $t0, -20($s3)
	
	#set to next row, rightmost pixel
	addi $s3, $s3, 128
	
	# fourth row
	sw $t0, 0($s3)
	sw $t4, -4($s3)
	sw $t0, -8($s3)
	sw $t0, -12($s3)
	sw $t4, -16($s3)
	sw $t0, -20($s3)
	
	#set to next row, rightmost pixel
	addi $s3, $s3, 128
	
	# fifth row
	sw $t0, 0($s3)
	sw $t0, -4($s3)
	sw $t4, -8($s3)
	sw $t0, -12($s3)
	sw $t0, -16($s3)
	sw $t0, -20($s3)
	
	#set to next row, rightmost pixel
	addi $s3, $s3, 128
	
	# sixth row
	sw $t0, -4($s3)
	sw $t0, -8($s3)
	sw $t0, -12($s3)
	sw $t0, -16($s3)

	
	lw $t8, 12($k1)			#Decrease the distance from despawn
sub31:	addi $t8, $t8, -1
	sw $t8, 12($k1)

out3:	#return to line after function call
	jr $ra
	addi $0, $0, 0
	
cleanEnemy1:				#Draw over the obstacle in black (clear)
	lw $s1, 4($k0)
	la $s0, black

	# first row
	sw $s0, -4($s1)
	sw $s0, -8($s1)
	sw $s0, -12($s1)

	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# second row
	sw $s0, 0($s1)
	sw $s0, -4($s1)
	sw $s0, -8($s1)
	sw $s0, -12($s1)
	sw $s0, -16($s1)
	
	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# third row
	sw $s0, 0($s1)
	sw $s0, -4($s1)
	sw $s0, -8($s1)
	sw $s0, -12($s1)
	sw $s0, -16($s1)
	sw $s0, -20($s1)
	
	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# fourth row
	sw $s0, 0($s1)
	sw $s0, -4($s1)
	sw $s0, -8($s1)
	sw $s0, -12($s1)
	sw $s0, -16($s1)
	sw $s0, -20($s1)
	
	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# fifth row
	sw $s0, 0($s1)
	sw $s0, -4($s1)
	sw $s0, -8($s1)
	sw $s0, -12($s1)
	sw $s0, -16($s1)
	sw $s0, -20($s1)
	
	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# sixth row
	#sw $s0, 0($s1)
	sw $s0, -4($s1)
	sw $s0, -8($s1)
	sw $s0, -12($s1)
	sw $s0, -16($s1)
	
	#return to line after function call
	jr $ra
	addi $0, $0, 0

cleanEnemy2:				#Draw over the obstacle in black (clear)
	lw $s2, 8($k0)
	la $s0, black
	
	# first row
	sw $s0, -4($s2)
	sw $s0, -8($s2)
	sw $s0, -12($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# second row
	sw $s0, 0($s2)
	sw $s0, -4($s2)
	sw $s0, -8($s2)
	sw $s0, -12($s2)
	sw $s0, -16($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# third row
	sw $s0, 0($s2)
	sw $s0, -4($s2)
	sw $s0, -8($s2)
	sw $s0, -12($s2)
	sw $s0, -16($s2)
	sw $s0, -20($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# fourth row
	sw $s0, 0($s2)
	sw $s0, -4($s2)
	sw $s0, -8($s2)
	sw $s0, -12($s2)
	sw $s0, -16($s2)
	sw $s0, -20($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# fifth row
	sw $s0, 0($s2)
	sw $s0, -4($s2)
	sw $s0, -8($s2)
	sw $s0, -12($s2)
	sw $s0, -16($s2)
	sw $s0, -20($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# sixth row
	sw $s0, -4($s2)
	sw $s0, -8($s2)
	sw $s0, -12($s2)
	sw $s0, -16($s2)
	
	#return to line after function call
	jr $ra
	addi $0, $0, 0

cleanEnemy3:				#Draw over the obstacle in black (clear)
	lw $s3, 12($k0)
	la $s0, black

	# first row
	sw $s0, -4($s3)
	sw $s0, -8($s3)
	sw $s0, -12($s3)
	
	#set to next row, rightmost pixel
	addi $s3, $s3, 128
	
	# second row
	sw $s0, 0($s3)
	sw $s0, -4($s3)
	sw $s0, -8($s3)
	sw $s0, -12($s3)
	sw $s0, -16($s3)
	#sw $s0, -20($s3)
	
	#set to next row, rightmost pixel
	addi $s3, $s3, 128
	
	# third row
	sw $s0, 0($s3)
	sw $s0, -4($s3)
	sw $s0, -8($s3)
	sw $s0, -12($s3)
	sw $s0, -16($s3)
	sw $s0, -20($s3)
	
	#set to next row, rightmost pixel
	addi $s3, $s3, 128
	
	# fourth row
	sw $s0, 0($s3)
	sw $s0, -4($s3)
	sw $s0, -8($s3)
	sw $s0, -12($s3)
	sw $s0, -16($s3)
	sw $s0, -20($s3)
	
	#set to next row, rightmost pixel
	addi $s3, $s3, 128
	
	# fifth row
	sw $s0, 0($s3)
	sw $s0, -4($s3)
	sw $s0, -8($s3)
	sw $s0, -12($s3)
	sw $s0, -16($s3)
	sw $s0, -20($s3)
	
	#set to next row, rightmost pixel
	addi $s3, $s3, 128
	
	# sixth row
	#sw $s0, 0($s3)
	sw $s0, -4($s3)
	sw $s0, -8($s3)
	sw $s0, -12($s3)
	sw $s0, -16($s3)
	#sw $s0, -20($s3)
	
	#return to line after function call
	jr $ra
	addi $0, $0, 0
	
checkDespawn:
	sw $ra, 16($k1) 			# save the return address

	lw $t8, 4($k1)		
	blez $t8, RZ1			#loads and checks to see if any of the obstacles "distance until despawn" values are zero, and then jump to the spot to generate new ones
	addi $0, $0, 0
	
C2:	lw $t8, 8($k1)
	blez $t8, RZ2
	addi $0, $0, 0
	
C3:	lw $t8, 12($k1)
	blez $t8, RZ3
	addi $0, $0, 0	
	
C4:	lw $ra, 16($k1) 			# restore this function's return adress
	jr $ra				#goes back to the drawing loop
	addi $0, $0, 0

RZ1:	sw $0, 4($k0)			#resets the position of the obstacle back to 0
	jal enemyLocation			#generates a new obstacle and puts the 
	addi $0, $0, 0
	
	lw $t8, 0($k1)
	addi $t8, $t8, 1
	sw $t8, 0($k1)
	
	j C2				#jumps back up to check if any of the other obstacles need respawning
	addi $0, $0, 0
	
RZ2:	sw $0, 8($k0)
	jal enemyLocation
	addi $0, $0, 0
	
	lw $t8, 0($k1)
	addi $t8, $t8, 1
	sw $t8, 0($k1)
	
	j C3
	addi $0, $0, 0

RZ3:	sw $0, 12($k0)
	jal enemyLocation
	addi $0, $0, 0
	
	lw $t8, 0($k1)
	addi $t8, $t8, 1
	sw $t8, 0($k1)
	
	j C4
	addi $0, $0, 0

#################################################################################################################################################
# Keypress
#################################################################################################################################################
keypress_happened:
	lw $t2, 4($t9) 				# 4($t9) holds the ascii value of the key pressed. NOTE: this assumes $t9 is set to 0xfff0000 from before
	beq $t2, w_ASCII, respond_to_w 		# ASCII code of 'w' is 0x77 or 119 in decimal
	addi $0, $0, 0
	beq $t2, a_ASCII, respond_to_a 		# ASCII code of 'a' is 0x61 or 97 in decimal
	addi $0, $0, 0
	beq $t2, s_ASCII, respond_to_s 		# ASCII code of 's' is 0x73 or 115 in decimal
	addi $0, $0, 0
	beq $t2, d_ASCII, respond_to_d 		# ASCII code of 'd' is 0x64 or 100 in decimal
	addi $0, $0, 0
	beq $t2, p_ASCII, reset 			# ASCII code of 'p' is 0x70 or 112 in decimal
	addi $0, $0, 0
	j return					# if no desired keys are pressed then
	addi $0, $0, 0
respond_to_w:
	# move up if not already at the top of the screen
	jal clearShip				# clear the current ship
	addi $0, $0, 0
	la $s0, ship
	lw $s1, 4($s0)
	add $s2, $zero, $zero			# the top edge of the screen
	beq $s1, $s2, return			# if at the top of the screen return to game	
	addi $0, $0, 0	
	addi $s1, $s1, -1		
	sw $s1, 4($s0)				#store the up move
	j return				
	addi $0, $0, 0
	
respond_to_a:
	# move to the left if not already at the edge
	jal clearShip				# clear the current ship
	addi $0, $0, 0
	la $s0, ship
	lw $s1, 0($s0)
	addi $s2, $zero, 6				# the left edge of the screen
	beq $s1, $s2, return			# if at the left edge of the screen return to game
	addi $0, $0, 0
	addi $s1, $s1, -1		
	sw $s1, 0($s0)				#store the left move
	j return	
	addi $0, $0, 0
respond_to_s:
	# move down if not already at the edge
	jal clearShip				# clear the current ship
	addi $0, $0, 0
	la $s0, ship
	lw $s1, 4($s0)
	addi $s1, $s1, 6				# get the right wing y coordinate
	addi $s2, $zero, 30				# the bottom edge of the screen
	beq $s1, $s2, return			# if at the top of the screen return to game	
	addi $0, $0, 0			
	# sw $s1, 12($s0)				#store the down move for the right edge
	lw $s1, 4($s0)
	addi $s1, $s1, 1
	sw $s1, 4($s0)				#store the down move 
	#lw $s1, 4($s0)
	#addi $s1, $s1, 1
	#sw $s1, 4($s0)
	#sw $s1, 8($s0)
	j return	
	addi $0, $0, 0
respond_to_d:
	# move to the right if not alredy at the edge
	jal clearShip				# clear the current ship
	addi $0, $0, 0
	la $s0, ship
	lw $s1, 0($s0)
	addi $s2, $zero, 31				# the right edge of the screen
	beq $s1, $s2, return			# if at the left edge of the screen return to game
	addi $0, $0, 0
	addi $s1, $s1, 1		
	sw $s1, 0($s0)				#store the right move
	j return	
	addi $0, $0, 0
return:						
	# need to draw the ship in the new position here
	
	la $t0, grey 			# load the grey colour
	addi, $sp, $sp, -4 			# move stack up
	sw $t0, 0($sp) 			# store white into the stack
	
	la $t0, white			# load the white colour
	addi, $sp, $sp, -4 			# move stack up
	sw $t0, 0($sp) 			# store white into the stack
	
	jal drawShip
	addi $0, $0, 0
	j createHealth
	addi $0, $0, 0
reset:
	la $t0, obstacle
	add $t1, $zero, $zero
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	la $t0, positions
	add $t1, $zero, $zero
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	la $t0, dspwn1
	add $t1, $zero, $zero
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	la $t0, ship
	addi $t1, $zero, 6
	sw $t1, 0($t0)
	addi $t1, $zero, 12
	sw $t1, 4($t0)
	
	jal drawBlackScreen
	addi $0, $0, 0
	
	li $v0, 32
	li $a0, 50 			# Wait one second (1000 milliseconds)
	syscall
	
	la $t0, health
	addi $t1, $zero, 160
	sw $t1, 0($t0)			# reset health to 160
	j startGamePhase
	addi $0, $0, 0

#################################################################################################################################################
# Health Bar
#################################################################################################################################################
drawHealth:
	addi $sp, $sp, -4
	sw $ra, 0($sp)	
	la $s0, red
	la $s1, baseAddress
	addi $s2, $zero, 4092
	add $s1, $s1, $s2
	la $s3, health
	lw $s4, 0($s3)			# load current health into $s3
	blez $s4, gameOverPhase1
	addi $0, $0, 0
	
	addi $s5, $zero, 5			# if health is <= 5 return
	sw $s0, -124($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 10			# if health is <= 10 return
	sw $s0, -120($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 15			# if health is <= 15 return
	sw $s0, -116($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 20			# if health is <=  20 return
	sw $s0, -112($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 25			# if health is <=  25 return
	sw $s0, -108($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 30			# if health is <= 30 return
	sw $s0, -104($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 35			# if health is <= 35 return
	sw $s0, -100($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 40			# if health is <=  40 return
	sw $s0, -96($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 45			# if health is <= 45 return
	sw $s0, -92($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 50			# if health is less than 50 return
	sw $s0, -88($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 55			# if health is less than 55 return
	sw $s0, -84($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 60		
	sw $s0, -80($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 65		
	sw $s0, -76($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 70		
	sw $s0, -72($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 75		
	sw $s0, -68($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 80		
	sw $s0, -64($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 85		
	sw $s0, -60($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 90		
	sw $s0, -56($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 95		
	sw $s0, -52($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 100		
	sw $s0, -48($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 105		
	sw $s0, -44($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 110		
	sw $s0, -40($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 115		
	sw $s0, -36($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 120		
	sw $s0, -32($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 125		
	sw $s0, -28($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 130		
	sw $s0, -24($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 135		
	sw $s0, -20($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 140		
	sw $s0, -16($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 145		
	sw $s0, -12($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 150		
	sw $s0, -8($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 155		
	sw $s0, -4($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0
	
	addi $s5, $zero, 160		
	sw $s0, 0($s1)
	ble $s4, $s5, jump
	addi $0, $0, 0

	jr $ra
	addi $0, $0, 0
clearHealth:
	la $s0, black
	la $s1, baseAddress
	addi $s2, $zero, 4092
	add $s1, $s1, $s2
	sw $s0, -124($s1)
	sw $s0, -120($s1)
	sw $s0, -116($s1)
	sw $s0, -112($s1)
	sw $s0, -108($s1)
	sw $s0, -104($s1)
	sw $s0, -100($s1)
	sw $s0, -96($s1)
	sw $s0, -92($s1)
	sw $s0, -88($s1)
	sw $s0, -84($s1)
	sw $s0, -80($s1)
	sw $s0, -76($s1)
	sw $s0, -72($s1)
	sw $s0, -68($s1)
	sw $s0, -64($s1)
	sw $s0, -60($s1)
	sw $s0, -56($s1)
	sw $s0, -52($s1)
	sw $s0, -48($s1)
	sw $s0, -44($s1)
	sw $s0, -40($s1)
	sw $s0, -36($s1)
	sw $s0, -32($s1)
	sw $s0, -28($s1)
	sw $s0, -24($s1)
	sw $s0, -20($s1)
	sw $s0, -16($s1)
	sw $s0, -12($s1)
	sw $s0, -8($s1)
	sw $s0, -4($s1)
	sw $s0, 0($s1)
	jr $ra
	addi $0, $0, 0
jump:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	addi $0, $0, 0
	
#################################################################################################################################################
# Clearing Stuff
#################################################################################################################################################
clearShip:
	addi $sp, $sp, -4			# move stack up
	sw $ra, 0($sp)
	
	la $s0, black 			# load the black colour
	addi, $sp, $sp, -4 			# move stack up
	sw $s0, 0($sp) 			# store white into the stack
	addi, $sp, $sp, -4 			# move stack up
	sw $s0, 0($sp) 			# store white into the stack
	
	jal drawShip
	addi $0, $0, 0
		
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	addi $0, $0, 0
#################################################################################################################################################
# Drawing the black screen for reset game
#################################################################################################################################################
drawBlackScreen:
	addi $sp, $sp, -4 			# move stack up
	sw $ra, 0($sp) 			#store return address into stack
	
	la $t0, screen			# load screen coordinates
	lw $t1, 4($t0)			# load y screen coordinate
	addi $t2, $zero, 33			# breaking condition for the y of screen
	beq $t1, $t2, screenDone
	addi $0, $0, 0
	j drawBlackRow			# draw next row
	addi $0, $0, 0
	jr $ra
	addi $0, $0, 0
	
drawBlackRow:
	la $s0, black 			# $s0 holds the black colour
	la $s2, screen	 		# $s2 holds the coordinate of the top right corner of the screen
	lw $s3, 0($s2) 			# $s3 holds the x coordinate
	lw $s4, 4($s2) 			# $s4 holds the y coordinate
	sll $s4, $s4, 5 			# $s4 holds y coordinate * 32
	add $s4, $s4, $s3 			# $s4 holds 32*y + x
	sll $s4, $s4, 2			# $s4 holds 4*(32*y + x)
	la $s5, baseAddress 		# $s5 has the display address
	add $s5, $s5, $s4 			# $s5 holds baseAddress + 4*(32*y + x)
	
	sw $s0, 0($s5)			# colour each pixel black
	sw $s0, -4($s5)			
	sw $s0, -8($s5)			
	sw $s0, -12($s5)	
	sw $s0, -16($s5)	
	sw $s0, -20($s5)	
	sw $s0, -24($s5)	
	sw $s0, -28($s5)	
	sw $s0, -32($s5)		
	sw $s0, -36($s5)		
	sw $s0, -40($s5)		
	sw $s0, -44($s5)			
	sw $s0, -48($s5)			
	sw $s0, -52($s5)	
	sw $s0, -56($s5)	
	sw $s0, -60($s5)	
	sw $s0, -64($s5)	
	sw $s0, -68($s5)	
	sw $s0, -72($s5)		
	sw $s0, -76($s5)
	sw $s0, -80($s5)		
	sw $s0, -84($s5)			
	sw $s0, -88($s5)			
	sw $s0, -92($s5)	
	sw $s0, -96($s5)	
	sw $s0, -100($s5)	
	sw $s0, -104($s5)	
	sw $s0, -108($s5)	
	sw $s0, -112($s5)		
	sw $s0, -116($s5)
	sw $s0, -120($s5)		
	sw $s0, -124($s5)
	
	lw $s4, 4($s2) 			# $s4 holds the y coordinate
	addi $s4, $s4, 1			# add 1 to the y coordinate to move on to the next row.
	sw $s4, 4($s2)			# store new y for screen
	
	j drawBlackScreen
	addi $0, $0, 0

screenDone:
	lw $ra, 0($sp)			#store return address
	addi $sp, $sp, 4			# move stack down
	la $t0, screen 			# load screen address
	add $t1, $zero, $zero		# store reset value for y
	sw $t1, 4($t0)			# store new y value
	jr $ra
	addi $0, $0, 0
#################################################################################################################################################
# Game Over Screen
#################################################################################################################################################
gameOverPhase1:
	# redraw screen to be black
	jal drawBlackScreen
	addi $0, $0, 0
	la $t0, ship
	addi $t1, $zero, 6
	sw $t1, 0($t0)
	addi $t1, $zero, 12
	sw $t1, 4($t0)
	j animateEndShip
	addi $0, $0, 0
	# draw background obstacles
	#jal allEnemies
	# maybe just draw on in each corner? or the border
	# draw the game over message
gameOverPhase2:
	jal drawBlackScreen
	addi $0, $0, 0
	jal drawGameOver
	addi $0, $0, 0
	# draw score
	jal drawScore
	addi $0, $0, 0
	# draw reset
	lw $t0, 0($k1) 			# obstacles despawned
	
	addi $t1, $zero, 10		
	ble $t0, $t1, bye
	addi $0, $0, 0
	jal drawSymbol_1
	addi $0, $0, 0
	
	addi $t1, $zero, 20	
	lw $t0, 0($k1)
	ble $t0, $t1, bye
	addi $0, $0, 0
	jal drawSymbol_2
	addi $0, $0, 0
	
	addi $t1, $zero, 30
	lw $t0, 0($k1)		
	ble $t0, $t1, bye
	addi $0, $0, 0
	jal drawSymbol_3
	addi $0, $0, 0
	
	addi $t1, $zero, 40
	lw $t0, 0($k1)		
	ble $t0, $t1, bye
	addi $0, $0, 0
	jal drawSymbol_4
	addi $0, $0, 0
	
	addi $t1, $zero, 50	
	lw $t0, 0($k1)	
	ble $t0, $t1, bye
	addi $0, $0, 0
	jal drawSymbol_5
	addi $0, $0, 0
	
	j bye
	addi $0, $0, 0
animateEndShip:
	la $t0, ship
	lw $t1, 0($t0)
	beq $t1, 31, gameOverPhase2
	addi $0, $0, 0
	la $t0, grey 			# load the grey colour
	addi, $sp, $sp, -4 			# move stack up
	sw $t0, 0($sp) 			# store white into the stack
	
	la $t0, white			# load the white colour
	addi, $sp, $sp, -4 			# move stack up
	sw $t0, 0($sp) 			# store white into the stack
	
	jal drawShip
	addi $0, $0, 0
	li $v0,32
	li $a0,50
	syscall
	jal clearShip
	addi $0, $0, 0
	
	la $t0, ship
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)
	
	j animateEndShip
	addi $0, $0, 0
bye:
	j end
	addi $0, $0, 0
drawGameOver:
	la $s0, red			# load the red colour into $s0
	la $s1, baseAddress 		# $s1 has the base address
	la $s2, game			# $s2 holds the top right corner of the word "game"
	lw $s3, 0($s2)			# $s3 holds the x coordinate
	lw $s4, 4($s2)			# $s4 holds the y coordinate
	sll $s4, $s4, 5 			# $s4 holds y coordinate * 32
	add $s4, $s4, $s3 			# $s4 holds 32*y + x
	sll $s4, $s4, 2 			# $s4 holds 4*(32*y + x)
	la $s5, baseAddress 		# $s5 has the base address
	add $s5, $s5, $s4 			# $s5 holds displayAddress + 4*(32*y + x)
	sw $s0, 0($s5)			#first row of the word game
	sw $s0, -4($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -24($s5)
	sw $s0, -40($s5)
	sw $s0, -52($s5)
	sw $s0, -56($s5)
	sw $s0, -60($s5)
	addi $s5, $s5, 128 			#set to next row, rightmost pixel
	sw $s0, -4($s5) 			#second row
	sw $s0, -12($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -60($s5)
	addi $s5, $s5, 128 			#set to next row, rightmost pixel
	sw $s0, -0($s5) 			#third row
	sw $s0, -4($s5) 
	sw $s0, -12($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -40($s5)
	sw $s0, -44($s5)
	sw $s0, -52($s5)
	sw $s0, -60($s5)
	addi $s5, $s5, 128 			#set to next row, rightmost pixel
	sw $s0, -4($s5) 			#fourth row
	sw $s0, -12($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -52($s5)
	sw $s0, -60($s5)
	addi $s5, $s5, 128 			#set to next row, rightmost pixel
	sw $s0, -0($s5) 			#fifth row
	sw $s0, -4($s5) 
	sw $s0, -12($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -52($s5)
	sw $s0, -56($s5)
	sw $s0, -60($s5)
	la $t1, baseAddress 		# $t1 has the base address
	la $t2, over 			#$t2 holds the top right corner of the word "over"
	lw $t2, 4($t2) 			#$t2 holds the y coordinate
	sll $s5, $t2, 5 			#$s5 holds y coordinate * 32
	la $t2, over 			#$t2 holds the top right corner of the word "over"
	lw $t2, 0($t2) 			#$t2 holds the x coordinate
	add $s5, $s5, $t2 			#$s5 holds 32*y + x
	sll $s5, $s5, 2 			#$s5 holds 4*(32*y + x)
	add $s5, $s5, $t1 			#$s5 holds 4*(32*y + x) + baseAddress
	sw $s0, 0($s5)			#first row of the word over
	sw $s0, -4($s5)
	sw $s0, -8($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -48($s5)
	sw $s0, -52($s5)
	addi $s5, $s5, 128 			#set to next row, rightmost pixel
	sw $s0, 0($s5)			#second row
	sw $s0, -8($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -52($s5)
	addi $s5, $s5, 128 			#set to next row, rightmost pixel
	sw $s0, 0($s5)			#third row
	sw $s0, -4($s5)
	sw $s0, -8($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -52($s5)
	addi $s5, $s5, 128 			#set to next row, rightmost pixel
	sw $s0, -4($s5) 			#fourth row
	sw $s0, -8($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -52($s5)
	addi $s5, $s5, 128 			#set to next row, rightmost pixel
	sw $s0, 0($s5)			#fifth row
	sw $s0, -8($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -32($s5)
	sw $s0, -44($s5)
	sw $s0, -48($s5)
	sw $s0, -52($s5)
	jr $ra
	addi $0, $0, 0
drawScore:
	la $s0, green 			# $s0 has the green colour
	la $s1, baseAddress 		# $t1 has the base address
	la $s2, score 			#$t2 holds the top right corner of the word "score"
	lw $s3, 0($s2) 			#$s3 holds the x coordinate
	lw $s4, 4($s2) 			#$s4 holds the y coordinate
	sll $s4, $s4, 5 			#$s4 holds y coordinate * 32
	add $s4, $s4, $s3 			#$s4 holds 32*y + x
	sll $s4, $s4, 2 			#$s4 holds 4*(32*y + x)
	la $s5, baseAddress 		# $s5 has the base address
	add $s5, $s5, $s4 			#$s5 holds displayAddress + 4*(32*y + x)
	sw $s0, 0($s5)			#first row of the word score
	sw $s0, -4($s5)
	sw $s0, -12($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -32($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -48($s5)
	sw $s0, -52($s5)
	sw $s0, -60($s5)
	sw $s0, -64($s5)
	sw $s0, -68($s5)
	addi $s5, $s5, 128 			#set to next row, rightmost pixel
	sw $s0, 8($s5)			#second row
	sw $s0, -4($s5)
	sw $s0, -12($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -52($s5)
	sw $s0, -68($s5)
	addi $s5, $s5, 128 			#set to next row, rightmost pixel
	sw $s0, 0($s5)			#third row
	sw $s0, -4($s5)
	sw $s0, -12($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -52($s5)
	sw $s0, -60($s5)
	sw $s0, -64($s5)
	sw $s0, -68($s5)
	addi $s5, $s5, 128 			#set to next row, rightmost pixel
	sw $s0, 8($s5)			#fourth row
	sw $s0, -4($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -52($s5)
	sw $s0, -60($s5)
	addi $s5, $s5, 128 			#set to next row, rightmost pixel
	sw $s0, 0($s5)			#fifth row
	sw $s0, -4($s5)
	sw $s0, -12($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -32($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -48($s5)
	sw $s0, -52($s5)
	sw $s0, -60($s5)
	sw $s0, -64($s5)
	sw $s0, -68($s5)
	jr $ra
	addi $0, $0, 0
allEnemies:
	addi $sp, $sp, -4			#move the stack up
	sw $ra, 0($sp) 			#store the return address
	jal enemyLocation
	jal enemyLocation
	jal enemyLocation
	jal enemyLocation
	jal enemyLocation
	jal enemyLocation
	jal enemyLocation
	lw $ra, 0($sp) 			#load the return address
	addi $sp, $sp, 4 			#move the stack down
	jr $ra
	addi $0, $0, 0
drawSymbol_1:
	la $s0, red 			#$s0 has the green colour
	la $s6, yellow
	la $s1, baseAddress 		#t1 has the base address
	la $s2, symbol_1 			#$t2 holds the top right corner of the word "score"
	lw $s3, 0($s2) 			#$s3 holds the x coordinate
	lw $s4, 4($s2) 			#$s4 holds the y coordinate
	sll $s4, $s4, 5 			#$s4 holds y coordinate * 32
	add $s4, $s4, $s3 			#$s4 holds 32*y + x
	sll $s4, $s4, 2 			#$s4 holds 4*(32*y + x)
	la $s5, baseAddress 		#$s5 has the base address
	add $s5, $s5, $s4 			#$s5 holds displayAddress + 4*(32*y + x)
	
	sw $s0, -8($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, -4($s5)
	sw $s6, -8($s5)
	sw $s0, -12($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, 0($s5)
	sw $s6, -4($s5)
	sw $s0, -8($s5)
	sw $s6, -12($s5)
	sw $s0, -16($s5)
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, -4($s5)
	sw $s6, -8($s5)
	sw $s0, -12($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, -8($s5)
	
	jr $ra
	addi $0, $0, 0
drawSymbol_2:
	la $s0, red 			#$s0 has the green colour
	la $s6, yellow
	la $s1, baseAddress 		#$t1 has the base address
	la $s2, symbol_2 			#$t2 holds the top right corner of the word "score"
	lw $s3, 0($s2) 			#$s3 holds the x coordinate
	lw $s4, 4($s2) 			#$s4 holds the y coordinate
	sll $s4, $s4, 5 			#$s4 holds y coordinate * 32
	add $s4, $s4, $s3 			#$s4 holds 32*y + x
	sll $s4, $s4, 2 			#$s4 holds 4*(32*y + x)
	la $s5, baseAddress 		#$s5 has the base address
	add $s5, $s5, $s4 			#$s5 holds displayAddress + 4*(32*y + x)
	
	sw $s0, -8($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, -4($s5)
	sw $s6, -8($s5)
	sw $s0, -12($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, 0($s5)
	sw $s6, -4($s5)
	sw $s0, -8($s5)
	sw $s6, -12($s5)
	sw $s0, -16($s5)
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, -4($s5)
	sw $s6, -8($s5)
	sw $s0, -12($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, -8($s5)
	
	jr $ra
	addi $0, $0, 0
drawSymbol_3:
	la $s0, red 			#$s0 has the green colour
	la $s6, yellow
	la $s1, baseAddress 		#$t1 has the base address
	la $s2, symbol_3 			#$t2 holds the top right corner of the word "score"
	lw $s3, 0($s2) 			#$s3 holds the x coordinate
	lw $s4, 4($s2)			#$s4 holds the y coordinate
	sll $s4, $s4, 5 			#$s4 holds y coordinate * 32
	add $s4, $s4, $s3 			#$s4 holds 32*y + x
	sll $s4, $s4, 2 			#$s4 holds 4*(32*y + x)
	la $s5, baseAddress 		#$s5 has the base address
	add $s5, $s5, $s4 			#$s5 holds displayAddress + 4*(32*y + x)
	
	sw $s0, -8($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, -4($s5)
	sw $s6, -8($s5)
	sw $s0, -12($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, 0($s5)
	sw $s6, -4($s5)
	sw $s0, -8($s5)
	sw $s6, -12($s5)
	sw $s0, -16($s5)
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, -4($s5)
	sw $s6, -8($s5)
	sw $s0, -12($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, -8($s5)
	
	jr $ra
	addi $0, $0, 0
drawSymbol_4:
	la $s0, red 			#$s0 has the green colour
	la $s6, yellow
	la $s1, baseAddress 		#$t1 has the base address
	la $s2, symbol_4 			#$t2 holds the top right corner of the word "score"
	lw $s3, 0($s2) 			#$s3 holds the x coordinate
	lw $s4, 4($s2) 			#$s4 holds the y coordinate
	sll $s4, $s4, 5 			#$s4 holds y coordinate * 32
	add $s4, $s4, $s3 			#$s4 holds 32*y + x
	sll $s4, $s4, 2 			#$s4 holds 4*(32*y + x)
	la $s5, baseAddress 		#$s5 has the base address
	add $s5, $s5, $s4 			#$s5 holds displayAddress + 4*(32*y + x)
	
	sw $s0, -8($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, -4($s5)
	sw $s6, -8($s5)
	sw $s0, -12($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, 0($s5)
	sw $s6, -4($s5)
	sw $s0, -8($s5)
	sw $s6, -12($s5)
	sw $s0, -16($s5)
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, -4($s5)
	sw $s6, -8($s5)
	sw $s0, -12($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, -8($s5)
	
	jr $ra
	addi $0, $0, 0
drawSymbol_5:
	la $s0, red 			#$s0 has the green colour
	la $s6, yellow
	la $s1, baseAddress 		#$t1 has the base address
	la $s2, symbol_5 			#$t2 holds the top right corner of the word "score"
	lw $s3, 0($s2) 			#$s3 holds the x coordinate
	lw $s4, 4($s2) 			#$s4 holds the y coordinate
	sll $s4, $s4, 5 			#$s4 holds y coordinate * 32
	add $s4, $s4, $s3 			#$s4 holds 32*y + x
	sll $s4, $s4, 2 			#$s4 holds 4*(32*y + x)
	la $s5, baseAddress 		#$s5 has the base address
	add $s5, $s5, $s4 			#$s5 holds displayAddress + 4*(32*y + x)
	
	sw $s0, -8($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, -4($s5)
	sw $s6, -8($s5)
	sw $s0, -12($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, 0($s5)
	sw $s6, -4($s5)
	sw $s0, -8($s5)
	sw $s6, -12($s5)
	sw $s0, -16($s5)
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, -4($s5)
	sw $s6, -8($s5)
	sw $s0, -12($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	sw $s0, -8($s5)
	
	jr $ra
	addi $0, $0, 0
#################################################################################################################################################
# Start Game Screen
#################################################################################################################################################
drawStartGame:
	la $s0, green 			#load the red colour into $s0
	la $s1, baseAddress 		#$s1 has the base address
	la $s2, start 			#$s2 holds the top right corner of the word "game"
	lw $s3, 0($s2) 			#$s3 holds the x coordinate
	lw $s4, 4($s2) 			#$s4 holds the y coordinate
	sll $s4, $s4, 5 			#$s4 holds y coordinate * 32
	add $s4, $s4, $s3 			#$s4 holds 32*y + x
	sll $s4, $s4, 2 			#$s4 holds 4*(32*y + x)
	la $s5, baseAddress 		#$s5 has the base address
	add $s5, $s5, $s4 			#$s5 holds displayAddress + 4*(32*y + x)
	sw $s0, 0($s5)			#first row of the word game
	sw $s0, -4($s5)
	sw $s0, -8($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -24($s5)
	sw $s0, -36($s5)
	sw $s0, -48($s5)
	sw $s0, -52($s5)
	sw $s0, -56($s5)
	sw $s0, -64($s5)
	sw $s0, -68($s5)
	sw $s0, -72($s5)
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, -4($s5)
	sw $s0, -16($s5)
	sw $s0, -24($s5)
	sw $s0, -32($s5)
	sw $s0, -40($s5)
	sw $s0, -52($s5)
	sw $s0, -72($s5)
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, -4($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -24($s5)
	sw $s0, -32($s5)
	sw $s0, -36($s5)
	sw $s0, -40($s5)
	sw $s0, -52($s5)
	sw $s0, -64($s5)
	sw $s0, -68($s5)
	sw $s0, -72($s5)
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, -4($s5) #fourth row
	sw $s0, -20($s5)
	sw $s0, -24($s5)
	sw $s0, -32($s5)
	sw $s0, -40($s5)
	sw $s0, -52($s5)
	sw $s0, -64($s5)
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, -4($s5) 
	sw $s0, -16($s5)
	sw $s0, -24($s5)
	sw $s0, -32($s5)
	sw $s0, -40($s5)
	sw $s0, -52($s5)
	sw $s0, -64($s5)
	sw $s0, -68($s5)
	sw $s0, -72($s5)
	la $s0, green 			#load the red colour into $s0
	la $s1, baseAddress 		#$s1 has the base address
	la $s2, s_game 			#$s2 holds the top right corner of the word "game"
	lw $s3, 0($s2) 			#$s3 holds the x coordinate
	lw $s4, 4($s2) 			#$s4 holds the y coordinate
	sll $s4, $s4, 5 			#$s4 holds y coordinate * 32
	add $s4, $s4, $s3 			#$s4 holds 32*y + x
	sll $s4, $s4, 2 			#$s4 holds 4*(32*y + x)
	la $s5, baseAddress 		#$s5 has the base address
	add $s5, $s5, $s4 			#$s5 holds displayAddress + 4*(32*y + x)
	sw $s0, 0($s5)			#first row of the word game
	sw $s0, -4($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -24($s5)
	sw $s0, -40($s5)
	sw $s0, -52($s5)
	sw $s0, -56($s5)
	sw $s0, -60($s5)
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, -4($s5) #second row
	sw $s0, -12($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -60($s5)
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, -0($s5) #third row
	sw $s0, -4($s5) 
	sw $s0, -12($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -40($s5)
	sw $s0, -44($s5)
	sw $s0, -52($s5)
	sw $s0, -60($s5)
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, -4($s5) #fourth row
	sw $s0, -12($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -52($s5)
	sw $s0, -60($s5)
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, -0($s5) #fifth row
	sw $s0, -4($s5) 
	sw $s0, -12($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -52($s5)
	sw $s0, -56($s5)
	sw $s0, -60($s5)
	jr $ra
	addi $0, $0, 0
#################################################################################################################################################
# Collision Detection
#################################################################################################################################################
CheckCollision:
	addi $sp, $sp, -4 			# move stack up
	sw $ra, 0($sp) 			# save the return addres
	la $s2, ship 			# $s2 load the top right corner of the ship
	lw $s3, 0($s2)			# $s3 has the x coordinate
	lw $s4, 4($s2)			# $s4 holds the y coordinate
	sll $s4, $s4, 5			# $s4 holds y * 32
	add $s4, $s4, $s3			# $s4 holds y * 32 + x
	sll $s4, $s4, 2 			# $s4 holds 4 * (y * 32 + x)
	add $s5, $s4, $zero
	la $s5, baseAddress		
	add $s5, $s5, $s4
	addi $s6, $s5, 0			#move the starting coord to $s6
	
	jal shipchck
	addi $0, $0, 0
	
hitted:	#j main
	lw $ra, 0($sp) 			# restor this function's return adress
	addi $sp, $sp, 4 			# move the stack down
	
	jr $ra
	addi $0, $0, 0

shipchck:	
	addi $sp, $sp, -4 			# move stack up
	sw $ra, 0($sp) 			# save the return addres
	
	addi $s6, $s6, -8			#cycels through each collideable hitbox on the shi, checking for collisions
	li $t8, -1			#0/1 value to determine graze
	sw $t8, 4($a3)
	jal checkOC
	addi $0, $0, 0
	addi $s6, $s6, 260
	li $t8, 0
	sw $t8, 4($a3)
	jal checkOC
	addi $0, $0, 0
	addi $s6, $s6, 132
	jal checkOC
	addi $0, $0, 0
	addi $s6, $s6, 124
	jal checkOC
	addi $0, $0, 0
	addi $s6, $s6, 252
	jal checkOC
	addi $0, $0, 0
	addi $s6, $s6, 128
	li $t8, 1
	sw $t8, 4($a3)
	jal checkOC
	addi $0, $0, 0
 
 	lw $ra, 0($sp) 			# restor this function's return adress
	addi $sp, $sp, 4 			# move the stack down
	
	jr $ra
	addi $0, $0, 0
	
checkOC: 	
	addi $sp, $sp, -4 			# move stack up
	sw $ra, 0($sp) 			# save the return addres

	lw $s7, 4($k0)			#cycles through each obstacle and checks them for collisions
	jal collide
	addi $0, $0, 0
	lw $s7, 8($k0)
	jal collide
	addi $0, $0, 0
	lw $s7, 12($k0)
	jal collide
	addi $0, $0, 0
	
	lw $ra, 0($sp) 			# restor this function's return adress
	addi $sp, $sp, 4 			# move the stack down
	
	jr $ra
	addi $0, $0, 0
	
collide:	
	addi $sp, $sp, -4 			# move stack up
	sw $ra, 0($sp) 			# save the return addres
	
	addi $s7, $s7, -12			#cycles through the collideable pixels in the obstacle with the given ship pixed ($s6)
	beq $s6, $s7, hitDetected
	addi $0, $0, 0
	addi $s7, $s7, 124
	beq $s6, $s7, hitDetected
	addi $0, $0, 0
	addi $s7, $s7, 124
	beq $s6, $s7, hitDetected
	addi $0, $0, 0
	addi $s7, $s7, 128
	beq $s6, $s7, hitDetected
	addi $0, $0, 0
	addi $s7, $s7, 128
	beq $s6, $s7, hitDetected
	addi $0, $0, 0
	addi $s7, $s7, 132
	beq $s6, $s7, hitDetected
	addi $0, $0, 0
	
	lw $ra, 0($sp) 			# restor this function's return adress
	addi $sp, $sp, 4 			# move the stack down
	
	jr $ra
	addi $0, $0, 0
	
hitDetected:
	lw $t8, 4($a3)			#the pixels overlapped; collision detected
	beqz $t8, hit
	addi $0, $0, 0
	bltz $t8, tgraze			#checks for grazes
	addi $0, $0, 0
	bgtz $t8, bgraze			#checks for grazes
	addi $0, $0, 0

hit:	lw $t8, 0($k0)			#regular hit; add to # of collisions
	addi $t8, $t8, 1
	sw $t8, 0($k0)
		
	la $s0, health			#decrease health
	lw $s1, 0($s0)
	addi $s1, $s1, -10
	sw $s1, 0($s0)
	
	jal clearHealth			#clear and redraw new health
	addi $0, $0, 0
	jal drawHealth
	addi $0, $0, 0
	
	j ocout
	
tgraze:	lw $t8, 8($a3)			#graze on the top wing; add to # of collisions
	addi $t8, $t8, 1
	sw $t8, 8($a3)
	
	la $s2, ship 			# $s2 load the top right corner of the ship
	lw $s3, 0($s2)			# $s3 has the x coordinate
	lw $s4, 4($s2)			# $s4 holds the y coordinate
	sll $s4, $s4, 5			# $s4 holds y * 32
	add $s4, $s4, $s3			# $s4 holds y * 32 + x
	sll $s4, $s4, 2 			# $s4 holds 4 * (y * 32 + x)
	add $s5, $s4, $zero
	la $s5, baseAddress		
	add $s5, $s5, $s4
	
	la $s0, health			#decrease health (less health is subtracted than a regular hit)
	lw $s1, 0($s0)
	addi $s1, $s1, -5
	sw $s1, 0($s0)
	
	la $s0, red
	sw $s0, -8($s5)
	
	li $v0, 32			#Sleep the simulator to slow eveerything down
	li $a0, 150
	syscall
	
	jal clearHealth			#clear and redraw new health
	addi $0, $0, 0
	jal drawHealth
	addi $0, $0, 0
	
	j ocout
	
bgraze:	lw $t8, 8($a3)			#graze on the bottom wing; add to # of collisions
	addi $t8, $t8, 1
	sw $t8, 8($a3)
	
	la $s2, ship 			# $s2 load the top right corner of the ship
	lw $s3, 0($s2)			# $s3 has the x coordinate
	lw $s4, 4($s2)			# $s4 holds the y coordinate
	sll $s4, $s4, 5			# $s4 holds y * 32
	add $s4, $s4, $s3			# $s4 holds y * 32 + x
	sll $s4, $s4, 2 			# $s4 holds 4 * (y * 32 + x)
	add $s5, $s4, $zero
	la $s5, baseAddress		
	add $s5, $s5, $s4
	
	la $s0, health			#decrease health (less health is subtracted than a regular hit)
	lw $s1, 0($s0)
	addi $s1, $s1, -5
	sw $s1, 0($s0)
	
	la $s0, red
	sw $s0, 888($s5)
	
	li $v0, 32			#Sleep the simulator to slow eveerything down
	li $a0, 150
	syscall
	
	jal clearHealth			#clear and redraw new health
	addi $0, $0, 0
	jal drawHealth
	addi $0, $0, 0
	
	j ocout
	
ocout:	j hitted				#jump back to leave collision checks
	addi $0, $0, 0
	
end:	# gracefully terminate the program
	li $v0, 10
	syscall


