# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#

.eqv lightBrown 0xa0522d
.eqv darkBrown 0x654321
.eqv red 0xff0000
.eqv green 0x00ff00
.eqv baseAddress 0x10008000

.data
ggsMessage: .word 0,0
obstacle: .word 0, 0 #x, y coordinates of the enemy block
game: .word 18, 3 # x,y coordinates of the top right of the word "game" 
over: .word 28, 9 # x,y coordinates of the top right of the word "end"
score: .word 24, 15 # x,y coordinates of the top right of the word "score"
.text
gameOverPhase:
	# redraw screen to be black
	# draw background obstacles
	jal allEnemies
	# draw the game over message
	jal drawGameOver
	# draw score
	jal drawScore
	# draw reset
	j end
drawGameOver:
	la $t0, red # load the red colour into $t0
	la $t1, baseAddress # $t1 has the display address
	la $t2, game # $t2 holds the top right corner of the word "game"
	lw $t2, 4($t2) # $t2 holds the y coordinate
	sll $t3, $t2, 5 # $t3 holds y coordinate * 32
	la $t2, game # $t2 holds the top right corner of the word "game"
	lw $t2, 0($t2) # $t2 holds the x coordinate
	add $t3, $t3, $t2 # $t3 holds 32*y + x
	sll $t3, $t3, 2 # $t3 holds 4*(32*y + x)
	add $t3, $t3, $t1 # $t3 holds 4*(32*y + x) + baseAddress
	sw $t0, 0($t3)#first row of the word game
	sw $t0, -4($t3)
	sw $t0, -16($t3)
	sw $t0, -20($t3)
	sw $t0, -24($t3)
	sw $t0, -40($t3)
	sw $t0, -52($t3)
	sw $t0, -56($t3)
	sw $t0, -60($t3)
	addi $t3, $t3, 128 #set to next row, rightmost pixel
	sw $t0, -4($t3) #second row
	sw $t0, -12($t3)
	sw $t0, -20($t3)
	sw $t0, -28($t3)
	sw $t0, -36($t3)
	sw $t0, -44($t3)
	sw $t0, -60($t3)
	addi $t3, $t3, 128 #set to next row, rightmost pixel
	sw $t0, -0($t3) #third row
	sw $t0, -4($t3) 
	sw $t0, -12($t3)
	sw $t0, -20($t3)
	sw $t0, -28($t3)
	sw $t0, -36($t3)
	sw $t0, -40($t3)
	sw $t0, -44($t3)
	sw $t0, -52($t3)
	sw $t0, -60($t3)
	addi $t3, $t3, 128 #set to next row, rightmost pixel
	sw $t0, -4($t3) #fourth row
	sw $t0, -12($t3)
	sw $t0, -20($t3)
	sw $t0, -28($t3)
	sw $t0, -36($t3)
	sw $t0, -44($t3)
	sw $t0, -52($t3)
	sw $t0, -60($t3)
	addi $t3, $t3, 128 #set to next row, rightmost pixel
	sw $t0, -0($t3) #fifth row
	sw $t0, -4($t3) 
	sw $t0, -12($t3)
	sw $t0, -20($t3)
	sw $t0, -28($t3)
	sw $t0, -36($t3)
	sw $t0, -44($t3)
	sw $t0, -52($t3)
	sw $t0, -56($t3)
	sw $t0, -60($t3)
	la $t1, baseAddress # $t1 has the display address
	la $t2, over # $t2 holds the top right corner of the word "over"
	lw $t2, 4($t2) # $t2 holds the y coordinate
	sll $t3, $t2, 5 # $t3 holds y coordinate * 32
	la $t2, over # $t2 holds the top right corner of the word "over"
	lw $t2, 0($t2) # $t2 holds the x coordinate
	add $t3, $t3, $t2 # $t3 holds 32*y + x
	sll $t3, $t3, 2 # $t3 holds 4*(32*y + x)
	add $t3, $t3, $t1 # $t3 holds 4*(32*y + x) + baseAddress
	sw $t0, 0($t3)#first row of the word over
	sw $t0, -4($t3)
	sw $t0, -8($t3)
	sw $t0, -16($t3)
	sw $t0, -20($t3)
	sw $t0, -28($t3)
	sw $t0, -36($t3)
	sw $t0, -44($t3)
	sw $t0, -48($t3)
	sw $t0, -52($t3)
	addi $t3, $t3, 128 #set to next row, rightmost pixel
	sw $t0, 0($t3)# second row
	sw $t0, -8($t3)
	sw $t0, -20($t3)
	sw $t0, -28($t3)
	sw $t0, -36($t3)
	sw $t0, -44($t3)
	sw $t0, -52($t3)
	addi $t3, $t3, 128 #set to next row, rightmost pixel
	sw $t0, 0($t3)# third row
	sw $t0, -4($t3)
	sw $t0, -8($t3)
	sw $t0, -16($t3)
	sw $t0, -20($t3)
	sw $t0, -28($t3)
	sw $t0, -36($t3)
	sw $t0, -44($t3)
	sw $t0, -52($t3)
	addi $t3, $t3, 128 #set to next row, rightmost pixel
	sw $t0, -4($t3) # fourth row
	sw $t0, -8($t3)
	sw $t0, -20($t3)
	sw $t0, -28($t3)
	sw $t0, -36($t3)
	sw $t0, -44($t3)
	sw $t0, -52($t3)
	addi $t3, $t3, 128 #set to next row, rightmost pixel
	sw $t0, 0($t3)#fifth row
	sw $t0, -8($t3)
	sw $t0, -16($t3)
	sw $t0, -20($t3)
	sw $t0, -32($t3)
	sw $t0, -44($t3)
	sw $t0, -48($t3)
	sw $t0, -52($t3)
	jr $ra
drawScore:
	la $t0, green # $t0 has the green colour
	la $t1, baseAddress # $t1 has the display address
	la $t2, score # $t2 holds the top right corner of the word "score"
	lw $t2, 4($t2) # $t2 holds the y coordinate
	sll $t3, $t2, 5 # $t3 holds y coordinate * 32
	la $t2, score # $t2 holds the top right corner of the word "score"
	lw $t2, 0($t2) # $t2 holds the x coordinate
	add $t3, $t3, $t2 # $t3 holds 32*y + x
	sll $t3, $t3, 2 # $t3 holds 4*(32*y + x)
	add $t3, $t3, $t1 # $t3 holds 4*(32*y + x) + baseAddress
	sw $t0, 0($t3)#first row of the word score
	sw $t0, -4($t3)
	sw $t0, -12($t3)
	sw $t0, -16($t3)
	sw $t0, -20($t3)
	sw $t0, -28($t3)
	sw $t0, -32($t3)
	sw $t0, -36($t3)
	sw $t0, -44($t3)
	sw $t0, -48($t3)
	sw $t0, -52($t3)
	sw $t0, -60($t3)
	sw $t0, -64($t3)
	sw $t0, -68($t3)
	addi $t3, $t3, 128 #set to next row, rightmost pixel
	sw $t0, 8($t3)# second row
	sw $t0, -4($t3)
	sw $t0, -12($t3)
	sw $t0, -20($t3)
	sw $t0, -28($t3)
	sw $t0, -36($t3)
	sw $t0, -52($t3)
	sw $t0, -68($t3)
	addi $t3, $t3, 128 #set to next row, rightmost pixel
	sw $t0, 0($t3)# third row
	sw $t0, -4($t3)
	sw $t0, -12($t3)
	sw $t0, -16($t3)
	sw $t0, -20($t3)
	sw $t0, -28($t3)
	sw $t0, -36($t3)
	sw $t0, -52($t3)
	sw $t0, -60($t3)
	sw $t0, -64($t3)
	sw $t0, -68($t3)
	addi $t3, $t3, 128 #set to next row, rightmost pixel
	sw $t0, 8($t3)# fourth row
	sw $t0, -4($t3)
	sw $t0, -16($t3)
	sw $t0, -20($t3)
	sw $t0, -28($t3)
	sw $t0, -36($t3)
	sw $t0, -52($t3)
	sw $t0, -60($t3)
	addi $t3, $t3, 128 #set to next row, rightmost pixel
	sw $t0, 0($t3)#fifth row
	sw $t0, -4($t3)
	sw $t0, -12($t3)
	sw $t0, -20($t3)
	sw $t0, -28($t3)
	sw $t0, -32($t3)
	sw $t0, -36($t3)
	sw $t0, -44($t3)
	sw $t0, -48($t3)
	sw $t0, -52($t3)
	sw $t0, -60($t3)
	sw $t0, -64($t3)
	sw $t0, -68($t3)
	jr $ra
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
	li $a1, 27	   # Upper bound of random number generator is 16
	syscall            # Generate random int (returns in $a0)
	
	addi $a0, $a0, 5 #random int *2
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
	lw $t0, 0($sp) # $t0 holds colour popped off from the stack
	addi $sp, $sp, 4 # update stack down
	lw $t4, 0($sp) # $t4 holds colour popped off from the stack
	addi $sp, $sp, 4 # update stack down
	la $t1, baseAddress # $t1 has the display address
	la $t2, obstacle # $t2 holds the top right corner of the enemy block
	lw $t2, 4($t2) # $t2 holds the y coordinate
	sll $t3, $t2, 5 # $t3 holds y coordinate * 32
	la $t2, obstacle # $t2 holds the top right corner of the enemy block
	lw $t2, 0($t2) # $t2 holds the x coordinate
	add $t3, $t3, $t2 # $t3 holds 32*y + x
	sll $t3, $t3, 2 # $t3 holds 4*(32*y + x)
	add $t3, $t3, $t1 # $t3 holds 4*(32*y + x) + displayAddress
	
	# first row
	#sw $t0, 0($t3)
	sw $t0, -4($t3)
	sw $t0, -8($t3)
	sw $t0, -12($t3)
	#sw $t0, -16($t3)
	#sw $t0, -20($t3)
	
	#set to next row, rightmost pixel
	addi $t3, $t3, 128
	
	# second row
	sw $t0, 0($t3)
	sw $t0, -4($t3)
	sw $t4, -8($t3)
	sw $t4, -12($t3)
	sw $t0, -16($t3)
	#sw $t0, -20($t3)
	
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
	#sw $t0, 0($t3)
	sw $t0, -4($t3)
	sw $t0, -8($t3)
	sw $t0, -12($t3)
	sw $t0, -16($t3)
	#sw $t0, -20($t3)
	
	#return to line after function call
	jr $ra
end:
	# gracefully terminate the program
	li $v0, 10
	syscall