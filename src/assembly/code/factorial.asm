main:
	addi r1,r0,#8
	jal factorial
	add r1,r0,r3
	wait:
	j wait

factorial:
	addi r3,r0,#1
	beqz r1,return
	add r2,r1,r0
	mult_loop:
		mult r3,r3,r2
		subi r2,r2,#1
		seqi r4,r2,#1
		beqz r4,mult_loop
	return:
	jr r31

