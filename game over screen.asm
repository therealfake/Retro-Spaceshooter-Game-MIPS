# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# WARNING: THERE WILL BE CONFLICT AS THE DRAW ENEMY IS DIFF THAN FOR THE MOVE ENEMY'S VERSION OF DRAW ENEMY
#
.eqv lightBrown 0xa0522d
.eqv darkBrown 0x654321
.eqv red 0xff0000
.eqv green 0x00ff00
.eqv baseAddress 0x10008000
.eqv yellow 0xffff00 
.data
ggsMessage: .word 0,0
obstacle: .word 0, 0 #x, y coordinates of the obstacle
game: .word 18, 4 # x,y coordinates of the top right of the word "game" 
over: .word 28, 10 # x,y coordinates of the top right of the word "end"
score: .word 23, 16 # x,y coordinates of the top right of the word "score"
symbol_1: .word 6, 23 # x, y coordinates for the score
symbol_2: .word 12, 23
symbol_3: .word 18, 23
symbol_4: .word 24, 23
symbol_5: .word 30, 23
.text
gameOverPhase:
	# redraw screen to be black
	# draw background obstacles
	#jal allEnemies
	# draw the game over message
	#jal drawGameOver
	# draw score
	#jal drawScore
	#draw symbols
	addi $s6, $zero, 16
	
	addi $s7, $zero, 15		
	ble $s6, $s7, end
	jal drawSymbol_1
	addi $s7, $zero, 30		
	ble $s6, $s7, end
	jal drawSymbol_2
bye:
	j end
	addi $0, $0, 0
	# draw reset
drawGameOver:
	la $s0, red # load the red colour into $s0
	la $s1, baseAddress # $s1 has the base address
	la $s2, game # $s2 holds the top right corner of the word "game"
	lw $s3, 0($s2) # $s3 holds the x coordinate
	lw $s4, 4($s2) # $s4 holds the y coordinate
	sll $s4, $s4, 5 # $s4 holds y coordinate * 32
	add $s4, $s4, $s3 # $s4 holds 32*y + x
	sll $s4, $s4, 2 # $s4 holds 4*(32*y + x)
	la $s5, baseAddress # $s5 has the base address
	add $s5, $s5, $s4 # $s5 holds displayAddress + 4*(32*y + x)
	sw $s0, 0($s5)#first row of the word game
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
	la $t1, baseAddress # $t1 has the base address
	la $t2, over # $t2 holds the top right corner of the word "over"
	lw $t2, 4($t2) # $t2 holds the y coordinate
	sll $s5, $t2, 5 # $s5 holds y coordinate * 32
	la $t2, over # $t2 holds the top right corner of the word "over"
	lw $t2, 0($t2) # $t2 holds the x coordinate
	add $s5, $s5, $t2 # $s5 holds 32*y + x
	sll $s5, $s5, 2 # $s5 holds 4*(32*y + x)
	add $s5, $s5, $t1 # $s5 holds 4*(32*y + x) + baseAddress
	sw $s0, 0($s5)#first row of the word over
	sw $s0, -4($s5)
	sw $s0, -8($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -48($s5)
	sw $s0, -52($s5)
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, 0($s5)# second row
	sw $s0, -8($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -52($s5)
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, 0($s5)# third row
	sw $s0, -4($s5)
	sw $s0, -8($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -52($s5)
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, -4($s5) # fourth row
	sw $s0, -8($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -44($s5)
	sw $s0, -52($s5)
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, 0($s5)#fifth row
	sw $s0, -8($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -32($s5)
	sw $s0, -44($s5)
	sw $s0, -48($s5)
	sw $s0, -52($s5)
	jr $ra
drawScore:
	la $s0, green # $s0 has the green colour
	la $s1, baseAddress # $t1 has the base address
	la $s2, score # $t2 holds the top right corner of the word "score"
	lw $s3, 0($s2) # $s3 holds the x coordinate
	lw $s4, 4($s2) # $s4 holds the y coordinate
	sll $s4, $s4, 5 # $s4 holds y coordinate * 32
	add $s4, $s4, $s3 # $s4 holds 32*y + x
	sll $s4, $s4, 2 # $s4 holds 4*(32*y + x)
	la $s5, baseAddress # $s5 has the base address
	add $s5, $s5, $s4 # $s5 holds displayAddress + 4*(32*y + x)
	sw $s0, 0($s5)#first row of the word score
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
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, 8($s5)# second row
	sw $s0, -4($s5)
	sw $s0, -12($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -52($s5)
	sw $s0, -68($s5)
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, 0($s5)# third row
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
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, 8($s5)# fourth row
	sw $s0, -4($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -28($s5)
	sw $s0, -36($s5)
	sw $s0, -52($s5)
	sw $s0, -60($s5)
	addi $s5, $s5, 128 #set to next row, rightmost pixel
	sw $s0, 0($s5)#fifth row
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
#################################################################################################################################################
# New Stuff
#################################################################################################################################################
drawOk:
	
#################################################################################################################################################
# Obstacles
#################################################################################################################################################
allEnemies:
	addi $sp, $sp, -4 # move the stack up
	sw $ra, 0($sp) # store the return address
	jal enemyLocation
	jal enemyLocation
	jal enemyLocation
	jal enemyLocation
	jal enemyLocation
	jal enemyLocation
	jal enemyLocation
	lw $ra, 0($sp) # load the return address
	addi $sp, $sp, 4 # move the stack down
	jr $ra
enemyLocation:
	addi $sp, $sp, -4 # move stack up
	sw $ra, 0($sp) # save the return address
	
	li $v0, 42         # Service 42, random int range
	li $a0, 0          # Select random generator 0
	li $a1, 26	   # Upper bound of random number generator is 30
	syscall            # Generate random int (returns in $a0)
	
	la $t0, obstacle #$t0 holds the address of the enemy's top right corner
	sw $a0, 4($t0) #save random y coordinate into enemy array
	
	li $v0, 42         # Service 42, random int range
	li $a0, 0          # Select random generator 0
	li $a1, 31	   # Upper bound of random number generator is 16
	syscall            # Generate random int (returns in $a0)
	
	sw $a0, 0($t0) #save random x coordinate (between 16 and 32) into the enemy array
	
	la $t0, darkBrown  # $t0 stores the dark brown colour
	addi $sp, $sp, -4 # move up stack
	sw $t0, 0($sp) #store the rdark brown colour into the stack
	
	la $t0, lightBrown # t0 stores the light brown colour
	addi $sp, $sp, -4 # move up stack
	sw $t0, 0($sp) #store the light brown colour into the stack
	
	jal drawEnemy
	
	lw $ra, 0($sp) # restor this function's return adress
	addi $sp, $sp, 4 # move the stack down
	
	jr $ra
drawEnemy: 
	lw $s0, 0($sp) # $s0 holds colour popped off from the stack
	addi $sp, $sp, 4 # update stack down
	lw $s1, 0($sp) # $s1 holds colour popped off from the stack
	addi $sp, $sp, 4 # update stack down
	la $s2, obstacle # $s2 holds the top right corner of the obstacle
	lw $s3, 0($s2) # $s3 holds the x coordinate
	lw $s4, 4($s2) # $s4 holds the y coordinate
	sll $s4, $s4, 5 # $s4 holds y coordinate * 32
	add $s4, $s4, $s3 # $s4 holds 32*y + x
	sll $s4, $s4, 2 # $s4 holds 4*(32*y + x)
	la $s5, baseAddress # $s5 has the base address
	add $s5, $s5, $s4 # $s5 holds baseAddress + 4*(32*y + x)
	
	
	# first row
	#sw $s0, 0($s5)
	sw $s0, -4($s5)
	sw $s0, -8($s5)
	sw $t0, -12($s5)
	#sw $s0, -16($s5)
	#sw $s0, -20($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	# second row
	sw $s0, 0($s5)
	sw $s0, -4($s5)
	sw $s1, -8($s5)
	sw $s1, -12($s5)
	sw $s0, -16($s5)
	#sw $s0, -20($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	# third row
	sw $s0, 0($s5)
	sw $s0, -4($s5)
	sw $s0, -8($s5)
	sw $s1, -12($s5)
	sw $s1, -16($s5)
	sw $s0, -20($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	# fourth row
	sw $s0, 0($s5)
	sw $s1, -4($s5)
	sw $s0, -8($s5)
	sw $s0, -12($s5)
	sw $s1, -16($s5)
	sw $s0, -20($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	# fifth row
	sw $s0, 0($s5)
	sw $s0, -4($s5)
	sw $s1, -8($s5)
	sw $s0, -12($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	
	#set to next row, rightmost pixel
	addi $s5, $s5, 128
	
	# sixth row
	#sw $s0, 0($s5)
	sw $s0, -4($s5)
	sw $s0, -8($s5)
	sw $s0, -12($s5)
	sw $s0, -16($s5)
	#sw $s0, -20($s5)
	
	#return to line after function call
	jr $ra
drawSymbol_1:
	la $s0, red # $s0 has the green colour
	la $s6, yellow
	la $s1, baseAddress # $t1 has the base address
	la $s2, symbol_1 # $t2 holds the top right corner of the word "score"
	lw $s3, 0($s2) # $s3 holds the x coordinate
	lw $s4, 4($s2) # $s4 holds the y coordinate
	sll $s4, $s4, 5 # $s4 holds y coordinate * 32
	add $s4, $s4, $s3 # $s4 holds 32*y + x
	sll $s4, $s4, 2 # $s4 holds 4*(32*y + x)
	la $s5, baseAddress # $s5 has the base address
	add $s5, $s5, $s4 # $s5 holds displayAddress + 4*(32*y + x)
	
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

drawSymbol_2:
	la $s0, red # $s0 has the green colour
	la $s6, yellow
	la $s1, baseAddress # $t1 has the base address
	la $s2, symbol_2 # $t2 holds the top right corner of the word "score"
	lw $s3, 0($s2) # $s3 holds the x coordinate
	lw $s4, 4($s2) # $s4 holds the y coordinate
	sll $s4, $s4, 5 # $s4 holds y coordinate * 32
	add $s4, $s4, $s3 # $s4 holds 32*y + x
	sll $s4, $s4, 2 # $s4 holds 4*(32*y + x)
	la $s5, baseAddress # $s5 has the base address
	add $s5, $s5, $s4 # $s5 holds displayAddress + 4*(32*y + x)
	
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

drawSymbol_3:
	la $s0, red # $s0 has the green colour
	la $s6, yellow
	la $s1, baseAddress # $t1 has the base address
	la $s2, symbol_3 # $t2 holds the top right corner of the word "score"
	lw $s3, 0($s2) # $s3 holds the x coordinate
	lw $s4, 4($s2) # $s4 holds the y coordinate
	sll $s4, $s4, 5 # $s4 holds y coordinate * 32
	add $s4, $s4, $s3 # $s4 holds 32*y + x
	sll $s4, $s4, 2 # $s4 holds 4*(32*y + x)
	la $s5, baseAddress # $s5 has the base address
	add $s5, $s5, $s4 # $s5 holds displayAddress + 4*(32*y + x)
	
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

drawSymbol_4:
	la $s0, red # $s0 has the green colour
	la $s6, yellow
	la $s1, baseAddress # $t1 has the base address
	la $s2, symbol_4 # $t2 holds the top right corner of the word "score"
	lw $s3, 0($s2) # $s3 holds the x coordinate
	lw $s4, 4($s2) # $s4 holds the y coordinate
	sll $s4, $s4, 5 # $s4 holds y coordinate * 32
	add $s4, $s4, $s3 # $s4 holds 32*y + x
	sll $s4, $s4, 2 # $s4 holds 4*(32*y + x)
	la $s5, baseAddress # $s5 has the base address
	add $s5, $s5, $s4 # $s5 holds displayAddress + 4*(32*y + x)
	
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

drawSymbol_5:
	la $s0, red # $s0 has the green colour
	la $s6, yellow
	la $s1, baseAddress # $t1 has the base address
	la $s2, symbol_5 # $t2 holds the top right corner of the word "score"
	lw $s3, 0($s2) # $s3 holds the x coordinate
	lw $s4, 4($s2) # $s4 holds the y coordinate
	sll $s4, $s4, 5 # $s4 holds y coordinate * 32
	add $s4, $s4, $s3 # $s4 holds 32*y + x
	sll $s4, $s4, 2 # $s4 holds 4*(32*y + x)
	la $s5, baseAddress # $s5 has the base address
	add $s5, $s5, $s4 # $s5 holds displayAddress + 4*(32*y + x)
	
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
end:
	# gracefully terminate the program
	li $v0, 10
	syscall
