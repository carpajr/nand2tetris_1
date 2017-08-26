// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// Put your code here.

// Reset Result
  @R2
  M=0

// Loading RAM[0]
  @R0
  D=M

// IF RAM[0] = 0
  @END 
  D;JEQ

// Loading RAM[1]
  @R1
  D=M

// IF RAM[1] = 0
  @END
  D,JEQ


// Compare if RAM[1] - 1 != 0, Do RAM[0] = RAM[0] + RAM[0]; RAM[1] = RAM[1] - 1
(MULTIPLY)
  @R0
  D=M

  @R2
  D=D+M
  M=D

  @R1
  D=M-1
  M=D

  @END
  D,JEQ

  @MULTIPLY
  0,JMP   

(END)
  @END
  0,JMP


