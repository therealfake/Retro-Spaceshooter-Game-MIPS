
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
obstacle: .word 0, 0			#x, y coordinates of the obstacle
positions: .word 0, 0, 0, 0, 0		#Contains the positions of all the obstacles
dspwn1: .word 0, 0, 0, 0		#Contains the distance from the point at which the obstacle needs to vanish and be generated again elsewhere

.text

la $k0, positions			#Initialize the two arrys into registers
la $k1, dspwn1			


makeEnemies:				#Create three obstacles at three random locations
	jal enemyLocation
	addi $0, $0, 0
	jal enemyLocation
	addi $0, $0, 0
	jal enemyLocation
	addi $0, $0, 0
	
moveEnemies:				#Move the obstacles forward one pixel
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
		
	
	lw $t8, 4($k0)			#Increment the positions of each obstacle by shifting them one pixel to the left
	addi $t8, $t8, -4
	sw $t8, 4($k0)
	
	lw $t8, 8($k0)
	addi $t8, $t8, -4
	sw $t8, 8($k0)
	
	lw $t8, 12($k0)
	addi $t8, $t8, -4
	sw $t8, 12($k0)
	
	jal checkDespawn		#Jumps to the portion of the code which checks to see if an obstacle should be removed
	addi $0, $0, 0
	
	j moveEnemies			#Jump back to the top of the loop
	addi $0, $0, 0

enemyLocation:
	addi $sp, $sp, -4 		# move stack up
	sw $ra, 0($sp) 			# save the return address
	
	li $v0, 42         		# Service 42, random int range
	li $a0, 0          		# Select random generator 0
	li $a1, 26		   	# Upper bound of random number generator is 30
	syscall            		# Generate random int (returns in $a0)
	
	la $t0, obstacle 		#$t0 holds the address of the enemy's top right corner
	sw $a0, 4($t0) 			#save random y coordinate into enemy array
	
	li $v0, 42        		# Service 42, random int range
	li $a0, 0          		# Select random generator 0
	li $a1, 2	 		# Upper bound of random number generator is 2
	syscall            		# Generate random int (returns in $a0)
	
	addi $a0, $a0, 29 		# random int between 29 and 31
	sw $a0, 0($t0) 			#save random x coordinate (between 16 and 32) into the enemy array
	
	la $t0, darkBrown  		# $t0 stores the dark brown colour
	addi $sp, $sp, -4 		# move up stack
	sw $t0, 0($sp) 			#store the rdark brown colour into the stack
	
	la $t0, lightBrown 		# t0 stores the light brown colour
	addi $sp, $sp, -4 		# move up stack
	sw $t0, 0($sp) 			#store the light brown colour into the stack
	
	jal drawEnemy
	addi $0, $0, 0
	
	lw $ra, 0($sp) 			# restor this function's return adress
	addi $sp, $sp, 4 		# move the stack down
	
	jr $ra
	addi $0, $0, 0
	


drawEnemy: 
	lw $t0, 0($sp) 			# $t0 holds colour popped off from the stack
	addi $sp, $sp, 4 		# update stack down
	lw $t4, 0($sp) 			# $t4 holds colour popped off from the stack
	addi $sp, $sp, 4 		# update stack down
	la $t1, baseAddress 		# $t1 has the display address
	la $t2, obstacle 		# $t2 holds the top right corner of the enemy block
	lw $t2, 4($t2) 			# $t2 holds the y coordinate
	sll $t3, $t2, 5 		# $t3 holds y coordinate * 32
	la $t2, obstacle 		# $t2 holds the top right corner of the enemy block
	lw $t2, 0($t2) 			# $t2 holds the x coordinate
	add $t3, $t3, $t2 		# $t3 holds 32*y + x
	sll $t3, $t3, 2 		# $t3 holds 4*(32*y + x)
	add $t3, $t3, $t1 		# $t3 holds 4*(32*y + x) + baseAddress
	
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
	
C:	addi $t9, $t3, 0		#Calculate the number of pixels that the obstacle is from the left edge of the screen upon generation
	andi $t9, 0x7f
	srl $t9, $t9, 2
	addi $t9, $t9, -5

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
	#sw $t0, 0($t3)
C1:	sw $t0, -4($t3)			#Draws the obstacle
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
	addi $0, $0, 0
	
	
moveEnemy1:				#Draws the obstacle and decrease the distance from despawn
	li $t0, lightBrown
	li $t4, darkBrown
	lw $s1, 4($k0)

	# first row
	#sw $t0, 0($s1)
	sw $t0, -4($s1)
	sw $t0, -8($s1)
	sw $t0, -12($s1)
	#sw $t0, -16($s1)
	#sw $t0, -20($s1)
	
	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# second row
	sw $t0, 0($s1)
	sw $t0, -4($s1)
	sw $t4, -8($s1)
	sw $t4, -12($s1)
	sw $t0, -16($s1)
	#sw $t0, -20($s1)
	
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
	#sw $t0, -20($s1)
	
	lw $t8, 4($k1)			#Decrease the distance from despawn
	addi $t8, $t8, -1
	sw $t8, 4($k1)
	
	#return to line after function call
	jr $ra
	addi $0, $0, 0
	
moveEnemy2:
	li $t0, lightBrown
	li $t4, darkBrown
	lw $s2, 8($k0)

	# first row
	#sw $t0, 0($s2)
	sw $t0, -4($s2)
	sw $t0, -8($s2)
	sw $t0, -12($s2)
	#sw $t0, -16($s2)
	#sw $t0, -20($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# second row
	sw $t0, 0($s2)
	sw $t0, -4($s2)
	sw $t4, -8($s2)
	sw $t4, -12($s2)
	sw $t0, -16($s2)
	#sw $t0, -20($s2)
	
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
	#sw $t0, 0($s2)
	sw $t0, -4($s2)
	sw $t0, -8($s2)
	sw $t0, -12($s2)
	sw $t0, -16($s2)
	#sw $t0, -20($s2)
	
	lw $t8, 8($k1)
	addi $t8, $t8, -1
	sw $t8, 8($k1)
	
	#return to line after function call
	jr $ra
	addi $0, $0, 0
	
moveEnemy3:
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
	#sw $t0, 0($s3)
	sw $t0, -4($s3)
	sw $t0, -8($s3)
	sw $t0, -12($s3)
	sw $t0, -16($s3)
	#sw $t0, -20($s3)
	
	lw $t8, 12($k1)
	addi $t8, $t8, -1
	sw $t8, 12($k1)
	
	#return to line after function call
	jr $ra
	addi $0, $0, 0
	
cleanEnemy1:				#Draw over the obstacle (clear)

	lw $s1, 4($k0)

	# first row
	#sw $k1, 0($s1)
	sw $k1, -4($s1)
	sw $k1, -8($s1)
	sw $k1, -12($s1)
	#sw $k1, -16($s1)
	#sw $k1, -20($s1)
	
	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# second row
	sw $k1, 0($s1)
	sw $k1, -4($s1)
	sw $k1, -8($s1)
	sw $k1, -12($s1)
	sw $k1, -16($s1)
	#sw $k1, -20($s1)
	
	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# third row
	sw $k1, 0($s1)
	sw $k1, -4($s1)
	sw $k1, -8($s1)
	sw $k1, -12($s1)
	sw $k1, -16($s1)
	sw $k1, -20($s1)
	
	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# fourth row
	sw $k1, 0($s1)
	sw $k1, -4($s1)
	sw $k1, -8($s1)
	sw $k1, -12($s1)
	sw $k1, -16($s1)
	sw $k1, -20($s1)
	
	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# fifth row
	sw $k1, 0($s1)
	sw $k1, -4($s1)
	sw $k1, -8($s1)
	sw $k1, -12($s1)
	sw $k1, -16($s1)
	sw $k1, -20($s1)
	
	#set to next row, rightmost pixel
	addi $s1, $s1, 128
	
	# sixth row
	#sw $k1, 0($s1)
	sw $k1, -4($s1)
	sw $k1, -8($s1)
	sw $k1, -12($s1)
	sw $k1, -16($s1)
	#sw $k1, -20($s1)
	
	#return to line after function call
	jr $ra
	addi $0, $0, 0

cleanEnemy2:

	lw $s2, 8($k0)

	# first row
	#sw $k1, 0($s2)
	sw $k1, -4($s2)
	sw $k1, -8($s2)
	sw $k1, -12($s2)
	#sw $k1, -16($s2)
	#sw $k1, -20($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# second row
	sw $k1, 0($s2)
	sw $k1, -4($s2)
	sw $k1, -8($s2)
	sw $k1, -12($s2)
	sw $k1, -16($s2)
	#sw $k1, -20($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# third row
	sw $k1, 0($s2)
	sw $k1, -4($s2)
	sw $k1, -8($s2)
	sw $k1, -12($s2)
	sw $k1, -16($s2)
	sw $k1, -20($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# fourth row
	sw $k1, 0($s2)
	sw $k1, -4($s2)
	sw $k1, -8($s2)
	sw $k1, -12($s2)
	sw $k1, -16($s2)
	sw $k1, -20($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# fifth row
	sw $k1, 0($s2)
	sw $k1, -4($s2)
	sw $k1, -8($s2)
	sw $k1, -12($s2)
	sw $k1, -16($s2)
	sw $k1, -20($s2)
	
	#set to next row, rightmost pixel
	addi $s2, $s2, 128
	
	# sixth row
	#sw $k1, 0($s2)
	sw $k1, -4($s2)
	sw $k1, -8($s2)
	sw $k1, -12($s2)
	sw $k1, -16($s2)
	#sw $k1, -20($s2)
	
	#return to line after function call
	jr $ra
	addi $0, $0, 0

cleanEnemy3:

	lw $s3, 12($k0)

	# first row
	#sw $k1, 0($s3)
	sw $k1, -4($s3)
	sw $k1, -8($s3)
	sw $k1, -12($s3)
	#sw $k1, -16($s3)
	#sw $k1, -20($s3)
	
	#set to next row, rightmost pixel
	addi $s3, $s3, 128
	
	# second row
	sw $k1, 0($s3)
	sw $k1, -4($s3)
	sw $k1, -8($s3)
	sw $k1, -12($s3)
	sw $k1, -16($s3)
	#sw $k1, -20($s3)
	
	#set to next row, rightmost pixel
	addi $s3, $s3, 128
	
	# third row
	sw $k1, 0($s3)
	sw $k1, -4($s3)
	sw $k1, -8($s3)
	sw $k1, -12($s3)
	sw $k1, -16($s3)
	sw $k1, -20($s3)
	
	#set to next row, rightmost pixel
	addi $s3, $s3, 128
	
	# fourth row
	sw $k1, 0($s3)
	sw $k1, -4($s3)
	sw $k1, -8($s3)
	sw $k1, -12($s3)
	sw $k1, -16($s3)
	sw $k1, -20($s3)
	
	#set to next row, rightmost pixel
	addi $s3, $s3, 128
	
	# fifth row
	sw $k1, 0($s3)
	sw $k1, -4($s3)
	sw $k1, -8($s3)
	sw $k1, -12($s3)
	sw $k1, -16($s3)
	sw $k1, -20($s3)
	
	#set to next row, rightmost pixel
	addi $s3, $s3, 128
	
	# sixth row
	#sw $k1, 0($s3)
	sw $k1, -4($s3)
	sw $k1, -8($s3)
	sw $k1, -12($s3)
	sw $k1, -16($s3)
	#sw $k1, -20($s3)
	
	#return to line after function call
	jr $ra
	addi $0, $0, 0
	
checkDespawn:
	sw $ra, 0($k1) 			# save the return address

	lw $t8, 4($k1)		
	blez $t8, RZ1			#loads and checks to see if any of the obstacles "distance until despawn" values are zero, and then jump to the spot to generate new ones
	addi $0, $0, 0
	
C2:	lw $t8, 8($k1)
	blez $t8, RZ2
	addi $0, $0, 0
	
C3:	lw $t8, 12($k1)
	blez $t8, RZ3
	addi $0, $0, 0	
	
C4:	lw $ra, 0($k1) 			# restore this function's return adress
	jr $ra				#goes back to the drawnig loop
	addi $0, $0, 0

RZ1:	sw $0, 4($k0)			#resets the position of the obstacle back to 0
	jal enemyLocation		#generates a new obstacle and puts the 
	addi $0, $0, 0
	j C2				#jumps back up to check if any of the other obstacles need respawning
	addi $0, $0, 0
	
RZ2:	sw $0, 8($k0)
	jal enemyLocation
	addi $0, $0, 0
	j C3
	addi $0, $0, 0

RZ3:	sw $0, 12($k0)
	jal enemyLocation
	addi $0, $0, 0
	j C4
	addi $0, $0, 0
	

end:	# gracefully terminate the program
	li $v0, 10
	syscall
