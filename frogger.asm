#####################################################################
#
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Name, Student Number
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256 
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
# ERROR CODES
# 10 - Screen size is not a multiple of 64
# 20 - Canvas Size not set
# 30 - BlockSize not set
# 100 - frog x position out of range
# 110 - frog y position out of range
# 200 - Non-Static is not set
# 400 - frog blocksize not implemented
#####################################################################
.data
displayAddress: .word 0x10008000
unitSize: .word 4
screenSize: .word 256
canvasSize: .word 0 		# A calculated value which stores how many pixels are on the screen
blockDim: .word 8		# This determines how large the frog is, (blockSize x blockSize)
blockSize: .word 0

non_static: .word 0

red: .word 0x00ff0000
green: .word 0x0000ff00
blue: .word 0x000000ff

color: .word 0x000000ff

goal_region_color: .word 0x000ff00
water_region_color: .word 0x000000ff
safe_region_color: .word 0x00c2b280
road_region_color: .word 0x00333333
starting_region_color: .word 0x00aabb33

car_color: .word 0x00850101
log_color: .word 0x00ba8c63

drawing_acc: .word 0

frog_color: .word 0x0000cc00
frog_pos_x: .word 0
frog_pos_y: .word 0

game_state_a: .word 0 
game_state_b: .word 1
game_state_c: .word 0 
game_state_d: .word -1

car_draw_1: .word 0 
car_draw_2: .word 0 

log_draw_1: .word 0 
log_draw_2: .word 0 

coll_mode: .word 0
coll_code: .word 0

is_half: .word 0

frames: .word 0

lives: .word 3

.text
# Function template --------------

# label:
# addiu $sp, $sp, -4		# Allocate word on stack
# sw $ra, 0($sp)		# Set current stack element to $ra

# ... code ...

# lw $ra, 0($sp)		# Load previous $ra value from stack
# addiu $sp, $sp, 4		# unallocate stack word
# jr $ra			# Jump back



jal init
j program_loop

############################### Calculate frog start ############################### 
calculate_frog_start:
lw $t0, blockSize		
addi $a0, $zero, 30		
beqz $t0, exit_with_error	# report error if blockSize is not set

addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

la $t1, frog_pos_x
la $t2, frog_pos_y


sra $t3, $t0, 1

sw $t3, 0($t1)

addi $t4, $t0, -1

sw $t4, 0($t2)

lw $ra, 0($sp)			# Load previous $ra value from stack

addiu $sp, $sp, 4		# unallocate stack word
jr $ra				# Go back to calling program

############################### Calculate canvas size ############################### 
calculate_canvas_size:
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

lw $t0, screenSize 		# Load screen size
lw $t1, unitSize		# Load unit size	 		
div $t0, $t1			# screenSize/unitSize
la $t2, canvasSize		# Load address of canvasSize into $t2
mflo $t3			# Read output of division into $t3
sw $t3, 0($t2)			# Store $t3 into canvasSize
addi $t5, $zero, 32		# Store int into $t5 - let us call this min_screenSize
div $t3, $t5			# Divide $t3 by $t5
mfhi $t4			# Read the remainder of division 
addi $a0, $zero, 10		# Set error code to 10		
bgtz $t4, exit_with_error 	# If $t3 is not a multiple of min_screenSize, exit with an error. (This checks that the screen is at least min_screenSize X min_screenSize)

lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra				# Go back to calling program

############################### Calculate block size ############################### 
calculate_block_size:
lw $t0, canvasSize		
addi $a0, $zero, 20		
beqz $t0, exit_with_error	# report error if canvasSize is not set

addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

lw $t1, blockDim

div $t0, $t1
mflo $t2

la $t3 blockSize
sw $t2, 0($t3)

lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra				# Go back to calling program


############################### Draw rectangle ############################### 
draw_rect:
				# Function to draw rectangle, $a0 - width, $a1 - height, $a2 - x, $a3 - y
				# This function prevents drawing outside and does not let the drawing loop around.
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

addi $s7, $zero, 4

lw $s0, displayAddress		# Load display address
lw $s1, canvasSize		
lw $s3, color
				
mult $s1, $s7			# Calculate canvasSize * 4 
mflo $s2

mult $a0, $s7			# Calculate a0*4
mflo $t2

mult $s2, $a1			# Calculate a1*canvasSize*4
mflo $t4

sub $s4, $s1, $a0
sub $s5, $s1, $a1

add $t3, $t2, $t4		# Calculate a2 + a3 position in pixels into cur_pos
addi $t0, $zero, 0		# y_val = 0
rect_y_loop:
beq $t0, $a3, rect_y_end	# loop y_val -> a1
addi $t1, $zero, 0		# x_val = 0
bge $t0, $s5, rect_x_end	# if x_pos > (height - a1)
rect_x_loop:
beq $t1, $a2, rect_x_end	# loop x_val -> a0
bge $t1, $s4, rect_x_end	# if x_pos > (width - a0)
add $t5, $s0, $t3
sw $s3, 0($t5)
rect_skip_draw:
addi $t3, $t3, 4		# cur_pos += 4
addi $t1, $t1, 1		# x_val += 1
j rect_x_loop
rect_x_end:
mult $t1, $s7
mflo $t4

add $t3, $t3, $s2		# cur_pos += canvasSize * 4 
sub $t3, $t3, $t4		# cur_pos -= x_val * 4
addi $t0, $t0, 1		# y_val += 1
j rect_y_loop
rect_y_end:

lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra				# go back to calling program

############################### Draw Background ############################### 
draw_background:
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

lw $s0, blockSize

sub $t0, $s0, 4			#t0 = blocksize - 4

addi $t2, $zero, 2		# t2 = 2
div $t0, $t2			# (blocksize - 4)/2

la $t6, non_static
mflo $s1			# Size of non-static portions of level
sw $s1, 0($t6)


la $t2, color
lw $t0, starting_region_color
sw $t0, 0($t2)			# set color = starting_region_color

lw $t0, blockDim		# load blockdim into t0
lw $t1, canvasSize

addi $a0, $zero, 0
addi $a1, $zero, 0
add $a2, $zero, $t1
add $a3, $zero, $t0

la $t5, drawing_acc
sw $t0, 0($t5)
jal draw_rect			# rect(0,0,canvasSize, blockSize)

lw $t0, blockDim
lw $t1, canvasSize
la $t2, color
lw $t5, water_region_color
sw $t5, 0($t2)			# set color = water_region_color

lw $t3, drawing_acc

lw $s1, non_static

mult $t0, $s1

mflo $t4

addi $a0, $zero, 0
add $a1, $zero, $t3
add $a2, $zero, $t1
add $a3, $zero, $t4

la $t5, drawing_acc
add $t4, $t4, $t3
sw $t4, 0($t5)

jal draw_rect			# rect(0,blockSize + 1,canvasSize, s1)

lw $t0, blockDim
lw $t1, canvasSize
la $t2, color
lw $t5, safe_region_color
sw $t5, 0($t2)			# set color = safe_region_color

lw $t3, drawing_acc

lw $s1, non_static



addi $a0, $zero, 0
add $a1, $zero, $t3
add $a2, $zero, $t1
add $a3, $zero, $t0

la $t5, drawing_acc
add $t0, $t0, $t3
sw $t0, 0($t5)

jal draw_rect			# rect(0,blockSize + 1,canvasSize, s1)

lw $t0, blockDim
lw $t1, canvasSize
la $t2, color
lw $t5, road_region_color
sw $t5, 0($t2)			# set color = water_region_color

lw $t3, drawing_acc
lw $s1, non_static

mult $t0, $s1

mflo $t4

addi $a0, $zero, 0
add $a1, $zero, $t3
add $a2, $zero, $t1
add $a3, $zero, $t4

la $t5, drawing_acc
add $t4, $t4, $t3
sw $t4, 0($t5)

jal draw_rect			# rect(0,blockSize + 1,canvasSize, s1)

lw $t0, blockDim
lw $t1, canvasSize
la $t2, color
lw $t5, starting_region_color
sw $t5, 0($t2)			# set color = safe_region_color

lw $t3, drawing_acc
lw $s1, non_static


add $t0, $t0, $t0

addi $a0, $zero, 0
add $a1, $zero, $t3
add $a2, $zero, $t1
add $a3, $zero, $t0

la $t5, drawing_acc
add $t0, $t0, $t3
sw $t0, 0($t5)
jal draw_rect			# rect(0,blockSize + 1,canvasSize, s1)


lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word
jr $ra				# go back to calling program

############################### Block pos to XYpixel ############################### 
block_to_xy:			#a0 -> block_x, a1->block_y
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

lw $s0, blockDim
lw $s1, canvasSize
addi $s6, $zero, 4

mult $a1, $s0			# a1 * blockSize = y_pixel_position
mflo $v1			# v1 = 

mult $a0, $s0			# a0 * blockSize = x_pixel_position
mflo $v0			# v0 =

lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra				# go back to calling program

############################### Block Pos to addrOffset ############################### 
block_to_pixel:			# a0 - > block_x, a1-> block_y
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

lw $s0, blockDim
lw $s1, canvasSize
addi $s6, $zero, 4

mult $a1, $s0			# a1 * blockSize = pixel_position
mflo $t0			# t0 = 

mult $a0, $s0			# a0 * blockSize = pixel_position
mflo $t1			

mult $t0, $s1			#a1 * blockSize * canvasSize
mflo $t0

add $v0, $t0, $t1		#v0 = a1*blockSize*canvasSize + a0*blockSize
mult $v0, $s6			#v0 = v0*4
mflo $v0

lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra				# go back to calling program

############################### Draw Frog ############################### 
draw_frog:
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

lw $s0, frog_pos_x
lw $s1, frog_pos_y
lw $s2, blockSize
lw $s3, blockDim




addi $t0, $zero, 100
bge $s0, $s2, exit_with_error 	# frog x position out of range
addi $t0, $zero, 110
bge $s1, $s2, exit_with_error	# frog y position out of range



add $a0, $zero, $s0
add $a1, $zero, $s1
jal block_to_pixel

addi $t0, $zero, 4
addi $t1, $zero, 8
lw $s4, displayAddress
lw $s6, canvasSize
lw $s5, frog_color
add $t3, $zero, $v0
add $t3, $s4, $t3

mult $s6, $t0
mflo $t4

bgt $s3, $t0, frog_block_ge_four
sw $s5, 0($t3)
sw $s5, 12($t3)

add $t3, $t3, $t4
sw $s5, 0($t3)
sw $s5, 4($t3)
sw $s5, 8($t3)
sw $s5, 12($t3)

add $t3, $t3, $t4
sw $s5, 4($t3)
sw $s5, 8($t3)

add $t3, $t3, $t4
sw $s5, 0($t3)
sw $s5, 4($t3)
sw $s5, 8($t3)
sw $s5, 12($t3)

j frog_finish
frog_block_ge_four:
bgt $s3, $t1, frog_block_ge_eight
sw $s5, 0($t3)
sw $s5, 4($t3)
sw $s5, 24($t3)
sw $s5, 28($t3)

add $t3, $t3, $t4
sw $s5, 0($t3)
sw $s5, 4($t3)
sw $s5, 24($t3)
sw $s5, 28($t3)

add $t3, $t3, $t4
sw $s5, 0($t3)
sw $s5, 4($t3)
sw $s5, 8($t3)
sw $s5, 12($t3)
sw $s5, 16($t3)
sw $s5, 20($t3)
sw $s5, 24($t3)
sw $s5, 28($t3)

add $t3, $t3, $t4
sw $s5, 0($t3)
sw $s5, 4($t3)
sw $s5, 8($t3)
sw $s5, 12($t3)
sw $s5, 16($t3)
sw $s5, 20($t3)
sw $s5, 24($t3)
sw $s5, 28($t3)

add $t3, $t3, $t4
sw $s5, 8($t3)
sw $s5, 12($t3)
sw $s5, 16($t3)
sw $s5, 20($t3)

add $t3, $t3, $t4
sw $s5, 8($t3)
sw $s5, 12($t3)
sw $s5, 16($t3)
sw $s5, 20($t3)

add $t3, $t3, $t4
sw $s5, 0($t3)
sw $s5, 4($t3)
sw $s5, 8($t3)
sw $s5, 12($t3)
sw $s5, 16($t3)
sw $s5, 20($t3)
sw $s5, 24($t3)
sw $s5, 28($t3)

add $t3, $t3, $t4
sw $s5, 0($t3)
sw $s5, 4($t3)
sw $s5, 8($t3)
sw $s5, 12($t3)
sw $s5, 16($t3)
sw $s5, 20($t3)
sw $s5, 24($t3)
sw $s5, 28($t3)




# addi $a0, $zero, 400
# j exit_with_error

j frog_finish
frog_block_ge_eight:
addi $a0, $zero, 120
j exit_with_error

frog_finish:
lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra				# go back to calling program


############################### Check Keyboard Input ############################### 
get_keyboard_input:
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

addi $v0, $zero, 0
lw $t8, 0xffff0000
beq $t8, 1, keyboard_input

j end_keyboard_input
keyboard_input:
lw $s0, frog_pos_x
lw $s1, frog_pos_y

lw $t2, 0xffff0004
beq $t2, 0x77, keyboard_w
beq $t2, 0x61, keyboard_a
beq $t2, 0x73, keyboard_s
beq $t2, 0x64, keyboard_d
j end_keyboard_input

######## A
keyboard_a:
beqz $s0, kb_skip_a
la $s2, frog_pos_x
addi $s0, $s0, -1
sw $s0, 0($s2)
addi $v0, $zero, 1
kb_skip_a:
j end_keyboard_input

######## W
keyboard_w:
beqz $s1, kb_skip_w
la $s3, frog_pos_y
addi $s1, $s1, -1
sw $s1, 0($s3)
addi $v0, $zero, 1
kb_skip_w:
j end_keyboard_input

######## S
keyboard_s:
lw $t3, blockSize
addi $t3, $t3, -1
bge $s1, $t3, kb_skip_s
la $s3, frog_pos_y
addi $s1, $s1, 1
sw $s1, 0($s3)
addi $v0, $zero, 1
kb_skip_s:

j end_keyboard_input
######## D
keyboard_d:
lw $t3, blockSize
addi $t3, $t3, -1
bge $s0, $t3, kb_skip_s
la $s2, frog_pos_x
addi $s0, $s0, 1
sw $s0, 0($s2)
addi $v0, $zero, 1
kb_skip_d:
j end_keyboard_input
end_keyboard_input:

lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra		

############################### Delay ############################### 
kill_frog:
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

la $t0, lives
lw $t1, lives
addi $t1, $t1, -1

beqz $t1, exit
sw $t1, 0($t0)

lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra		

############################### Delay ############################### 
delay:
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

li $v0, 32
li $a0, 16
syscall

lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra	


############################### inc_wrap ############################### 
inc_wrap:
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

addi $v0, $a0, 1

addi $t1, $zero, 2

beq $v0, $t1, inc_reset
j inc_skip_reset

inc_reset:
addi $v0, $zero, -1


inc_skip_reset:
lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra		


############################### dec_wrap ############################### 
dec_wrap:
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

addi $v0, $a0, -1

addi $t1, $zero, -2

beq $v0, $t1, dec_reset
j dec_skip_reset

dec_reset:
addi $v0, $zero, 1 


dec_skip_reset:
lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra		

############################### Update Game State ############################### 
update_game_state:
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

la $t2, game_state_a
lw $a0, game_state_a
jal inc_wrap
sw $v0, 0($t2)

la $t2, game_state_b
lw $a0, game_state_b
jal dec_wrap
sw $v0, 0($t2)

la $t2, game_state_c
lw $a0, game_state_c
jal inc_wrap
sw $v0, 0($t2)

la $t2, game_state_d
lw $a0, game_state_d
jal dec_wrap
sw $v0, 0($t2)

lw $a1, coll_mode
lw $a0, coll_code
lw $s0, frog_pos_x
beq $a1, 1, move_frog
j dont_move_frog

move_frog:
beq $a0, 4, update_frog_left
lw $t3, blockSize
blez $s0, frog_skip_right
la $s2, frog_pos_x
addi $s0, $s0, -1
sw $s0, 0($s2)
frog_skip_right:
j dont_move_frog


update_frog_left:
lw $t3, blockSize
addi $t3, $t3, -1
bge $s0, $t3, frog_skip_left
la $s2, frog_pos_x
addi $s0, $s0, 1
sw $s0, 0($s2)
frog_skip_left:
dont_move_frog:

lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra

############################### Check Map pos ############################### 
				#map -1: 1, 0:0, 1:2
check_get_map:
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

beq $a0, -1, map_minus
beq $a0, 1, map_one
addi $v0, $zero, 0
j map_end
map_minus:
addi $v0, $zero, 1
j map_end

map_one:
addi $v0, $zero, 2
j map_end

map_end:
lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra				# Go back to calling program

############################### UpdateFrog ############################### 
update_frog:
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra
				# a0 -> code from check_collision (0- nothing, 1 - car, 2- car, 3- log L, 4- log right)
				# a1 -> s7 from check_collision
				
lw $a0, coll_code
lw $a1, coll_mode
bgtz $a1, log_move
beqz $a0, end_update_frog
reset_frog:
addi $a0, $a1, 0
li $v0, 1
syscall

jal calculate_frog_start
jal kill_frog
j end_update_frog
log_move:
lw $s0, frog_pos_x
lw $s1, frog_pos_y

beqz $a0, reset_frog
end_update_frog:
lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra				# Go back to calling program


############################### Check collision ############################### 
check_collision: 
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

lw $s0, frog_pos_x
lw $s1, frog_pos_y
lw $s2, non_static

addi $t2, $s2, 2	
addi $v0, $zero, 0
addi $s7, $zero, 0	
bge $s1, $t2, check_road_area
bge $s1, 1, check_water_area
j end_check

check_road_area:
add $t2, $t2, $s2
bge $s1, $t2, end_check

addi $t2, $s2, 2

sub $t0, $s1, $t2

addi $t1, $zero, 2
div $t0, $t1
mfhi $t0

beqz $t0, check_state_a
j check_state_b
j end_check

check_water_area:

bgt $s1, $s2, end_check
addi $s7, $zero, 1
addi $t0, $s1, -1

addi $t1, $zero, 2
div $t0, $t1
mfhi $t0
addi $s0, $s0, 2
beqz $t0, check_state_c
j check_state_d
j end_check

check_state_a:
lw $a0, game_state_a
addi $v1, $zero, 1
j end_check_col

check_state_b:
lw $a0, game_state_b
addi $v1, $zero, 2
j end_check_col

check_state_c:
lw $a0, game_state_c
addi $v1, $zero, 3
j end_check_col

check_state_d:
lw $a0, game_state_d
addi $v1, $zero, 4
j end_check_col

no_collision:

addi $v0, $zero, 0
j end_check

end_check_col:
jal check_get_map
addi $t3, $zero, 3
div $s0, $t3
mfhi $t2
beq $t2, $v0, no_collision
addi $v0, $v1, 0


end_check:

la $t0, coll_code
la $t1, coll_mode
sw $v0, 0($t0)
sw $s7, 0($t1)

lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra				# Go back to calling program


############################### Init ############################### 
init: 
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

jal calculate_canvas_size	# Calcuate canvas size and set the canvasSize label
jal calculate_block_size	
jal calculate_frog_start

lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra				# Go back to calling program

############################### Draw Log ############################### 
draw_log:			#a0 = blockX, $a1= blockY
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

bltz $a0, log_half

la $t0, is_half
sw $zero, 0($t0)

j end_log_half

log_half:
addi $t1, $zero, 1
la $t0, is_half
sw $t1, 0($t0)
end_log_half:

jal block_to_xy

lw $t0, is_half
beqz $t0, log_draw_reg

log_draw_half:
lw $s2, blockDim
add $s0, $s2, $v0		# x position
add $s1, $zero, $v1		# y position


addi $a3, $s2, -2		# height = blocksize - 2
# addi $a3, $s2, 0
add $a2, $s2,$zero		# width = blocksize
addi $a2, $a2, -1		# width -= 2

addi $a0, $s0, 0
addi $a1, $s1, 1

j log_draw_main
log_draw_reg:
add $s0, $zero, $v0		# x position
add $s1, $zero, $v1		# y position
lw $s2, blockDim

addi $a3, $s2, -2		# height = blocksize - 2
# addi $a3, $s2, 0
add $a2, $s2,$s2		# width = blocksize * 2
addi $a2, $a2, -2		# width -= 2

addi $a0, $s0, 1
addi $a1, $s1, 1

log_draw_main:
la $t2, color
lw $t5, log_color	
sw $t5, 0($t2)			# set color = water_region_color
jal draw_rect

lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra				# go back to calling program


############################### Draw All Logs ############################### 
draw_all_logs:
lw $s0, non_static		
addi $a0, $zero, 200		
beqz $s0, exit_with_error	# report error if canvasSize is not set

addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

lw $t8, game_state_c
lw $t9, game_state_d

addi $a1, $zero, 1		# y_block = 1

draw_all_logs_outer_loop:
lw $s0, non_static	
addi $s0, $s0, 1
bge $a1, $s0, draw_all_logs_end_loop	# loop until y_pos > 2*non_static  for each row

addi $t4, $zero, 2
div $a1, $t4
mfhi $t4
beqz $t4, draw_all_l_state_a

add $a0, $zero, $t9
j draw_all_l_inner_loop

draw_all_l_state_a:
add $a0, $zero, $t8
j draw_all_l_inner_loop

draw_all_l_inner_loop:
lw $s0, blockSize
bge $a0, $s0, draw_all_logs_end_iloop	# Loop until end of screen

la $s5, log_draw_1
la $s6, log_draw_2

sw $a0, 0($s5)
sw $a1, 0($s6)

jal draw_log

lw $a0, log_draw_1
lw $a1, log_draw_2

addi $a0, $a0, 3
j draw_all_l_inner_loop
draw_all_logs_end_iloop:

addi $a1, $a1, 1
j draw_all_logs_outer_loop
draw_all_logs_end_loop:

lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra				# Go back to calling program

############################### Draw Car ############################### 
draw_car:			#a0 = blockX, $a1= blockY
addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

bltz $a0, car_half

la $t0, is_half
sw $zero, 0($t0)

j end_car_half

car_half:
addi $t1, $zero, 1
la $t0, is_half
sw $t1, 0($t0)
end_car_half:

jal block_to_xy

lw $t0, is_half
beqz $t0, car_draw_reg

carog_draw_half:
lw $s2, blockDim
add $s0, $s2, $v0		# x position
add $s1, $zero, $v1		# y position


addi $a3, $s2, -2		# height = blocksize - 2
# addi $a3, $s2, 0
add $a2, $s2,$zero		# width = blocksize
addi $a2, $a2, -1		# width -= 2

addi $a0, $s0, 0
addi $a1, $s1, 1

j car_draw_main
car_draw_reg:
add $s0, $zero, $v0		# x position
add $s1, $zero, $v1		# y position
lw $s2, blockDim

addi $a3, $s2, -2		# height = blocksize - 2
# addi $a3, $s2, 0
add $a2, $s2,$s2		# width = blocksize * 2
addi $a2, $a2, -2		# width -= 2

addi $a0, $s0, 1
addi $a1, $s1, 1

car_draw_main:
la $t2, color
lw $t5, car_color	
sw $t5, 0($t2)			# set color = water_region_color
jal draw_rect

lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra				# go back to calling program


############################### Draw All Cars ############################### 
draw_all_cars:
lw $s0, non_static		
addi $a0, $zero, 200		
beqz $s0, exit_with_error	# report error if canvasSize is not set

addiu $sp, $sp, -4		# Allocate word on stack
sw $ra, 0($sp)			# Set current stack element to $ra

lw $t8, game_state_a
lw $t9, game_state_b

addi $a1, $s0, 2		# y_block = non_static + 1

draw_all_cars_outer_loop:
lw $s0, non_static
sll $s0, $s0, 1	
addi $s0,$s0, 2	
bge $a1, $s0, draw_all_cars_end_loop	# loop until y_pos > 2*non_static  for each row

addi $t4, $zero, 2
div $a1, $t4
mfhi $t4
beqz $t4, draw_all_state_a

add $a0, $zero, $t9
j draw_all_inner_loop

draw_all_state_a:
add $a0, $zero, $t8
j draw_all_inner_loop

draw_all_inner_loop:
lw $s0, blockSize
bge $a0, $s0, draw_all_cars_end_iloop	# Loop until end of screen

la $s5, car_draw_1
la $s6, car_draw_2

sw $a0, 0($s5)
sw $a1, 0($s6)

jal draw_car

lw $a0, car_draw_1
lw $a1, car_draw_2

addi $a0, $a0, 3
j draw_all_inner_loop
draw_all_cars_end_iloop:

addi $a1, $a1, 1
j draw_all_cars_outer_loop
draw_all_cars_end_loop:

lw $ra, 0($sp)			# Load previous $ra value from stack
addiu $sp, $sp, 4		# unallocate stack word

jr $ra				# Go back to calling program

############################### Program loop ############################### 
program_loop:


jal get_keyboard_input
bgtz $v0, update

la $t0, frames
lw $t1, frames	

addi $t1, $t1, 1
sw $t1, 0($t0)

beq $t1, 59, advance_state
bgt $t1, 60, update
j end_update

update:
la $t0, frames
lw $t1, frames
addi $t1, $t1, 1
sw $t1, 0($t0)
jal check_collision
jal update_frog
jal check_collision
jal draw_background
jal draw_frog
jal draw_all_cars
jal draw_all_logs
jal get_keyboard_input

lw $t0, frames
bge $t0, 59, reset_state
j end_state

advance_state:
jal update_game_state
jal update_frog
j end_state

reset_state:
la $t0, frames
sw $zero, 0($t0)
end_reset_state:
end_update:
end_state:

jal delay

j program_loop

exit_with_error:
li $v0, 1
syscall
j exit

exit:
li $v0, 10
syscall 

