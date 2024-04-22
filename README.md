# MIPS Assembly Bitmap Display

As part of a uni architecture course, the following creates a rendering of an image on a 512 x 256 2D Bitmap display. Using the MIPS Assembler and Runtime Simulator [MARS](https://courses.missouristate.edu/kenvollmar/mars/), the program uses MIPS assembly code for the MIPS Architecture- a Reduced Instruction Set Computer(RISC) with C-style structures containing 32-bit ints in the form: 
```c
struct asmInput {
  unsigned w, h, l; // size parameters
  unsigned bgcol; // background color
}
```

| Proposed Output  | Solution  | 
| :------------ |:---------------:|
|<img width="261" alt="Screen Shot 2024-04-21 at 7 49 48 PM" src="https://github.com/halaway/asm-display/assets/31904474/3bcfeb94-554f-4a52-88cb-b4ed2230154d"> | <img width="261" alt="Screen Shot 2024-04-21 at 8 29 26 PM" src="https://github.com/halaway/asm-display/assets/31904474/a04d6f67-b0ea-44fa-b4b1-0b067e70c419">|



### Implementation
While a considerably trivial program, a requirement is to not make use of custom built-in function calls, multiplication, or division operators. Regardless, the approach was to traverse the display using the frame buffer in row-major form while calculating starting corner positions using the geometric properties of each shape when considered as a separate unit.
```asm
#   t3 - y coordinate of top left cap corner
#   t5 - base and height of trapezoid with 45-degree angles
mathPortion:	  
	addi 	$t5, $t6, -48		# $t5 ← w - 48
	srl 	$t5, $t5, 1		# $t5 ← w - 48 / 2
	add 	$t3, $t7, $t8 		# $t3 ← h + l
	add 	$t3, $t3, $t5		# $t3 ← h + l + b
  ...
```

## Note
The program is relatively straightforward and was meant to simulate low-level programming while directly accessing and manipulating registers using the available instruction set. I genuinely hope this helps future CS students and clarifies some nuances when applying classroom theory to possible real-world examples.   

