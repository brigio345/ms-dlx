main:
	addi r1,r0,#4
	addi r2,r0,#3
	jal power
	add r1,r3,r0	; r1 = 4 ^ 3 = 64
	end:
	j end

; r3 = r1 ^ r2
power:
	add r3,r1,r0	; initialize result
	subi r4,r2,#1	; initialize counter
	mul_loop:
		mult r3,r3,r1
		subi r4,r4,#1	; update counter
		bnez r4,mul_loop
	jr r31

