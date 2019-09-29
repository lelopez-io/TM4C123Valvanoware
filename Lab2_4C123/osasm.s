;/*****************************************************************************/
; OSasm.s: low-level OS commands, written in assembly                       */
; Runs on LM4F120/TM4C123/MSP432
; Lab 2 starter file
; February 10, 2016
;


        AREA |.text|, CODE, READONLY, ALIGN=2
        THUMB
        REQUIRE8
        PRESERVE8

        EXTERN  RunPt            ; currently running thread
        EXPORT  StartOS
        EXPORT  SysTick_Handler
        IMPORT  Scheduler	; This tells that Scheduler is written in C and to import that name


SysTick_Handler                ; 1) Saves R0-R3,R12,LR,PC,PSR as part of ISR
    CPSID   I                  ; 2) Prevent interrupt during switch
	PUSH {R4-R11}			   ; Only R4-R11 are left to be pushed
    LDR R0,=RunPt			   ; Obtain the address of current RunPt
	LDR R1,[R0]				   ; Get the value of RunPt
	STR SP,[R1]				   ; Update the value of SP for the current thread
	;ADD R1,#4				   ; Add 4 bytes to the address to obtain the value of next
	;To write scheduler in C we will call Scheduler from here
	;LDR R1,[R1,#4]			   ; Obtain the address of new thread's stack / Value stored in RunPt
	;STR R1,[R0]			   ; Update the RunPt to point to next
	PUSH {R0, LR}			   ; Preserve RunPt value and LX value
	BL Scheduler			   ; Invoke the Scheduler sub-routine
	POP {R0, LR}			   ; Pop it back for use after the call
	LDR R1,[R0]				   ; Get the value of RunPt
	LDR SP,[R1]				   ; Update the new stack pointer
	POP {R4-R11}			   ; Pop only R4-R11. Rest will be automatically popped on return from ISR
	;MOV LX,#FFFFFFF9		   ; This number would be the current value of the LR
	CPSIE   I                  ; 9) tasks run with interrupts enabled
    BX      LR                 ; 10) restore R0-R3,R12,LR,PC,PSR

StartOS
	;Get the context of first thread on to the processor
	LDR R0, =RunPt
	LDR R1, [R0]			   ; Get the contents of the Run pointer in R1
    LDR SP, [R1]			   ; Stack pointer is updated for the thread
	POP {R4-R11}			   ; Pop R4-R11
	POP {R0-R3}				   ; Pop R0-R3
	POP {R12}				   ; Pop R12
	ADD SP,#4				   ; LR on the stack is not of use for the first thread so discard it
	POP {LR}				   ; PC of the stack will stored in LR as after the subroutine this will become the PC
	ADD SP,#4				   ; Discard the PSR as it is not correct
	CPSIE   I                  ; Enable interrupts at processor level
    BX      LR                 ; start first thread

    ALIGN
    END
