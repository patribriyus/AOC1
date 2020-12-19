		AREA codigo, CODE
		EXPORT ordena

ordena
	PUSH{fp,lr}		; empieza apilando el estado
	mov fp,sp		; guarda el puntero de referencia dentro del bloque de activación
	
	sub r1,#1
	add r1,r0,r1,LSL#2
	
	PUSH{r0}
	PUSH{r1}
	bl qksort
	add sp,sp,#8
	pop{fp,pc}
	
; SUBRUTINA RECURSIVA

qksort
	PUSH{fp,lr}		; empieza apilando el estado
	mov fp,sp		; guarda el puntero de referencia dentro del bloque de activación
	PUSH{r0-r7}			; almaceno todo el estado para poder luego recuperar los valores de los registros
	ldr r0,[fp,#12]	; @iz
	ldr r1,[fp,#8]	; @de

	sub r2,r1,r0	; diferencia entre las direcciones en bytes
	LSR r2,#3		; diferencia en numero normal (/4) y distancia entre izq y el valor medio (/2)
	add r2,r0,r2,LSL#2	; @(iz+de)/2	
	ldr r3,[r2]		; valor de X
	
	mov r6,r0		; indice i
	mov r7,r1		; indice j
	
w1	
	ldr r4,[r6]				; guardo en r4 el valor de T[i]
	cmp r4,r3				; si T[i]<x
	addlt r6,#4				; i++
	blt w1					; vuelve a hacerse el bucle
	
w2	
	ldr r5,[r7]				; guardo en r5 el valor de T[j]
	cmp r3,r5				; si x<T[j]
	sublt r7,#4				; j--
	blt w2					; vuelve a hacerse el bucle
	
	cmp r6,r7				; si i<=j
	strle r4,[r7]			; T[j]=T[i]
	strle r5,[r6]			; T[i]=T[j]
	addle r6,#4				; i++
	suble r7,#4				; j--
	
	cmp r6,r7				; si i<=j
	ble w1
	
if1	cmp r0,r7				; iz<j
	bge if2
	PUSH{r0}
	PUSH{r7}
	bl qksort
	add sp,sp,#8
	
if2	
	cmp	r6,r1				; i<de
	bge f
	PUSH{r6}
	PUSH{r1}
	bl qksort
	add sp,sp,#8
	
f	pop{r0-r7}
	pop{fp,pc}
	
	END