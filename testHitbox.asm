#adresses
.eqv baseAddress 0x10008000 		# base address for the display
.eqv keystrokeAddress 0xffff0000 	# memory address for the keystroke event / if a key has been pressed
#colors
.eqv lightBrown 0xa0522d 		# asteroid color
.eqv darkBrown 0x654321 		# asteroid color
.eqv white 0xffffff 			# ship colour	
.eqv grey 0x808080 			#ship colour
.eqv red 0xff0000 			# game over message colour
.eqv green 0x00ff00 			# game over screen "score" colour
.eqv black 0x000000
#ascii values for keyboard input
.eqv w_ASCII 0x77 			# ascii value for w in hex
.eqv a_ASCII 0x61			# ascii value for a in hex
.eqv s_ASCII 0x73 			# ascii value for s in hex
.eqv d_ASCII 0x64 			# ascii value for d in hex
.eqv p_ASCII 0x70 			# ascii value for p in hex

.data
ship: .word 6, 12, 12, 18 #x, y coordinates of the top right corner of the ship and then the y coordinates of the left and right wing.
obstacle: .word 0, 0			#x, y coordinates of the obstacle
positions: .word 0, 0, 0, 0, 0		#Contains the positions of all the obstacles
dspwn1: .word 0, 0, 0, 0		#Contains the distance from the point at which the obstacle needs to vanish and be generated again elsewhere
screen: .word 31, 0			# x, y coordinates for drawing the screen black		
.text
createShip:
	la $k0, positions		#Initialize the two arrys into registers
	la $k1, dspwn1	
	la $t0, grey 			# load the grey colour
	addi, $sp, $sp, -4 		# move stack up
	sw $t0, 0($sp) 			# store white into the stack
	
	la $t0, white			# load the white colour
	addi, $sp, $sp, -4 		# move stack up
	sw $t0, 0($sp) 			# store white into the stack
	
	jal drawShip
	addi $0, $0, 0
	
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
	sw $s0, 252($s5)
	sw $s0, 384($s5)
	sw $s0, 508($s5)
	sw $s0, 760($s5)
	
	j enemyLocation
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
	
	j end
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

C1:	sw $t0, -12($t3)			#Draws the obstacle
	sw $t0, 112($t3)
	sw $t0, 236($t3)
	sw $t0, 364($t3)
	sw $t0, 492($t3)
	sw $t0, 624($t3)
	

	#return to line after function call
	jr $ra
	addi $0, $0, 0
	
end:	# gracefully terminate the program
	li $v0, 10
	syscall