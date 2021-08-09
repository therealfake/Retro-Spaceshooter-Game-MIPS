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
.eqv grey 0x808080 
.eqv white 0xffffff
.eqv black 0x000000
.data
ggsMessage: .word 0,0
obstacle: .word 0, 0 #x, y coordinates of the obstacle
start: .word 25, 9 # x,y coordinates of the top right of the word "start"
s_game: .word 23, 15 # x,y coordinates of the top right of the word "game" 
ship: .word 6, 11		 	#x, y coordinates of the top right corner of the ship and then the y coordinates of the left and right wing.
.text
startGamePhase:
	jal drawStartGame
	jal animateShip
	addi $0, $0, 0
animateShip:
	la $t0, ship
	lw $t1, 0($t0)
	beq $t1, 31, end
	la $t0, grey 			# load the grey colour
	addi, $sp, $sp, -4 		# move stack up
	sw $t0, 0($sp) 			# store white into the stack
	
	la $t0, white			# load the white colour
	addi, $sp, $sp, -4 		# move stack up
	sw $t0, 0($sp) 			# store white into the stack
	
	jal drawShip
	li $v0,32
	li $a0,50
	syscall
	jal clearShip
	
	la $t0, ship
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)
	
	j animateShip
#bye:
#	j end
#	addi $0, $0, 0
	# draw reset
drawShip:
	lw $s0, 0($sp) 			# load the white color into $s0
	addi $sp, $sp, 4		# move stack down
	lw $s1, 0($sp) 			# load the white color into $s1
	addi $sp, $sp, 4		# move stack down
	la $s2, ship 			# $s2 load the top right corner of the ship
	lw $s3, 0($s2)			# $s3 has the x coordinate
	lw $s4, 4($s2)			# $s4 holds the y coordinate
	sll $s4, $s4, 5			# $s4 holds y * 32
	add $s4, $s4, $s3		# $s4 holds y * 32 + x
	sll $s4, $s4, 2 		# $s4 holds 4 * (y * 32 + x)
	add $s5, $s4, $zero
	la $s5, baseAddress		
	add $s5, $s5, $s4
	
	sw $s0, -8($s5)
	addi $s5, $s5, 128		# move to next row
	
	sw $s0, -8($s5)
	sw $s0, -12($s5)
	addi $s5, $s5, 128		# move to next row
	
	sw $s0, -4($s5)
	sw $s0, -8($s5)
	sw $s0, -12($s5)
	sw $s0, -16($s5)
	sw $s0, -24($s5)
	addi $s5, $s5, 128		# move to next row
	
	sw $s0, 0($s5)
	sw $s0, -4($s5)
	sw $s1, -8($s5)
	sw $s1, -12($s5)
	sw $s0, -16($s5)
	sw $s0, -20($s5)
	sw $s0, -24($s5)
	addi $s5, $s5, 128		# move to next row
	
	sw $s0, -4($s5)
	sw $s0, -8($s5)
	sw $s0, -12($s5)
	sw $s0, -16($s5)
	sw $s0, -24($s5)
	addi $s5, $s5, 128		# move to next row
	
	sw $s0, -8($s5)
	sw $s0, -12($s5)
	addi $s5, $s5, 128		# move to next row
	
	sw $s0, -8($s5)
	
	jr $ra
	addi $0, $0, 0
clearShip:
	addi $sp, $sp, -4		# move stack up
	sw $ra, 0($sp)
	
	la $s0, black 			# load the black colour
	addi, $sp, $sp, -4 		# move stack up
	sw $s0, 0($sp) 			# store white into the stack
	addi, $sp, $sp, -4 		# move stack up
	sw $s0, 0($sp) 			# store white into the stack
	
	jal drawShip
	addi $0, $0, 0
		
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	addi $0, $0, 0
drawStartGame:
	la $s0, green # load the red colour into $s0
	la $s1, baseAddress # $s1 has the base address
	la $s2, start # $s2 holds the top right corner of the word "game"
	lw $s3, 0($s2) # $s3 holds the x coordinate
	lw $s4, 4($s2) # $s4 holds the y coordinate
	sll $s4, $s4, 5 # $s4 holds y coordinate * 32
	add $s4, $s4, $s3 # $s4 holds 32*y + x
	sll $s4, $s4, 2 # $s4 holds 4*(32*y + x)
	la $s5, baseAddress # $s5 has the base address
	add $s5, $s5, $s4 # $s5 holds displayAddress + 4*(32*y + x)
	sw $s0, 0($s5)#first row of the word game
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
	la $s0, green # load the red colour into $s0
	la $s1, baseAddress # $s1 has the base address
	la $s2, s_game # $s2 holds the top right corner of the word "game"
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
	jr $ra
end: 
	li $v0, 10
	syscall
