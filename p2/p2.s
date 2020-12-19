	AREA datos,DATA,READWRITE

ini		SPACE 1024*2+512	; reserva espacio
long	EQU 1024*2
ampl	EQU 512
	
	AREA codigo,CODE,READONLY
	;ENTRY
	
	ldr r0,=ini				; guarda el comienzo de la direccion @ini en r0
	mov r1,#0				; r1 = 0 (contador)
	add r2, r0, #long		; r2 guarda el final de la direccion de @ini (r0)
	
buc	strh r1,[r0],#2			; en la direccion @r0 de memoria se guarda el contenido de r1
	add r1,#1				; contador++
	cmp r2,r0				; compara si @r0 ha llegado a su fin (@r2)
	bne buc					; si todavía no ha acabado vuelve a la etiqueta "buc"
	
	; ya tiene la lista de numeros del 0 al 1023

	; pasa los 256 primeros numeros al espacio extra
							
	ldr r3,=ini				; guarda el comienzo de la direccion @ini en r1
	add r4,r0,#ampl			; r4 guarda el final de la direccion del espacio extra

any	ldrh r1,[r3],#2			; guarda en r1 el contenido de la direccion @r3
	strh r1,[r0],#2			; guarda en la direccion de memoria @r0 el valor de r1
	cmp r0,r4				; compara si @r0 ha llegado a su fin (@r4)
	bne any					; si todavía no ha acabado vuelve a la etiqueta "pri"
	
	; mueve los bloques de derecha a izquierda dejando ceros en los bloques de la derecha
							
	ldr r0,=ini				; guarda el comienzo de la direccion @ini en r0
	add r2,r0,#ampl			; r2 guarda la direccion del inicio de @ini mas el espacio extra (@ini[512])
	mov r1,#0				; r1 = 0

cop	ldrh r3,[r2]			; guarda en r3 el contenido de la direccion de @r2
	strh r1,[r2],#2			; guarda en la direccion de memoria @r2 un cero
	strh r3,[r0],#2			; guarda en la direccion de memoria @r0 el valor de r3
	cmp r4,r2				; compara si @r4 ha llegado a su fin (@r2)
	bne cop					; si todavía no ha acabado vuelve a la etiqueta "seg"
	
	; el programa ha acabado

fin	b fin					; bucle infinito en la etiqueta "fin"
	END