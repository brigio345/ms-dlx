addi r1,r0,#3	; put a random value in r1
label:
subi r1,r1,#1	; decrement r1
sw 4(r0),r1	; store the random value
lw r2,4(r0)	; load the random value to be forwarded
bnez r2,label	; generate the hazard: r2 from LOADED currently in EX stage
xor r3,r1,r2	; random instruction
