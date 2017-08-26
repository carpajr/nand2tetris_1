// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, the
// program clears the screen, i.e. writes "white" in every pixel.

// Put your code here.

(RESET)
    //@16384 (BASE) - SCREEN SIZE 256 x 512 pixels - 256 = 16*16 - 512 = 16*2 Words (1)
    @SCREEN
    D=A

    @SCRMAP // HANDLE SCREEN RAM MEMORY IN ITERATIONS
    M=D

    @8192   // MAX ALLOCATED RAM TO HANDLE SCREEN = 16*16*16*2 (1)
    D=A
    @SCRMAX
    M=D

(KBDCHECK)
    @KBD
    D=M

    @BLACK
    D;JGT

    @COLOR	// IS COLOR BLACK?
    D=M

    @WHITE // REVERT SCREEN COLOR WHEN IT IS BLACK
    D;JLT

    @KBDCHECK
    0;JMP

(BLACK)
    @COLOR // -1 = (1111 1111 1111 1111)2
    M=-1	
    @FILL
    0;JMP

(WHITE)
    @COLOR // 0 = (0000 0000 0000 0000)2
    M=0	
    @FILL
    0;JMP

(FILL)
    @COLOR	//LOAD COLOR
    D=M	   

    @SCRMAP
    A=M	    //GET THE ADDRESS TO FILL
    M=D	    //FILL WITH THE COLOR

    @SCRMAP
    M=M+1	//NEXT PIXEL

    @SCRMAX
    D=M-1
    M=D

    @FILL
    D;JGT	

    @RESET
    0;JMP

