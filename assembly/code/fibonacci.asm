main:
	addui r1,r0,#28
	jal fibonacci
	addu r1,r2,r0

	end:
	j end

; compute the r1-th Fibonacci number (returning it to r2)
fibonacci:
	addi r2,r0,#0	; set res to 0
	sgti r3,r1,#0
	beqz r3,fib_ret	; return 0 if r1 = 0
	addi r2,r0,#1	; set res to 1
	sgti r3,r1,#1
	beqz r3,fib_ret	; return 1 if r1 = 1

	addi r3,r0,#0		; initialize addend
	addi r2,r0,#1		; initialize result
	subui r5,r1,#1		; initialize counter
	fib_loop:
		addu r4,r2,r0	; backup r2
		addu r2,r2,r3	; compute new Fibonacci number
		addu r3,r4,r0	; restore r2 (previous Fibonacci number)
		subui r5,r5,#1	; update counter
		bnez r5,fib_loop

	fib_ret:
	jr r31

