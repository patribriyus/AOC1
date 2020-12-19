		AREA datos, DATA, READWRITE	
T DCD 4,8,5,9,1,6,2,7,3,0
N EQU 10
stotal DCD 0
pila SPACE 2048
	
		AREA codigo, CODE, READONLY
		ENTRY
	LDR sp,=pila
	add sp,sp,#2048	; pila full-descending
	LDR r1,=T
	mov r0,#N-1
	sub sp,sp,#4	; empiezo a crear la pila
	PUSH{r0,r1}		; apilamos los parámetros, primero el indice (+8) y luego el vector (+12)
	bl suma
	add sp,sp,#8
	pop{r0}
	LDR r1,=stotal
	str r0,[r1]

fin	b fin

suma
	PUSH{fp,lr}		; empieza apilando el estado
	mov fp,sp		; guarda el puntero de referencia dentro del bloque de activación
	PUSH{r0-r3}			; almaceno todo el estado para poder luego recuperar los valores de los registros
	ldr r0,[fp,#8]	; r0 guarda el valor del indice
	cmp r0,#0
	bne else
	ldr r1,[fp,#12]		; r1 guarda la direccion de T
	ldr r1,[r1]			; T[0]
	str r1,[fp,#16]		; stotal = r1
	pop{r0-r3}
	pop{fp,pc}
; punto de salida de la subrutina

else
	sub r2,r0,#1		; r2 = i--
	ldr r3,[fp,#12]		; cargo en r3 la direccion del vector
	sub sp,sp,#4		; creo la invocación
	push{r2,r3}
	bl suma
	add sp,sp,#8		; ignoro los datos anteriores (indice, vector..)
	pop{r2}
	ldr r3,[r3,r0,LSL#2]	; T[i]
	add r3,r3,r2		; T[i] = T[i]+T[i-1]
	str r3,[fp,#16]		; y lo guardamos en memoria
	pop{r0-r3}
	pop{fp,pc}
	END