# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)

.eqv white 0xffffff 	
.eqv grey 0x808080 
.eqv red 0xff0000
.eqv baseAddress 0x10008000 		# base address for the display

li $t0, 0x10008594
drawShip:
	la $t1, white	#load the colour white into $t1
	la $t2, grey	#load the colour grey into $t2
	#sw $t1, 0($t0)
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t2, 512($t0)
	sw $t1, 388($t0)
	sw $t1, 516($t0)
	sw $t1, 644($t0)
	sw $t1, 520($t0)
	sw $t1, 640($t0)
	sw $t1, 768($t0)
	sw $t1, 896($t0)
	#sw $t1, 1024($t0)
	#sw $t1, 124($t0)
	sw $t1, 252($t0)
	sw $t1, 380($t0)
	sw $t2, 508($t0)
	sw $t1, 636($t0)
	sw $t1, 764($t0)
	#sw $t1, 892($t0)
	sw $t1, 376($t0)
	sw $t1, 504($t0)
	sw $t1, 632($t0)
	sw $t1, 500($t0)
	sw $t1, 368($t0)
	sw $t1, 496($t0)
	sw $t1, 624($t0)
	
	la $t0, red
	la $t1, baseAddress
	addi $t2, $zero, 4092
	add $t1, $t1, $t2
	sw $t0, 0($t1)
end:
	li $v0, 10
	syscall
