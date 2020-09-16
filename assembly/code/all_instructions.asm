	; set random values
	addi r1,r0,#257
	addi r2,r0,#672
	addi r3,r0,#-5524
	addi r5,r0,#2

	; R-type instructions
	sll r4,r1,r5
	srl r4,r1,r5
	sra r4,r4,r5
	add r4,r1,r3
	addu r4,r1,r2
	sub r4,r1,r2
	subu r4,r2,r1
	mult r4,r1,r2
	and r4,r1,r2
	or r4,r1,r2
	xor r4,r1,r1
	seq r4,r1,r2
	seq r4,r1,r1
	sne r4,r1,r2
	sne r4,r1,r1
	slt r4,r1,r3
	slt r4,r3,r1
	sgt r4,r1,r3
	sgt r4,r3,r1
	sle r4,r1,r3
	sle r4,r3,r1
	sge r4,r1,r3
	sge r4,r3,r1
	sltu r4,r1,r2
	sltu r4,r2,r1
	sgtu r4,r1,r2
	sgtu r4,r2,r1
	sleu r4,r1,r2
	sleu r4,r1,r1
	sgeu r4,r1,r2
	sgeu r4,r1,r1

	; I-type instructions
	addi r4,r3,#15
	addui r4,r2,#26
	subi r4,r1,#234
	subui r4,r2,#99
	andi r4,r3,#666
	ori r4,r1,#315
	xori r4,r2,#22
	slli r4,r1,#3
	srli r4,r1,#2
	srai r4,r3,#2
	seqi r4,r1,#257
	seqi r4,r1,#256
	snei r4,r1,#257
	snei r4,r1,#256
	slti r4,r1,#257
	slti r4,r1,#256
	sgti r4,r1,#258
	sgti r4,r1,#257
	sgti r4,r1,#256
	slei r4,r1,#258
	slei r4,r1,#257
	slei r4,r1,#256
	sgei r4,r1,#258
	sgei r4,r1,#257
	sgei r4,r1,#256
	sltui r4,r3,#-5523
	sltui r4,r3,#-5524
	sgtui r4,r3,#-5525
	sgtui r4,r3,#-5523
	sgtui r4,r3,#-5524
	sleui r4,r3,#-5525
	sleui r4,r3,#-5523
	sleui r4,r3,#-5524
	sgeui r4,r3,#-5525
	sgeui r4,r3,#-5523
	sgeui r4,r3,#-5524
	sb 0(r0),r1
	sh 2(r0),r2
	sw 4(r0),r3
	lw r4,4(r0)
	lh r4,2(r0)
	lb r4,0(r0)
	lbu r4,2(r0)
	lhu r4,4(r0)
	nop
	beqz r1,end
	bnez r0,end

	; J-type instructions
	j target0
	target0:
	jal target1
	target1:
	addi r4,r0,target2
	jr r4
	target2:
	addi r4,r0,end
	jalr r4

	end:
	j end

