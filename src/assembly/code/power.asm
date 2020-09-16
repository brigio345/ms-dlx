addi r1,r0,#4
addi r2,r0,#3
jal power
add r1,r3,r0
end:
j end

power:
add r3,r1,r0
subi r4,r2,#1
mul_loop:
	mult r3,r3,r1
	subi r4,r4,#1
	bnez r4,mul_loop
jr r31
