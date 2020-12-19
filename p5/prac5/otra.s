		AREA datos,DATA
; variables y constantes
VICIntEnable 	EQU 0xFFFFF010
VICIntEnClr  	EQU 0xFFFFF014
VICSoftInt   	EQU 0xFFFFF018
VICSoftIntClear EQU 0xFFFFF01C
VICVectAddr0    EQU 0xFFFFF100
VICVectAddr		EQU 0xFFFFF030

TEC_DAT			EQU 0xE0010000

IOSET   		EQU 0xE0028004
IOCLR 			EQU 0XE002800C

tecl_so			DCD 0
reloj_so 		DCD 0

T0_IR			EQU 0xE0004000
IRQ_I4 			EQU 4
IRQ_I7			EQU 7

reloj 			DCD 0 				; contador de centesimas de segundo 
max 			DCD 8 				; velocidad de mov. caracter + (en centesimas s.) 
cont 			DCD 0 				; instante siguiente movimiento caracter +
dirx 			DCB 0 				; direccion mov. caracter + (alumno (-1 izda,1 der.) 
diry 			DCB 0 				; direccion mov. caracter * (bala) (1 abajo) 
fin				DCB 0
sem     		EQU 3
	
marcador		DCD 0x40007E00
Mpuntos			DCD 0x40007E04
pantup   		DCD 0x40007E20 		; marcamos limites de pantalla
pantdown 		DCD 0x40008000
finDer		 	DCD 0x40008000
finIzq 			DCD 0x40007E1F

espblanco 		EQU 32 				; espacio en blanco
arroba  		EQU 64				; arroba @. Ascii @ = 64
puntos 			EQU 46 				; puntos para saciar su gula.
contador		DCD 0			
puntosTotales	DCD 478				; 16*32-2-32 puntos que se tiene que comer para acabar el programa
contMuertes		DCB 51	
asterisco 		EQU 42				; Para los 4 asteriscos. Ascii = 42
posArroba 		DCD 0x40007F0F 		; Posicion inicial de la arroba.
posAsterisco1 	DCD 0x40007E20
posAsterisco2 	DCD 0x40007E50
posAsterisco3 	DCD 0x40007F65
posAsterisco4 	DCD 0x40007FFE
quehabia1 		DCB 46				; un punto predeterminado
quehabia2 		DCB 46				; un punto predeterminado
quehabia3 		DCB 46				; un punto predeterminado
quehabia4		DCB 46				; un punto predeterminado

		AREA codigo,CODE
		EXPORT inicio 				; forma de enlazar con el startup.s
		IMPORT srand 				; para poder invocar SBR srand
		IMPORT rand 				; para poder invocar SBR srand
			
inicio 								; se recomienda poner punto de parada (breakpoint) en la primera instruccion
	ldr r0,=VICVectAddr0   			; inicializar rutina de interrupcion del timer
	
	ldr r1,=RSI_timer
	mov r2,#IRQ_I4
	str r1,[r0,r2,LSL#2]			; programa @IRQ4 -> RSI_timer (modifica el VIC de la IRQ)
	
	ldr r1,=RSI_teclado
	mov r2,#IRQ_I7
	str r1,[r0,r2,LSL#2]			; programa @IRQ7 -> RSI_teclado (modifica el VIC de la IRQ)
	
	ldr r0,=VICIntEnable			; carga el registro que activa interrupciones
	ldr r1,[r0]
	orr r1,r1,#1<<IRQ_I4			; activa IRQ4
	orr r1,r1,#1<<IRQ_I7			; activa IRQ7
	str r1,[r0]						; guarda el registro máscara de interrupciones modificado

 	ldr r0,=cont
	mov r1,#0
	strb r1,[r0]  					;iniciamos el contador
		
 	; Crea la semilla para numeros aleatorios
    mov r0,#sem
	push {r0}
    bl srand
    pop {r0}
	
	;inicio pantalla
	ldr r6,marcador
	ldr r4,pantup
	ldr r5,pantdown  				; marcamos los limites de la pantalla
	mov r0,#espblanco 				; guardamos en r0 el espaco en blanco
	mov r1,r6						; copiamos r4 en r1 para no machacar la direccion de inicio de la pantalla

marca
	strb r0,[r1],#1					; pantalla en blanco
	cmp r1,r4	  
	bne marca	   					; de momento usamos los registros r4-> inicio de pantalla y r5-> fin de pantalla
	
	ldr r0,=contMuertes
	ldr r1,[r0]
	strb r1,[r6]
	mov r0,#puntos  				; guardamos en r0 el espaco en blanco
	mov r1,r4	   					; copiamos r4 en r1 para no machacar la direccion de inicio de la pantalla

borrar	
	strb r0,[r1],#1					; pantalla en blanco
	cmp r1,r5	  
	bne borrar	   					; de momento usamos los registros r4-> inicio de pantalla y r5-> fin de pantalla
	
	; preparacion de los elementos en la pantalla de juego
	
	ldr r3,Mpuntos
	mov r2,#48
	strb r2,[r3]
	strb r2,[r3,#1]
	strb r2,[r3,#2]
	
	ldr r3,posArroba 				; guardamos en r3 la direccion de la arroba
	mov r2,#arroba
	strb r2,[r3]					; posicion de la arroba

	ldr r3,posAsterisco1
	mov r2,#asterisco
	strb r2,[r3]					; posicion del asterisco
	
	ldr r3,posAsterisco2
	mov r2,#asterisco
	strb r2,[r3]					; posicion del asterisco
	
	ldr r3,posAsterisco3
	mov r2,#asterisco
	strb r2,[r3]					; posicion del asterisco
	
	ldr r3,posAsterisco4
	mov r2,#asterisco
	strb r2,[r3]					; posicion del asterisco

bucle
	ldr r0,=fin
	ldrb r0,[r0]
	cmp r0,#0
	bne final

	ldr r1,=cont
	ldr r1,[r1]
	ldr r2,=max
	ldr r2,[r2]
	cmp r1,r2
	bne bucle

	mov r9,#1
queasterisco
	cmp r9,#2
	ldreq r8,=posAsterisco2
	ldreq r0,=quehabia2
	ldrlt r8,=posAsterisco1
	ldrlt r0,=quehabia1
	cmp r9,#3
	ldreq r8,=posAsterisco3
	ldreq r0,=quehabia3
	cmp r9,#4
	ldreq r8,=posAsterisco4
	ldreq r0,=quehabia4
	bgt astAcabados

	; PREPARACION MOVIMIENTOS ASTERISCOS
	sub sp,sp,#4
	bl haciadonde
	pop{r1}

	ldr r3,[r8]
	
	ldrb r2,[r0]					; guardo en r2 el caracter que hay en la variable "quehabia"
	cmp r2,#puntos
	strbeq r2,[r3],r1				; sustituyo el asterisco por el caracter de "quehabia"
	cmp r2,#espblanco
	strbeq r2,[r3],r1
	
	; calculamos la direccion a la que va a ir
	ldr r2,finDer
	ldr r1,finIzq
	sub sp,sp,#4
	PUSH{r2,r1,r3}					; le pasamos finDer,finIzq,direccion en este orden
	bl areajuego
	add sp,sp,#12
	pop{r3}

	ldrb r2,[r3]					; guardo en r2 el caracter que hay en la direccion a la que se va a mover el asterisco
	strb r2,[r0]					; y guardo el caracter nuevo en la variable quehabia

	mov r0,#asterisco
	strb r0,[r3]
	str r3,[r8] 					; actualiza la posicion del asterisco
	
	add r9,#1
	b queasterisco
	
astAcabados	 	
	mov r0,#0
	ldr r1,=cont
	str r0,[r1]
	
	ldr r1,=reloj
	str r0,[r1]
	
	ldr r7,=dirx
	ldrsb r7,[r7]
	
	ldr r8,=posArroba
	ldr r3,[r8]						; guardamos en r3 la posicion del alumno
	mov r0,#espblanco
	strb r0,[r3],r7					; r3 adquiere la nueva posicion del alumno
	
	ldr r1,=posAsterisco1
	
	mov r9,#1
estamuerto
	cmp r9,#2
	ldreq r1,=posAsterisco2
	ldrlt r1,=posAsterisco1
	cmp r9,#3
	ldreq r1,=posAsterisco3
	cmp r9,#4
	ldreq r1,=posAsterisco4
	bgt muerteAcabada
	; empieza
	ldr r1,[r1]
	cmp r1,r3						; comparamos las direcciones de arroba y el asterisco para ver si se han chocado
	bne nomuerto
	
	ldr r0,=contMuertes
	ldrb r1,[r0]
	sub r1,r1,#1
	strb r1,[r0]
	ldr r2,marcador
	strb r1,[r2]
	cmp r1,#48
	ldreq r1,=fin
	moveq r0,#1
	strbeq r0,[r1]
	
	mov r0,#espblanco  				; guardamos en r0 el espaco en blanco
borrarp	
	strb r0,[r1],#1					; pantalla en blanco
	cmp r1,r5	  
	bne borrarp	   					; de momento usamos los registros r4-> inicio de pantalla y r5-> fin de pantalla
gameover	
	mov r0,#1
	
nomuerto
	add r9,#1
	b estamuerto

muerteAcabada
	ldr r0,finDer
	ldr r1,finIzq
	sub sp,sp,#4
	PUSH{r0,r1,r3}					; le pasamos finDer,finIzq,direccion en este orden
	bl areajuego
	add sp,sp,#12
	pop{r3}
	
	; el siguiente codigo es para que cuando el arroba se haya comido todos los puntos el juego termine
	cmp r7,#0
	beq nada
	ldrb r0,[r3]						; guardamos en r0 el caracter que hay en la direccion a la que se dirige "@"
	cmp r0,#espblanco
	beq nada
	
	; MARCADOR DE PUNTOS
	; obtenemos el valor en ascii de centenas, decenas y unidades
	ldr r4,Mpuntos
	ldrb r0,[r4]		; centenas
	ldrb r1,[r4,#1]		; decenas
	ldrb r2,[r4,#2]		; unidades
	
	add r2,#1
	cmp r2,#57
	movgt r2,#48
	addgt r1,#1
	cmp r1,#57
	movgt r1,#48
	addgt r0,#1

	strb r0,[r4]
	strb r1,[r4,#1]
	strb r2,[r4,#2]
	
	ldr r0,=contador
	ldr r1,[r0]						; guardamos el valor de contador en r1
	ldr r4,puntosTotales
	cmp r1,r4
	addne r1,#1
	strne r1,[r0]
	
	cmp r1,r4
	ldreq r0,=fin
	moveq r1,#1
	strbeq r1,[r0]

nada	
	mov r0,#arroba
	strb r0,[r3]
	str r3,[r8]
	
	ldr r7,=dirx					; poner al final
	mov r0,#0
	strb r0,[r7]                  	; volvemos a inicializar el eje de x a 0

	b bucle
  
final  
	; desactivar IRQ4,IRQ7
	ldr r0,=VICIntEnClr
	ldr r1,[r0]
	orr r1,r1,#1<<IRQ_I4
	orr r1,r1,#1<<IRQ_I7
	str r1,[r0]
	
bfin b bfin

haciadonde
	PUSH{fp,lr}
	mov fp,sp
	PUSH{r0,r1}
	sub sp,sp,#4
	bl rand 		  				; si el primer bit es uno, ira a la derecha, sino a la izquierda
	pop{r0}
	and r0,r0,#2_10000000
	
	sub sp,sp,#4
	bl rand 		  				; si el primer bit es uno, ira a la derecha, sino a la izquierda
	pop{r1}
	and r1,r1,#2_10000000
	
	cmp r0,#0
	bne ejex
	; si es igual se movera en el eje y
	cmp r1,#0
	moveq r1,#-32					; se movera hacia arriba
	movne r1,#32					; se movera hacia abajo
	
	b sehamovido
	
	; si es distinto se movera en el eje x
ejex
	cmp r1,#0
	moveq r1,#-1					; se movera hacia la izquierda
	movne r1,#1						; se movera hacia la derecha

sehamovido
	str r1,[fp,#8]
	pop{r0,r1}
	pop{fp,pc}
	; ACABA LA SUBRUTINA

areajuego	; SUBRUTINA
	PUSH{fp,lr}
	mov fp,sp
	PUSH{r2,r3,r4}
	ldr r3,[fp,#16]					; r3 guarda el valor de la direccion a la que se va a dirigir
	mov r4,r3
	
	ldr r2,[fp,#8]					; r2 guarda el valor de finDer
	cmp r2,r4						; compara si ha llegado al final de la derecha
	subeq r3,#32
	movlt r2,#15
	sublt r3,r3,r2,LSL#5
	
	ldr r2,[fp,#12]					; r2 guarda el valor de finIzq
	cmp r2,r4						; compara si ha llegado al final de la derecha
	addeq r3,#32
	movgt r2,#15
	addgt r3,r3,r2,LSL#5
	
	str r3,[fp,#20]
	pop{r2,r3,r4}
	pop{fp,pc}
	; ACABA LA SUBRUTINA

movimiento   
	cmp r0,#65							; r0 -?-> A
	ldreq r0,=dirx
    moveq r1,#-1
    strbeq r1,[r0]						; se mueve a la izquierda
	beq fintec
	
	cmp r0,#68							; r0 -?-> D
	ldreq r0,=dirx
    moveq r1, #1
    strbeq r1,[r0]						; se mueve a la derecha
    beq fintec
	
	cmp r0,#83							; r0 -?-> S
	ldreq r0,=dirx
    moveq r1,#32
    strbeq r1,[r0]						; se mueve hacia abajo
    beq fintec
	
	cmp r0,#87							; r0 -?-> W
	ldreq r0,=dirx
    moveq r1,#-32
    strbeq r1,[r0]						; se mueve hacia arriba
    beq fintec
	
	cmp r0,#11							; r0 -?-> +
	beq sumarmax						; aumenta la velocidad
	
	cmp r0,#13							; r0 -?-> -
	beq restarmax						; reduce la velocidad
	
	b fintec

sumarmax 
	ldr r0,=max
	ldr r1,[r0]
	sub r1,#1
	cmp r1,#0
	addeq r1,#1
	str r1,[r0]
	b fintec

restarmax 
	ldr r0,=max
	ldr r1,[r0]
	add r1,#1
	cmp r1,#256
	subeq r1,#1
	str r1,[r0]
	b fintec
	
RSI_timer
	sub lr, lr, #4
	push{lr} 							; Activo IRQs
	mrs r14, spsr
	push{r14}
	push {r0-r1} 						; apila registros a utilizar
	msr cpsr_c,#2_01010010				; habilita IRQ de la palabra de estado
	
	ldr r0,=cont
	ldr r1,[r0]
	add r1,#1
	str r1,[r0]

	; desactiva del VIC la peticion
	LDR r0,=T0_IR ;
	mov r1,#1 
	str r1,[r0]
	
	ldr r0,=reloj
	ldr r1,[r0]
	add r1, r1, #1
	str r1, [r0]

	;desactiva IRQ
	msr cpsr_c,#2_11010010
	POP{r0-r1}
	POP{r14}
	msr spsr_fsxc,r14
	LDR r14,=VICVectAddr
	str r14,[r14]
	POP {pc}^

RSI_teclado 
	sub lr,lr,#4					
	push{lr}						
	mrs r14,spsr						; activo IRQs
	push{r14}						
	msr cpsr_c,#2_01010010
	PUSH{r0-r2}
		
	LDR r1,=TEC_DAT
	ldrb r0,[r1]						; r0=codigo ASCII tecla
		
	bic r0,r0,#2_100000				 	; transformo la tecla a mayuscula
	cmp r0,#81						 	; comparo con la letra 'Q' (finaliza el programa)
	bne movimiento
	
	ldr r1,=fin
	mov r0,#1
	strb r0,[r1]
	
fintec  
	POP{r0-r2}
	msr cpsr_c,#2_11010010
	POP{r14}
	msr spsr_fsxc,r14
	LDR r14,=VICVectAddr
	str r14,[r14]
	POP{PC}^

	END