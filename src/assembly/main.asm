.globl main
.data
str1:	.string	"1=>Yoda\n2=>Maul\n3=>Mando\n"
str2:	.string "select character: "
buff:	.space 172800 # (320 x 180 x 3)
input_filename:	.string "starwars.rgb"
output_filename:	.string "output.rgb"

.text
###############################################################################
# Function: main
# Description: main function of the program
# Arguments:
# -
# Return:
# - void
###############################################################################
main:
	la a0, str1
	li a7, 4	# print char list
	ecall
	
	li t0, 3
	
while:	la a0, str2	# print question
	li a7, 4
	ecall
	li a7, 5	# scanf (int)
	ecall
	blez a0, while
	bgt a0, t0, while
	
	mv a3, a0	# move char. num into temp register
	
	jal read_rgb_image
	
	mv a0, a3
	la a1, buff
	jal location
	
	mv a2, a1
	mv a1, a0
	la a0, buff
	jal draw_crosshair
	jal write_rgb_image
	
	li a0, 0
	li a7, 93	# exit(0)
	ecall
###############################################################################
# Function: read_rgb_image
# Description: reads a file with an image in RGB format into an array in memory
# Arguments:
# - 
# Return:
# - void
###############################################################################
read_rgb_image:
	addi sp, sp, -4
	sw s0, 0(sp)

	la a0, input_filename
	li a1, 0	# read-only flag
	li a7, 1024	# open file
	ecall	
	mv s0, a0
	
	la a1, buff	# get array add.
	li a2, 172800
	li a7, 63	# read file into buffer
	ecall
	
	mv a0, s0
	li a7, 57	# close file
	ecall

	lw s0, 0(sp)
	addi sp, sp, 4
	ret
###############################################################################
# Function: write_rgb_image
# Description: creates a new file with an image in RGB format
# Arguments:
# - 
# Return:
# - void
###############################################################################
write_rgb_image:
	addi sp, sp, -4
	lw s0, 0(sp)
	
	la a0, output_filename
	li a1, 1
	li a7, 1024
	ecall
	mv s0, a0
	
	la a1, buff
	li a2, 172800
	li a7, 64
	ecall
	
	mv a0, s0
	li a7, 57
	ecall
	
	lw s0, 0(sp)
	addi sp, sp, 4
	ret
###############################################################################
# Function: hue
# Description: calculates Hue component from R, G and B components of a pixel
# Arguments:
# a0 - red value
# a1 - green value
# a2 - blue value
# Return:
# a0 - hue value
###############################################################################
hue:
	addi sp, sp, -24
	sw ra, 0(sp)	# return address
	sw a0, 4(sp)	# r
	sw a1, 8(sp)	# g
	sw a2, 12(sp)	# b
	sw s0, 16(sp)	# t0
	sw s1, 20(sp)	# t1
	
	# (r > g && g >= b)
	lw a0, 4(sp)
	lw a1, 8(sp)
	bleu a0, a1, case2	# r > g
	lw a0, 8(sp)
	lw a1, 12(sp)
	bltu a0, a1, case2	# g >= b
	lw a0, 8(sp)
	lw a1, 12(sp)
	sub a0, a0, a1
	mv a1, a0
	slli a1, a1, 4
	sub a1, a1, a0
	slli a1, a1, 2
	mv s0, a1		# s0 = 60 * (g - b)
	lw a0, 4(sp)
	lw a1, 12(sp)
	sub s1, a0, a1		# s1 = (r - b)
	divu a0, s0, s1		# (60 * (g - b)) / (r - b)
	j end
case2:				# (g >= r && r > b)
	lw a0, 8(sp)
	lw a1, 4(sp)
	bltu a0, a1, case3	
	lw a0, 4(sp)
	lw a1, 12(sp)
	bleu a0, a1, case3
	lw a0, 4(sp)
	lw a1, 12(sp)
	sub a0, a0, a1
	mv a1, a0
	slli a1, a1, 4
	sub a1, a1, a0
	slli a1, a1, 2
	mv s0, a1
	lw a0, 8(sp)
	lw a1, 12(sp)
	sub s1, a0, a1
	divu a0, s0, s1
	li s0, 120
	sub a0, s0, a0
	j end
case3:
	lw a0, 8(sp)
	lw a1, 12(sp)
	bleu a0, a1, case4
	lw a0, 12(sp)
	lw a1, 4(sp)
	bltu a0, a1, case4
	lw a0, 12(sp)
	lw a1, 4(sp)
	sub a0, a0, a1
	mv a1, a0
	slli a1, a1, 4
	sub a1, a1, a0
	slli a1, a1, 2
	mv s0, a1
	lw a0, 8(sp)
	lw a1, 4(sp)
	sub s1, a0, a1
	divu a0, s0, s1
	li s0, 120
	add a0, s0, a0
	j end
case4:
	lw a0, 12(sp)
	lw a1, 8(sp)
	bltu a0, a1, case5
	lw a0, 8(sp)
	lw a1, 4(sp)
	bleu a0, a1, case5
	lw a0, 8(sp)
	lw a1, 4(sp)
	sub a0, a0, a1
	mv a1, a0
	slli a1, a1, 4
	sub a1, a1, a0
	slli a1, a1, 2
	mv s0, a1
	lw a0, 12(sp)
	lw a1, 4(sp)
	sub s1, a0, a1
	divu a0, s0, s1
	li s0, 240
	sub a0, s0, a0
	j end
case5:
	lw a0, 12(sp)
	lw a1, 4(sp)
	bleu a0, a1, case6
	lw a0, 4(sp)
	lw a1, 8(sp)
	bltu a0, a1, case6
	lw a0, 4(sp)
	lw a1, 8(sp)
	sub a0, a0, a1
	mv a1, a0
	slli a1, a1, 4
	sub a1, a1, a0
	slli a1, a1, 2
	mv s0, a1
	lw a0, 12(sp)
	lw a1, 8(sp)
	sub s1, a0, a1
	divu a0, s0, s1
	li s0, 240
	add a0, a0, s0
	j end
case6:
	lw a0, 4(sp)
	lw a1, 12(sp)
	bltu a0, a1, case7
	lw a0, 12(sp)
	lw a1, 8(sp)
	bleu a0, a1, case7
	lw a0, 12(sp)
	lw a1, 8(sp)
	sub a0, a0, a1
	mv a1, a0
	slli a1, a1, 4
	sub a1, a1, a0
	slli a1, a1, 2
	mv s0, a1
	lw a0, 4(sp)
	lw a1, 8(sp)
	sub s1, a0, a1
	divu a0, s0, s1
	li s0, 360
	sub a0, s0, a0
	j end
case7:
end:
	lw ra, 0(sp)
	lw s0, 16(sp)	
	lw s1, 20(sp)	
	addi sp, sp, 24
	ret	
###############################################################################
# Function: indicator
# Description: indicates whether or not RGB values belong to character
# Arguments:
# a0 - character
# a1 - red value
# a2 - green value
# a3 - blue value
# Return:
# a0 - true, false value
###############################################################################
indicator:
	addi sp, sp, -12
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)	# t0

	mv s0, a0 	# holds char value
	mv a0, a1
	mv a1, a2
	mv a2, a3
	
	jal hue
	
	li s1, 1
	beq s0, s1, yoda
	li s1, 2
	beq s0, s1, maul
	li s1, 3
	beq s0, s1, mando

yoda:
	li s1, 40
	bltu a0, s1, ret_false
	li s1, 80
	bgtu a0, s1, ret_false
	li a0, 1
	j return
maul:
	li s1, 1
	bltu a0, s1, ret_false
	li s1, 15
	bgtu a0, s1, ret_false
	li a0, 1
	j return
mando:
	li s1, 160
	bltu a0, s1, ret_false
	li s1, 180
	bgtu a0, s1, ret_false
	li a0, 1
	j return
ret_false:
	li a0, 0
return:
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	addi sp, sp, 12
	ret
###############################################################################
# Function: location
# Description: calculates “center of mass” for a certain character
# Arguments:
# a0 - character
# a1 - buffer address
# Return:
# a0 - x coordinate of center of mas
# a1 - y coordinate of center of mas 
###############################################################################
location:
	addi sp, sp, -20
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)
	
	mv s0, a0	# character
	mv s1, a1	# buffer address
	
	li s2, 0	# x of center of mass
	li s3, 0	# y of center of mass
	
	li t0, 0	# counter for x axis 
	li t1, 0	# counter for y axis
	
	li t2, 0	# counter for character
	li t3, 0	# loop counter
	li t4, 172800	# for loop limit
	li t5, 320	# image width 
	
for:
	beq t3, t4, ret_loc	
	
	bne t1, t5, continue	# if (y == 320)
	addi t0, t0, 1		# x++	
	li t1, 0		# y = 0
continue:	
	mv a0, s0
	lbu a1, 0(s1)	# red value
	lbu a2, 1(s1)	# green value
	lbu a3, 2(s1)	# blue value
	
	bne a1, a2, continue_2	# if (red == green && green == blue)
	bne a2, a3, continue_2
	addi t1, t1, 1		# y++
	addi t3, t3, 3		# i++
	addi s1, s1, 3
	j for
continue_2:
	jal indicator
	li t6, 1
	bne a0, t6, else
	addi t2, t2, 1		# count++
	add s2, s2, t0		# cx += x
	add s3, s3, t1 		# cy += y
	addi t1, t1, 1		# y++
	addi t3, t3, 3		# i++
	addi s1, s1, 3
	j for
else:
	addi t1, t1, 1		# y++
	addi t3, t3, 3		# i++
	addi s1, s1, 3
	j for
ret_loc:
	divu a0, s2, t2
	divu a1, s3, t2
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	addi sp, sp, 20
	ret
###############################################################################
# Function: draw_crosshair
# Description: draws a crosshair at the center of mass
# Arguments:
# a0 - buffer address
# a1 - x coordinate of center of mass 
# a2 - y coordinate of center of mass
# Return:
# - void
###############################################################################
draw_crosshair:
	addi sp, sp, -20
	sw a0, 0(sp)	# buffer address
	sw a1, 4(sp)	# cx
	sw a2, 8(sp)	# cy
	sw s0, 12(sp)	# temp register	
	sw s1, 16(sp)	# buffer address holder
	
	li t0, 0	# counter for x axis 
	li t1, 0	# counter for y axis
	li t3, 0	# loop counter
	li t4, 172800	# for loop limit
	li t5, 320
	
	mv s1, a0	
	li t2, 255
	
for_c:
	beq t3, t4, ret_c	# if (i == 172800)
	
	bne t1, t5, continue_c	# if (y == 320)
	addi t0, t0, 1		# x++	
	li t1, 0		# y = 0

continue_c:

	lw s0, 4(sp)
	addi s0, s0, -1
	bne t0, s0, second_c
	lw s0, 8(sp)
	bne t1, s0, second_c
	j draw_c
	
second_c:
	lw s0, 4(sp)
	bne t0, s0, third_c
	lw s0, 8(sp)
	addi s0, s0, -1
	bne t1, s0, third_c
	j draw_c
third_c:
	lw s0, 4(sp)
	bne t0, s0, fourth_c
	lw s0, 8(sp)
	bne t1, s0, fourth_c
	j draw_c
fourth_c:
	lw s0, 4(sp)
	bne t0, s0, fifth_c
	lw s0, 8(sp)
	addi s0, s0, 1
	bne t1, s0, fifth_c
	j draw_c
fifth_c:
	lw s0, 4(sp)
	addi s0, s0, 1
	bne t0, s0, i_c
	lw s0, 8(sp)
	bne t1, s0, i_c
	j draw_c
draw_c:
	sb t2, 0(s1)
	sb zero, 1(s1)
	sb zero, 2(s1)
i_c:
	addi t1, t1, 1	# increment y axis
	addi t3, t3, 1	# increment loop counter
	addi s1, s1, 3	# increment file iterator
	j for_c
ret_c:
	lw s0, 12(sp)
	lw s1, 16(sp)
	addi sp, sp, 20
	ret
	
	
	
