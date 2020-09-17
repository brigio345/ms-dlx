main:
	addi r1,r0,#8
	jal factorial
	add r1,r0,r3
	wait:
	j wait

; compute factorial of r1 value (returning it through r3)
factorial:
	addi r3,r0,#1	; initialize result to 1
	beqz r1,return	; return 1 if r1 = 0
	add r2,r1,r0	; backup r1 (r2 is used as multiplicand and counter)
	mult_loop:
		mult r3,r3,r2
		subi r2,r2,#1	; update counter
		seqi r4,r2,#1
		beqz r4,mult_loop	; loop until r4 is greater than 1
	return:
	jr r31

