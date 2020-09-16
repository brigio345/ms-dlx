main:
	addi r1,r0,#1
	jal push	; push 1
	addi r1,r0,#2
	jal push	; push 2
	addi r1,r0,#3
	jal push	; push 3
	jal pop		; pop 3
	jal pop		; pop 2
	addi r1,r0,#4
	jal push	; push 4
	jal pop		; pop 4
	jal pop		; pop 1
	jal pop		; pop empty -> 0

	end:
	j end

; push r1 to the stack if it's not full (100 elements)
; (stack pointer is r30)
push:
	sgei r4,r30,#400	; check if stack is not full
	bnez r4,push_ret	; if stack is full return
	sw 0(r30),r1		; store to stack
	addi r30,r30,#4		; update stack pointer
	push_ret:
	jr r31			; return

; pop to r2 from stack if it's not empty (otherwise r2 is set to 0)
; (stack pointer is r30)
pop:
	xor r2,r2,r2	; set r2 to 0
	slti r4,r30,#4	; check if stack is not empty
	bnez r4,pop_ret	; if stack is empty return 0
	subi r30,r30,#4	; update stack pointer
	lw r2,0(r30)	; load from stack
	pop_ret:
	jr r31		; return

