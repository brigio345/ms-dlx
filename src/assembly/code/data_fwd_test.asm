start:
addi r1,r0,#185
addi r2,r0,#1234
add r3,r1,r2	; forward r1 from ALUOUT (MEM) to ID and r2 from ALUOUT (EX) to EX
add r4,r1,r2	; forward r1 from ALUOUT (WB) to ID and r2 from ALUOUT (MEM) to ID
addi r5,r1,#56	; read r1 from RF
sw 16(r0),r2	; read r2 from RF
lw r6,16(r0) 
xor r7,r6,r2	; stall (cannot forward from LOADED(EX)) + forward from LOADED(MEM)
xor r8,r6,r0	; forward r6 from LOADED(WB)
xor r9,r6,r1	; read r6 from RF
bnez r9,start	; forward r9 from ALUOUT(EX) to ID
end:
j end
