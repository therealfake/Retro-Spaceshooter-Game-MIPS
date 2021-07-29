#####################################################################
#
# CSC258 Summer 2021 Assembly Final Project
# University of Toronto
#
# Student: Tianji Zhang, 1007405808, zha10311
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one that applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
#adresses
.eqv baseAddress .word 0x10008000 # base address for the display
.eqv keystrokeAddress .word 0xffff0000 # memory address for the keystroke event / if a key has been pressed
#colors
.eqv lightBrown 0xa0522d
.eqv darkBrown 0x654321
#ascii values for keyboard input
.eqv w_ASCII 0x77 # ascii value for w in hex
.eqv a_ASCII 0x61 # ascii value for a in hex
.eqv s_ASCII 0x73 # ascii value for s in hex
.eqv d_ASCII 0x64 # ascii value for d in hex
.eqv p_ASCII 0x70 # ascii value for p in hex

.data
enemyBlock: .word 0, 0 # obstacle x, y coordinates 


.text
user_input: 
	li $t9, keystrokeAddress # load the keystroke event address into $t9
	lw $t8, 0($t9) 
	beq $t8, 1, keypress_happened # check if they keystroke event occurred.
keypress_happened:
	lw $t2, 4($t9) # 4($t9) holds the ascii value of the key pressed. NOTE: this assumes $t9 is set to 0xfff0000 from before
	#beq $t2, w_ASCII, respond_to_w # ASCII code of 'w' is 0x77 or 119 in decimal
	#beq $t2, a_ASCII, respond_to_a # ASCII code of 'a' is 0x61 or 97 in decimal
	#beq $t2, s_ASCII, respond_to_s # ASCII code of 's' is 0x73 or 115 in decimal
	#beq $t2, d_AsCII, respond_to_d # ASCII code of 'd' is 0x64 or 100 in decimal
	beq $t2, p_AsCII, reset # ASCII code of 'p' is 0x70 or 112 in decimal
#respond_to_w:
	# move up if not already at the top of the screen
#respond_to_a:
	# move to the left
#respond_to_s:
	# move to the right
#respond_to_d:
	# move down if not already at the bottom of the screen
reset:
	


