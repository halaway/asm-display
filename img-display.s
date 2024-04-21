.data
# DONOTMODIFYTHISLINE
frameBuffer:			.space 0x80000 # 512 wide X 256 high pixels
w:				.word 72
h:				.word 20
l:				.word 10
bgcol:				.word 0x00E6CC9C
# DONOTMODIFYTHISLINE
# Your variables go BELOW here only (and above .text)
blue: .word 0x000203e2
.text
# creating enough space on the stack
addi $sp, $sp, -28	# 24 bytes total 
                                
drawBackGround: 
	la	$t1, frameBuffer	# $t1 ← address of frameBuffer 
	la	$t2, bgcol 		# $t2 ← address of bgcol 
	lw	$t2, 0($t2) 		# $t2 ← bgcol 
	la	$t3, blue 		# $t3 ← address of blue 
	lw 	$t3, 0($t3)		# $t3 ← blue 
	add 	$t4, $zero, $zero 	# i = 0
	
	la 	$t6, w			# $t6 ← address of w
	lw 	$t6, 0($t6)		# $t6 ← w
	la 	$t7, h			# $t7 ← address of h
	lw 	$t7, 0($t7)		# $t7 ← h
	la 	$t8, l			# $t8 ← address of l
	lw 	$t8, 0($t8)		# $t8 ← l
	la 	$t9, blue 		# $t9 ← address of blue 
	lw 	$t9, 0($t9)		# $t9 ← blue 
					# storing on the stack
	sw 	$t8, 0($sp)		# length saved first on stack
	sw 	$t7, 4($sp)		# height saved second on stack
	sw 	$t6, 8($sp)		# width saved third on stack
	sw 	$t2, 20($sp)		# store background color onto stack
					# height from top cap 
					# slope height
					# height of the top left cap corner 
beginLoop:
 	bgt 	$t4, 0x80000, endColor	# if (i < 512 x 256)	
	sll 	$t5, $t4, 2 		# $t5 ← i x 2^2
	add 	$t5, $t1, $t5  		# $t5 ← address of $t1[i] 
	sw 	$t2, 0($t5)		# $t5 ← bgcol 
	addi 	$t4, $t4, 1		# $t4 ← $t4 + 1
	j 	beginLoop		# else
endColor:
errorCases:
	andi 	$t0, $t6, 1		# bit mask least significant bit 
	bnez 	$t0, endLiquid		# if (w % 2 != 0  ) branch
	blt 	$t6, 60, endLiquid	# if (w < 60 ) branch 
	bgt 	$t6, 512, endLiquid	# if (w > 512) branch
	bgt 	$t7, 256, endLiquid	# if (l > 256 ) branch
	bgt 	$t8, 256, endLiquid	# if (h > 256 ) branch
# REGISTERS
#   t3 - y coordinate of top left cap corner
#   t5 - base and height of trapezoid with 45 degree angles
mathPortion:	  
	addi 	$t5, $t6, -48		# $t5 ← w - 48
	srl 	$t5, $t5, 1		# $t5 ← w - 48 / 2
	add 	$t3, $t7, $t8 		# $t3 ← h + l
	add 	$t3, $t3, $t5		# $t3 ← h + l + b
	addi 	$t3, $t3, 64		# $t3 ← h + l + b + 64
	addi 	$t2, $zero, 256		# $t2 ← 256
	sub 	$t3, $t2, $t3		# $t3 ← 256 - h + l + b + 64
	srl 	$t3, $t3, 1		# $t3 ← ( 256 - h + l + b + 64 )  / 2 , y coordindate 
drawCap:
	la 	$t1, frameBuffer 	# $t1 ← address of frameBuffer
	addi 	$t2, $zero, 226		# $t2 ← x cap coordinate
	addi 	$t6, $zero, 0		# row = 0
	addi 	$t0, $t3, 32		# $t0 ← y coordinate + 32 
	sw 	$t3, 12($sp)		# y coordinate stored on stack
	sw 	$t5, 16($sp)		# base stored on stack 
outerCapLoop: 
	sll 	$t2, $t2, 2		# $t2 ← x coordinate offset	
	bgt 	$t6, 60, endDrawCap	# if ( row > 60) branch 
	addi 	$t8, $zero, 0		# cols = 0 
innerCapLoop: 
	sll 	$t4, $t8, 11		# $t4 ← y coordinate offset 
	add 	$t4, $t4, $t1		# $t4 ← address of $t1 + column offset 
	add 	$t4, $t4, $t2		# $t4 ← addr. of $t1 + column offset + row offset 
	blt 	$t8, $t3, conditional	# if ( col < y cap coordinate ) branch
	sw 	$t9, 0($t4)		# $t4 ← blue  	
conditional:
	add 	$t8, $t8, 1 		# $t8 ← $t8 + 1   
	blt 	$t8, $t0, innerCapLoop	# if(col < y coordinate + 32 ) branch
					# outerCapLoop
	addi 	$t6, $t6, 1		# row = row + 1
	srl 	$t2, $t2, 2		# return back to intial value
	addi 	$t2, $t2, 1		# increment row
	j 	outerCapLoop	
endDrawCap: 
halvingRGB:
	lw 	$t5, 20($sp)		# $t5 ← backgroundColor from stack
	andi 	$t4, $t5, 255 		# bit mask for blue component
	andi 	$t3, $t5, 65280		# bit mask for green component 
	andi 	$t6, $t5, 16711680	# bit mask for red component 
	srl 	$t4, $t4, 1		# halving blue component
	srl 	$t3, $t3, 1		# halving green component
	srl 	$t6, $t6, 1		# halving red component
	sll 	$t6, $t6, 16		# red shifted 16 bits to correct position
	sll 	$t3, $t3, 8 		# green shifted 8 bits to correct position
	or 	$t5, $t6, $t3		# combining red and green
	or 	$t5, $t5, $t4 		# $t5 ← halved RGB background color 
	
drawBottleNeck:
	la 	$t1, frameBuffer	# $t1 ← address of frameBuffer
	addi 	$t6, $zero, 0		# rows i = 0
	lw 	$t3, 12($sp)		# height of top left cap corner from stack	53
	addi 	$t0, $t3, 64 		# $t0 ← height + 64
	addi 	$t3, $t3, 32		# $t3 ←  y coordinate of bottom left corner of bottleneck
	addi	$t2, $zero, 232		# $t2 ← x coordinate of top left bottleneck corner ie.) 226 + 6
outBottleNeck:
	sll 	$t2, $t2, 2 		# $t2 ← x coordinate offset 
	bgt 	$t6, 48, endBottle	# if ( rows > 48 ) branch 
	addi 	$t8, $zero, 0		# cols = 0
inBottleNeck:				# column traversal loop
	sll 	$t4, $t8, 11		# $t4 ← y coordinate offset 
	add 	$t4, $t4, $t1		# $t4 ← address of $t1 + column offset
	add 	$t4, $t4, $t2		# $t4 ← address of $t1 + column offset + row offset
	blt 	$t8, $t3, bottleCond	# if( cols < y coordinate of bottom left corner ) branch 
	sw 	$t5, 0($t4)		# $t4 ← backgroundColor halved  
bottleCond:
	addi 	$t8, $t8, 1		# cols = cols + 1 
	blt 	$t8, $t0, inBottleNeck	# if( cols < height + 64 ) branch 
	
	addi 	$t6, $t6, 1 		# rows = rows + 1
	srl 	$t2, $t2, 2		# return x coordinate back to initial value
	addi 	$t2, $t2, 1		# rows = rows + 1
	j 	outBottleNeck		# outer Loop
endBottle:
# traversing down and going across while subtracting on each side  
drawSlope:
	la 	$t1, frameBuffer	# $t1 ← address of frameBuffer
	addi 	$t8, $zero, 0		# col = 0
	lw 	$t9, 16($sp)		# $t9 ← trapezoid height from stack 12
	lw 	$t3, 12($sp)		# $t3 ← height of cap from top
	addi 	$t3, $t3, 64		# $t3 ← height of cap + 64 for bottom of bottle neck
	add 	$s0, $t5, $zero 	# $s0 ← background color	
	addi	$t5, $zero, 49		# $t5 ← 48 ( initial row width ) 
	addi 	$t2, $zero, 232		# $t2 ← 232 ( inital x coordinate )
Outside:
	sll 	$t4, $t3, 11		# $t4 ← y coordinate offset 
	bgt 	$t8, $t9, exitLoops	# if (col > trapezoid Height) branch
	add 	$t4, $t4, $t1		# $t4 ← address of $t1 + y coordinate offset 
	sll 	$t2, $t2, 2 		# $t2 ← x coordinate offset  
	add 	$t4, $t4, $t2		# $t4 ← address of $t1 + y coordinate offset + x coordinate offset 
	addi 	$t6, $zero, 0		# i = 0 horizontal traversal 
inside:
	sll 	$t7, $t6, 2		# $t7 ← i offset 
	add 	$t0, $t4, $t7		# $t0 ← address of $t4 + i offset
	
	sw 	$s0,  0($t0)		# $t0 ← background color halved  
	addi 	$t6, $t6, 1		# $t6 ← $t6 + 1 
	blt 	$t6, $t5, inside	# if( i < row width) branch to inner loop
	addi 	$t5, $t5, 2		# row width increases by one pixel
	srl 	$t2, $t2, 2		# revert back into x coordinate
	addi 	$t2, $t2, -1		# subtract from x cooridinate
	addi 	$t8, $t8, 1		# col = col + 1  
	addi 	$t3, $t3, 1 		# $t3 ← $t3 + 1 
	
	j 	Outside			# jump to Outside loop 
exitLoops:
# REGISTER
#   t9 - starting y coordinate for body of the flask
drawBottomFlask:
	la 	$t1, frameBuffer	# $t1 ← address of frameBuffer 
	addi 	$t6, $zero, 0		# i = 0
	li	$t3, 232		# $t3 ← bottle neck x coordinate  
	lw 	$t0, 16($sp)		# $t0 ← trapezoid base  
	sub 	$t2, $t3, $t0		# $t2 ← bottle neck coordinate - trapezoid base 
	lw 	$t9, 12($sp)		# $t9 ← height of top left corner of cap  
	addi	$t9, $t9, 64		# $t9 ← y coordinate of top left corner + 64 
	add 	$t9, $t9, $t0		# $t9 ← y coordinate + trapezoid height 
	sw 	$t9, 24($sp)		# store y coordinate + trapezoid height on stack
	lw 	$t5, 8($sp)		# $t5 ← width
	add 	$t0, $t9, $t5		# $t0 ← y coordinate of bottom left corner + width
	lw 	$t7, 4($sp)		# $t7 ← height  
outerFlask:
	sll 	$t2, $t2, 2		# $t3 ← x coordinate offset
	bgt 	$t6, $t5, endFlask	# if( i > width ) branch
	addi 	$t8, $zero, 0		# y = 0
innerFlask:
	sll 	$t4, $t8, 11		# $t4 ← y offset 
	add 	$t4, $t4, $t1		# $t4 ← address of $t1 + y offset 
	add 	$t4, $t4, $t2		# $t4 ← address of t1 + y offset + x offset 
	blt	$t8, $t9, skipPixel	# if (i < y coordinate + trapezoid height) branch
	sw 	$s0, 0($t4)		# $t4 ← background color 
skipPixel:
	addi 	$t8, $t8, 1		# $t8 ← $t8 + 1 
	blt 	$t8, $t0, innerFlask	# if( i < y coordinate of bottom left corner + width ) branch
	addi	$t6, $t6, 1 		# $t6 ← $t6 + 1 
	srl 	$t2, $t2, 2		# return back to initial value
	addi 	$t2, $t2, 1		# increment + 1
	j 	outerFlask		# jump to outer Loop 
endFlask:
swapRedAndBlue:			
	lw 	$t3, 20($sp) 		# $t3 ← background color
	andi 	$t4, $t3, 255 		# $t4 ← Blue Component lower 4 bits, 1111 1111 
	sll 	$t4, $t4, 16		# shift blue left 16 bits into place
	andi 	$t5, $t3, 65280		# $t3 ← Green Component bits 15:7, 1111 1111 0000 0000
	andi	$t6, $t3, 16711680	# $t6 ← Red Component bits 23:16, 1111 1111 00...000
	srl 	$t6, $t6, 16		# shifting red components to blue position
	xor 	$t5, $t5, $t6		# or to get green and red position into place	
	xor 	$t5, $t5, $t4		# or to get blue green and red position into place
drawLiquid:
	la 	$t1, frameBuffer	# $t1 ← address of frameBuffer
	addi 	$t6, $zero, 0		# i = 0
	li 	$t3, 232		# $t6 ←  bottle neck x coordinate  
	lw 	$t0, 16($sp)		# $t0 ← trapezoid base  
	sub 	$t2, $t3, $t0		# $t2 ← bottle neck x coordinate - trapezoid base
	lw 	$t9, 24($sp)		# $t9 ← y coordinate of top left corner of flask
	lw 	$t0, 8($sp)		# $t0 ← height 
	add 	$t9, $t9, $t0		# $t9 ← top left flask corner y coordinate + width
	lw 	$t0, 0($sp)		# $t0 ← length 
	add 	$t0, $t0, $t9		# $t0 ← length + top left corner y coordinate  
	lw 	$t8, 8($sp)		# $t8 ← width 
outerLiquid:
	sll 	$t2, $t2, 2 		# $t2 ← x coordinate offset 
	bgt 	$t6, $t8 endLiquid	# if( i > width ) branch 
	addi 	$t7, $zero, 0		# j = 0
innerLiquid:
	sll 	$t4, $t7, 11		# $t4 ← j x 2 ^ 11 
	add 	$t4, $t4, $t1		# $t4 ← address of $t1 + j offset 
	add 	$t4, $t4, $t2		# $t4 ← address of $t1 + j offset + i offset 
	blt 	$t7, $t9, skip
	sw 	$t5, 0($t4)		# $t4 ← liquid color 
skip:
	addi 	$t7, $t7, 1		# j = j + 1
	blt 	$t7, $t0, innerLiquid	# if (j < $t0 ) branch 
	addi 	$t6, $t6, 1 		# i = i + 1 
	srl 	$t2, $t2, 2		# return back to initial value
	addi 	$t2, $t2, 1		# $t2 ← $t2 + 1
	j 	outerLiquid
endLiquid:
	li $v0,10		# exit code
	syscall 		# exit to OS :(
	
	

