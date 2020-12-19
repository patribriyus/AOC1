		AREA datos,DATA
; variables y constantes
VICIntEnable EQU 0xFFFFF010
VICIntEnClr  EQU 0xFFFFF014
VICSoftInt    EQU 0xFFFFF018
VICSoftIntClear EQU 0xFFFFF01C
VICVectAddr0    EQU 0xFFFFF100
VICVectAddr EQU 0xFFFFF030

TEC_DAT EQU 0xE0010000

IOSET    EQU 0xE0028004
IOCLR EQU 0XE002800C

tecl_so DCD 0
terminar DCD 0
reloj_so DCD 0

T0_IR EQU 0xE0004000

IRQ_I4 EQU 4
IRQ_I7 EQU 7	

reloj DCD 0 						;contador de centesimas de segundo 
max DCD 8 							;velocidad de mov. caracter @ (en centesimas s.) 
cont DCD 0 							;instante siguiente movimiento caracter @
dirx DCB 0 							;direccion mov (-1 izda,0 stop,1 der.) 
diry DCB 0 							;direccion mov (-1 arriba,0 stop,1 abajo)
fin DCB 0 							;indicador fin de programa si vale 1.

quehabia EQU 46						; empieza habiendo un punto

sem     EQU 3
pantup   DCD 0x40007E00 			;marcamos limites de pantalla
pantdown DCD 0x40007FFF
espblanco EQU 32 					;espacio en blanco. Ascii espacio en blanco = 32
arroba  EQU 64						; arroba @. Ascii @ = 64
puntos EQU 46 						; puntos para saciar su gula.
asterisco EQU 42					; Para los 4 asteriscos. Ascii = 42
posArroba DCD 0x40007F0F 			; Posicion inicial de la arroba.
posAsterisco DCD 0x40007E50
;Falta poner el limite del movimiento por cada lado al moverse el arroba.



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
	mov r1, #0
	strb r1,[r0]  					; iniciamos el contador
	
	; Crea la semilla para numeros aleatorios
	mov r0,#sem
	push{r0}
	bl srand
	pop{r0}
	
	;inicio pantalla
	ldr r4,pantup
	ldr r5,pantdown  				; marcamos los limites de la pantalla
	mov r0,#puntos  				; guardamos en r0 el punto
	mov r1,r4     					; copiamos r4 en r1 para no machacar la direccion de inicio de la pantalla

borrar 
	strb r0,[r1],#1 				; pantalla llena de puntos para comer.
	cmp r1,r5   
	bne borrar     					; de momento los unicos registros que usamos son r4 inicio de pantalla y r5 fin de pantalla
	
	ldr r3,=posArroba 				; guardamos en r3 la direccion de arroba
	ldr r3,[r3]						
	mov r2,#arroba
	strb r2,[r3]					; posicion de arroba
	
	
	ldr r3,=posAsterisco
	ldr r3,[r3]
	mov r2,#asterisco
	strb r2,[r3]					; posicion de asterisco
	
bucle
	ldr r0,=fin
	ldr r1,[r0]
	cmp r1,#1
	beq final						; el programa termina (Fin=1)
	
	ldr r0,=TEC_DAT
	ldrb r1,[r0]
	cmp r1,#81 						; comparo con la letra 'Q' (finaliza el programa)
	beq bucle						; se ha pulsado la Q para terminar el programa
	
	ldr r1,=cont
	ldr r1,[r1]
	ldr r2,=max
	ldr r2,[r2]
	cmp r1,r2
	bne finale 						;numero aleatorio
	; ??????????????????????????????????????????????????
	sub sp,sp,#4
	bl rand   						; si primer bit es uno a la derecha sino izquierda
	pop{r0}
	and r0,r0,#2_10000000
	cmp r0,#0
	moveq r1,#-1
	movne r1,#1
	
	ldr r8,=posAsterisco
	ldr r3,[r8]						; direccion del asterisco
	
	ldr r0,=quehabia
	ldrb r2,[r0]					; guardo en r2 el caracter que habia en la variable "quehabia"
	strb r2,[r3],r1					; sustituyo el asterisco por el caracter de "quehabia"
	ldrb r2,[r3]					; guardo en r2 el caracter que hay en la direccion a la que se va a mover el asterisco
	strb r2,[r0]					; y guardo el caracter nuevo en memoria
	
	mov r0,#asterisco
	strb r0,[r3]					; mueve el asterisco a la direccion nueva
	str r3,[r8]						; actualiza la direccion del asterisco
 
	ldr r7,=dirx
	ldrsb r7,[r7]
	mov r0,#0
	ldr r1,=cont
	str r0,[r1]
	ldr r1,=reloj
	str r0,[r1]
	cmp r0,r7 ;ponemos reloj a cero
	;;;;;;;;;;;;;;    
	ldr r8,=posArroba    ;movemos alumno
	ldr r3,[r8] 
	mov r0,#espblanco
	strb r0,[r3],r7
	mov r0,#arroba
	strb r0, [r3]
	str r3,[r8]
	ldr r7,=dirx ;poner al final
	mov r0,#0
	strb r0,[r7]                 

finale
	ldr r0,=fin
	ldrb r0,[r0]
	cmp r0,#0
	beq bucle

final
	; desactivar IRQ4,IRQ7
	ldr r0,=VICIntEnClr
	ldr r1,[r0]
	orr r1,r1,#1<<IRQ_I4
	orr r1,r1,#1<<IRQ_I7
	str r1,[r0]
	
bfin b bfin

sigue
	cmp r0,#65
	beq izq
	cmp r0,#68
	beq der
	cmp r0,#87
	beq arriba
	cmp r0,#83
	beq abajo
	cmp r0,#43
	beq sumarmax
	cmp r0,#45
	beq restarmax
	b fintec
izq
	ldr r0,=dirx
	mov r1,#-1
	strb r1,[r0]
	b fintec

der 
	ldr r0, =dirx
	mov r1, #1
	strb r1, [r0]
	b fintec

arriba 
	ldr r0,=diry
	mov r1,#1
	strb r1,[r0]   
	b fintec
	
abajo 
	ldr r0,=diry
	mov r1,#-1
	strb r1,[r0]   
	b fintec

sumarmax 
	ldr r0,=max
	ldr r1,[r0]
	sub r1,r1,#1
	cmp r1,#0
	addeq r1,r1,#1
	str r1,[r0]
	b fintec

restarmax 
	ldr r0,=max
	ldr r1,[r0]
	add r1,r1,#1
	cmp r1,#256
	subeq r1,r1,#1
	str r1,[r0]
	b fintec
		
RSI_timer
	sub lr, lr, #4
	push{lr} 						; Activo IRQs
	mrs r14, spsr
	push{r14}
	push {r0-r1} 					; apila registros a utilizar
	msr cpsr_c,#2_01010010			; habilita IRQ de la palabra de estado

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
	msr spsr_cxsf,r14
	LDR r14,=VICVectAddr
	str r14,[r14]
	POP {pc}^

RSI_teclado 
	sub lr,#4
	push{lr}
	mrs r14,spsr 					; Activo IRQs
	push{r14}
	PUSH {r0-r2}
	msr cpsr_c,#2_01010010
	
	LDR r0,=TEC_DAT
	ldrb r1,[r0]					; r1=codigo ASCII tecla
	bic r1,r1,#2_100000 			; transformo la tecla a mayuscula
	
	cmp r1,#81 						; comparo con la letra 'Q' (finaliza el programa)
	ldreq r0,=fin
	moveq r1,#1
	streq r1,[r0]
	beq fintec
	
	ldr r2,=TEC_DAT					; guardamos la direccion de la tecla pulsada
	strb r1,[r2]					; guardamos la tecla pulsada en la direccion de tecla
	
	ldr r0,=cont
	mov r1,#0
	str r1,[r0]
	
fintec
	msr cpsr_c,#2_11010010
	POP{r0-r2}
	POP{r14}
	msr spsr_fsxc,r14
	LDR r14,=VICVectAddr
	str r14,[r14]
	POP{PC}^

	END