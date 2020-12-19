		AREA datos, DATA, READWRITE
N EQU 5			; numero filas
M EQU 7			; numero columnas
matriz DCB 'n','k','o','n','g','v','f','k','o','b','c','f','e','q','p','b','j','u','f','c','x','x','f','r','e','w','o','m','n','k','g','y','t','v','d'	; los datos estan guardados por filas

		AREA codigo, CODE, READONLY
		ENTRY
		
		ldr r0,=matriz
		mov r6,#M
		mov r1,#0		; contador x=1 (columnas)
		mov r2,#1		; contador i=1
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
		
		mla r4,r6,r3,r1			; guarda en r4 la posicion de matriz[j][x] (nºcolumnas*j+x)
		sub r10,r3,#1			; j-1
		mla r5,r6,r10,r1		; guarda en r5 la posicion de matriz[j-1][x] (nºcolumnas*[j-1]+x)
		
		ldrb r7,[r0,r5]			; valor de matriz[j-1][x]
		ldrb r8,[r0,r4]			; valor de matriz[j][x]
		
		cmp r7,r8 
		movgt r9,r8
		strhib r9,[r0,r5]
		strhib r7,[r0,r4]
		
		sub r3,r3,#1
		b ftres
				
fin		b fin
		END