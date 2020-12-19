	AREA datos, DATA, READWRITE
		
ini SPACE 1024*2
lng1 EQU 1024*2
lng2 EQU 512
lng3 EQU 1024*2 - 512
	
	AREA codigo, CODE, READONLY
	;ENTRY
	
	mov r0,#0
	mov r1,#0
	
	ldr r2,=ini
buc	strh r1,[r2,r0]
	add r0,r0,#2
	add r1,r1,#1
	cmp r0,#lng1
	bne buc
	
	mov r0,#0
	ldr r1,=ini
	add r2,r1,#lng2
dsp	ldrh r3,[r1,r0]
	ldrh r4,[r2,r0]
	strh r4,[r1,r0]
	strh r3,[r2,r0]
	add r0,r0,#2
	cmp r0,#lng3
	bne dsp
	
fin	b fin
	END