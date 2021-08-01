# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#

.eqv lightBrown 0xa0522d
.eqv darkBrown 0x654321
.eqv baseAddress 0x10008000

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
	
	addi $a0, $a0, 16 #random int + 16 to make it be the righter half
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
	la $s2, enemyBlock # $s2 holds the top right corner of the enemy block
	lw $s3, 0($s2) # $s3 holds the x coordinate
	lw $s4, 4($s2) # $s4 holds the y coordinate
	sll $s4, $s4, 5 # $s4 holds y coordinate * 32
	add $s4, $s4, $s3 # $s4 holds 32*y + x
	sll $s4, $s4, 2 # $s4 holds 4*(32*y + x)
	la $s5, baseAddress # $s5 has the display address
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
end:
	# gracefully terminate the program
	li $v0, 10
	syscall

