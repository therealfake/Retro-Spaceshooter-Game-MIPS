# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#

.eqv lightBrown 0xa0522d
.eqv darkBrown 0x654321
.eqv displayAddress 0x10008000

.data
initialBlock: .word 4, 13 #x, y coordinates of the top right corner of the initial block
enemyBlock: .word 0, 0 #x, y coordinates of the enemy block

.text
allEnemies:
	jal enemyLocation
	jal enemyLocation
	jal enemyLocation
	j end
enemyLocation:
	addi $sp, $sp, -4 # move stack up
	sw $ra, 0($sp) # save the return address
	
	li $v0, 42         # Service 42, random int range
	li $a0, 0          # Select random generator 0
	li $a1, 26	   # Upper bound of random number generator is 30
	syscall            # Generate random int (returns in $a0)
	
	la $t0, enemyBlock #$t0 holds the address of the enemy's top right corner
	sw $a0, 4($t0) #save random y coordinate into enemy array
	
	li $v0, 42         # Service 42, random int range
	li $a0, 0          # Select random generator 0
	li $a1, 15	   # Upper bound of random number generator is 16
	syscall            # Generate random int (returns in $a0)
	
	addi $a0, $a0, 16 #random int *2
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
	la $t1, displayAddress # $t1 has the display address
	la $t2, enemyBlock # $t2 holds the top right corner of the enemy block
	lw $t2, 4($t2) # $t2 holds the y coordinate
	sll $t3, $t2, 5 # $t3 holds y coordinate * 32
	la $t2, enemyBlock # $t2 holds the top right corner of the enemy block
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

