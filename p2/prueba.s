		AREA datos,DATA,READWRITE
matriz DCB 'n','k','o','n','g','v','f'
       DCB 'k','o','b','c','f','e','q'
       DCB 'p','b','j','u','f','c','x'
       DCB 'x','f','r','e','w','o','m'
       DCB 'n','k','g','y','t','v','d'	; los datos estan guardados por filas
N EQU 5			; numero filas
M EQU 7			; numero columnas

		AREA codigo,CODE,READONLY
		ENTRY
		
		LDR r0,=matriz
		mov r6,#N
		mov r1,#1		; contador x=1 (columnas)
		mov r2,#1		; contador i=1 (filas)
		mov r3,#N-1		; contador j=N-1 (fila por el final)
		
funo	cmp r1,#M
		beq fin
		
		
fdos	cmp r2,#N
		addeq r1,#1
		moveq r2,#1
		beq funo
		
ftres	cmp r3,r2
		addlt r2,#1
		movlt r3,#N-1
		blt fdos
		
		mla r4,r6,r1,r3
		mla r5,r6,r1,r2
		
		ldrb r7,[r0,r4]		; valor de matriz[j-1][x]
		ldrb r8,[r0,r5]		; valor de matriz[j][x]
		
		cmp r7,r8
		movgt r9,r8
		strgtb r7,[r0,r5]
		strgtb r9,[r0,r4]
		
		sub r3,r3,#1
		b ftres
				
fin		b fin
		END