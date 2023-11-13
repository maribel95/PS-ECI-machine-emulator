*-----------------------------------------------------------
* Title      : PRAFIN20
* Written by : María Isabel Crespí Valero y Juan Mesquida Arenas
* Date       : 20/05/2020
* Description: Emulador de la PS-ECI
*-----------------------------------------------------------
    ORG $1000
EPROG: DC.W $8810,$400A,$E00D,$688E,$9000,$4003,$E00D,$6804
                 DC.W $6FFD,$48A4,$495B,$E00D,$C009,$4020,$A012,$0000
                 DC.W $0004,$0003,$0000
EIR:   DC.W 0 ;eregistro de instruccion
EPC:   DC.W 0 ;econtador de programa
ET0:   DC.W 0 ;eregistro T0
ET1:   DC.W 0 ;eregistro T1
ER2:   DC.W 0 ;eregistro R2
ER3:   DC.W 0 ;eregistro R3
ER4:   DC.W 0 ;eregistro R4
ER5:   DC.W 0 ;eregistro R5
EB6:   DC.W 0 ;eregistro B6
EB7:   DC.W 0 ;eregistro B7
ESR:   DC.W 0 ;eregistro de estado (00000000 00000ZNC)

START:
    CLR.W EPC
    
                   

FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	
	; ESCRIBID VUESTRO CODIGO AQUI
	
	MOVE.W EPC,D0
    MULS.W #2,D0     ; Multiplicamos por 2 debido a que es un vector de Words
    LEA EPROG,A0     ; Cargamos la dirección de memoria de EPROG en A0
    ADD.W D0,A0      ;Siguiente einstrucción = EPROG + 2*EPC
    MOVE.W (A0),D0
    MOVE.W D0,EIR    ; y meteremos la instrucción pertinente en EIR
    ADDQ.W #1,EPC    ; A medida que avancemos en el programa emulado,
                     ; el contador EPC irá aumentando de 1 en 1
                     
                            
        
    ;--- FFETCH: FIN FETCH
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1
        
    
    

	; ESCRIBID VUESTRO CODIGO AQUI
	
	SUBQ.W #2,SP            ; Reservamos un espacio vacío donde meteremos el índice de instrucción
    MOVE.W EIR,-(SP)        ; También reservaremos un espacio para el EIR
    JSR DECOD               ; Salto a la subrutina
    MOVE.W 2(SP),D1         ; Metemos el resultado en el registro D1
    ADDQ.W #4,SP            ; Vaciamos la pila
        
    ;--- FBRDECOD: FIN SALTO A DECOD
    
    
   

    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA
    MULU #6,D1
    MOVEA.L D1,A1
    JMP JMPLIST(A1)
JMPLIST:
    JMP EEXIT
    JMP ECOPY
    JMP EADD
    JMP ESUB
    JMP EAND
    JMP ENOT
    JMP ESTC
    JMP ELOA
    JMP ELOAI
    JMP ESTO
    JMP ESTOI
    JMP EBRI
    JMP EBRC
    JMP EBRZ    
    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecucion de cada einstr.
	
	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
EEXIT:

    MOVE.B #9,D0
    TRAP #15		 ; Acaba el programa
  
ECOPY:

     MOVE.W #5,D2 ;  D4 será el registro que definirá el operando destino
     JSR REGISTRO
     MOVE.W D1,D3   ; Hacemos un MOVE que es lo que nos pide la instrucción
     MOVE.W SR,D4   ; Guardamos los flags del 68K
     JSR ZN         ; Actualizamos los flags ZN
     JSR REGISTRO_DESTINO 
     BRA FETCH
    
EADD:

    MOVE.W #8,D2 ; Vamos a codificar el operando A
    JSR REGISTRO
    MOVE.W D1,D3  ; Guardamos el operando A en D3
    
    MOVE.W #5,D2   ; Vamos a codificar el operando B
    JSR REGISTRO 
    ADD.W D1,D3    ;Sumamos A con B y lo dejamos en C
    MOVE.W SR,D4   ; Guardamos los flags del 68K en D4
    JSR CZN        ; Actualizamos flags CZN
    JSR REGISTRO_DESTINO
    BRA FETCH
    
ESUB:

    MOVE.W #8,D2
    JSR REGISTRO ;A en D1 
    MOVE.W D1,D3
    
    MOVE.W #5,D2
    JSR REGISTRO ;B en D1
    JSR CAMBIO_SIGNO
    ; Ahora ya podemos hacer la resta de ambos números   
    ADD.W D1,D3 ; Hacemos la resta entre A y B
    MOVE.W SR,D4  ; Inmediatamente guardamos los flags
    JSR CZN
    JSR REGISTRO_DESTINO ;RESULTADO EN OPERANDO DESTINO      
    BRA FETCH
    
EAND:
    
    MOVE.W #8,D2
    JSR REGISTRO ;A EN D1
    MOVE.W D1,D3
    
    MOVE.W #5,D2
    JSR REGISTRO ;b EN D1
    AND.W D1,D3
    MOVE.W SR,D4
    JSR ZN
    JSR REGISTRO_DESTINO   
    BRA FETCH
    
ENOT: 

  MOVE.W #2,D2
  JSR REGISTRO ; Codificamos el operando C
  NOT.W D1
  MOVE.W SR,D4
  JSR ZN
  MOVE.W D1,D3        ; Lo estamos metiendo en C
  JSR REGISTRO_DESTINO
  
  BRA FETCH
  
ESTC:
  ;Codificación constante K
  JSR K
  MOVE.W D5,D3  ; Movemos la constante a C
  MOVE.W SR,D4
  JSR ZN
  JSR REGISTRO_DESTINO
  BRA FETCH
  
ELOA:
 JSR M ;TENEMOS VALOR  DE M EN D5
 ADD.W D5,D5 
 MOVE.W D5,A2 
 MOVE.W EPROG(A2),D6 ; Guardamos la M en T
 JSR T_DEST ;LOS FLAGS SE GUARDAN DONDE TOCA
 JSR ZN
 BRA FETCH
    
ELOAI:
  JSR B  OBTENEMOS B1 O B0 EN A1
  MOVE.W EPROG(A1),ET0
  MOVE.W SR,D4
  JSR ZN
  BRA FETCH
  
ESTO:

  JSR M ;TENEMOS VALOR DE M EN D5
  ADD.W D5,D5
  MOVE.W D5,A2
  JSR T ;TENEMOS VALOR DE T EN D6
  MOVE.W D6,A2
  MOVE.W D5,EPROG(A2)
  ;NO SE ACTUALIZAN FLAGS
    BRA FETCH
    
ESTOI:

    JSR B  ;OBTENEMOS B1 O B0 EN A1
    MOVE.W ET0,EPROG(A1)
    BRA FETCH
    
EBRI:

   JSR BRANCH_PC  
   BRA FETCH
    
EBRC:

  BTST.L #0,D7 ;COMPROBAMOS FLAG C
  BEQ FETCH    ;SI ES 1 SE HACE UN JMP
  JSR BRANCH_PC    
  BRA FETCH
  
EBRZ:

  BTST.L #2,D7 ;COMPROBAMOS FLAG Z
  BEQ FETCH    ;SI ES 1 SE HACE UN JMP
  JSR BRANCH_PC  
  BRA FETCH

    ;--- FEXEC: FIN EJECUCION

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

	; ESCRIBID VUESTRO CODIGO AQUI
	
;-------------------------------------------------
;          ACTUALIZACIÓN FLAGS
;-------------------------------------------------
  
CZN:  ;Esta subrutina actualiza el flag C
   BTST.L #0,D4
   BNE C_1  ;FLAG C ES 1
   BEQ C_0
ZN:  ;Esta subrutina actualiza los flags N y Z     
   BTST.L #2,D4
   BNE Z_1 ;FLAG Z ES 1 
   BEQ Z_0
N:
   BTST.L #3,D4
   BNE N_1   ;FLAG N ES 1
   BEQ N_0

C_0:

    BCLR #0,D7
    BRA ZN
 
C_1:

    BSET #0,D7
    BRA ZN

Z_0:

    BCLR #2,D7    
    BRA N
        
Z_1:

    BSET #2,D7
    BRA N
    
N_0:
    BCLR #1,D7
    MOVE.W D7,ESR ; La actualización de los flags acaba en N
    RTS    
    
N_1:

    BSET #1,D7
    MOVE.W D7,ESR 
    RTS
    
    
    
   
;-------------------------------------------------
;    CODIFICACIÓN OPERANDOS FUENTE Y DESTINO
;-------------------------------------------------        
        


REGISTRO:

    CLR.L D1     ; Limpiamos el registro de alguna instrucción previa
    BTST.L D2,D0 ; Comprobamos si hay un 1 o un 0 en la primera c
    BNE BIT_1AA
    BEQ BIT_0AA

BIT_0AA:
 SUBQ.W #1,D2
 BTST.L D2,D0
 BNE BIT_01A
 BEQ BIT_00A
 
BIT_00A:
 SUBQ.W #1,D2
 BTST.L D2,D0
 BNE OPERANDO_ET1
 BEQ OPERANDO_ET0

BIT_01A:
 SUBQ.W #1,D2
 BTST.L D2,D0
 BNE OPERANDO_ER3
 BEQ OPERANDO_ER2
                
BIT_1AA:
 SUBQ.W #1,D2
 BTST.L D2,D0
 BNE BIT_11A
 BEQ BIT_10A

BIT_10A:
 SUBQ.W #1,D2
 BTST.L D2,D0
 BNE OPERANDO_ER5
 BEQ OPERANDO_ER4
        
BIT_11A:
 SUBQ.W #1,D2
 BTST.L D2,D0
 BNE OPERANDO_EB7
 BEQ OPERANDO_EB6

    
; A continuación, se va a guardar el eregistro correspondiente
; en el operando dentro de D4  
    
OPERANDO_ET0:

    MOVE.W ET0,D1
    RTS
OPERANDO_ET1:

    MOVE.W ET1,D1
    RTS

OPERANDO_ER2:

    MOVE.W ER2,D1
    RTS

OPERANDO_ER3:

    MOVE.W ER3,D1
    RTS

OPERANDO_ER4:

    MOVE.W ER4,D1
    RTS

OPERANDO_ER5:

    MOVE.W ER5,D1
    RTS

OPERANDO_EB6:
    MOVE.W EB6,D1
    RTS

OPERANDO_EB7:
    MOVE.W EB7,D1
    RTS
       
    
        
 ; El operando C funcionará siempre como operando destino      
        
REGISTRO_DESTINO:

 BTST.L #2,D0
 BNE BIT_1CC
 BEQ BIT_0CC

BIT_0CC:
 BTST.L #1,D0
 BNE BIT_01C
 BEQ BIT_00C
 
BIT_00C:
 BTST.L #0,D0
 BNE DESTINO_ET1
 BEQ DESTINO_ET0

BIT_01C:
 BTST.L #0,D0
 BNE DESTINO_ER3
 BEQ DESTINO_ER2
                
BIT_1CC:
 BTST.L #1,D0
 BNE BIT_11C
 BEQ BIT_10C

BIT_10C:
 BTST.L #0,D0
 BNE DESTINO_ER5
 BEQ DESTINO_ER4
        
BIT_11C:
 BTST.L #0,D0
 BNE DESTINO_EB7
 BEQ DESTINO_EB6
            
        


    
DESTINO_ET0:

    MOVE.W D3,ET0
    CLR.L D3         
    RTS 
    
DESTINO_ET1:

    MOVE.W D3,ET1
    CLR.L D3         
    RTS 

DESTINO_ER2:

    MOVE.W D3,ER2
    CLR.L D3         
    RTS 

DESTINO_ER3:

    MOVE.W D3,ER3
    CLR.L D3         
    RTS 

DESTINO_ER4:

    MOVE.W D3,ER4
    CLR.L D3         
    RTS 

DESTINO_ER5:

    MOVE.W D3,ER5
    CLR.L D3         
    RTS 

DESTINO_EB6:

    MOVE.W D3,EB6
    CLR.L D3         
    RTS 
    
DESTINO_EB7:

    MOVE.W D3,EB7
    CLR.L D3         
    RTS 
    


;-------------------------------------------------
;              CODIFICACIÓN M
;-------------------------------------------------        
        

M:                  
    CLR.L D5        
    MOVE.W D0,D5  
    AND.L #$00FF,D5
    EXT.W D5
    RTS          


;-------------------------------------------------
;              CODIFICACIÓN K
;-------------------------------------------------        
        

K:                  
  
  CLR.L D5
  MOVE.W D0,D5  ;Movemos la instrucción a D1 para que no se altere su valor
  LSR.L #3,D5   ;Movemos  todos los bits tres posiciones a la izquierda
  AND.L #$00FF,D5 ; Hacemos la máscara
  EXT.W D5      ; Hacemos la extensión de bits 
  RTS
       
       
;-------------------------------------------------
;              CODIFICACIÓN T0,T1
;-------------------------------------------------

; Codificamos T como operando fuente        
T:  ;FUENTE T (Pero sin actualizar flags)
 CLR.L D6
 BTST.L #11,D0 ; En el bit 11 es donde hay que codificar la i
 BEQ T0
 BNE T1
 
; La i puede ser 0 o 1 únicamente 
 T0:
 MOVE.W ET0,D6
 RTS
 
 T1: 
 MOVE.W ET1,D6
 RTS

; Aquí codificamos T cuando funciona como operando destino

T_DEST:   ;DESTINO T  (LOS FLAGS DEPENDEN)
 BTST.L #11,D0
 BEQ T0_DEST
 BNE T1_DEST
 
T0_DEST:
 MOVE.W D6,ET0
 MOVE.W SR,D4
 CLR.L D4
 RTS
 
T1_DEST: 
 MOVE.W D6,ET1
 MOVE.W SR,D4
 CLR.L D4
 RTS

 
    
        
;-------------------------------------------------
;      CODIFICACIÓN B6,B7
;-------------------------------------------------

B:  ; FUENTE T
 CLR.L D6
 BTST.L #11,D0
 BEQ B6   ;BIT 11 ES 0
 BNE B7  ;BIT 11 ES 1
 
B6:
 MOVE.W EB6,D6
 ADD.W D6,D6 
 MOVE.W D6,A1
 RTS
 
B7:
 MOVE.W EB7,D6
 ADD.W D6,D6
 MOVE.W D6,A1
 RTS
 
 
 
;-------------------------------------------------
;           CAMBIO DE SIGNO EN C2
;-------------------------------------------------        
        
CAMBIO_SIGNO:

    NOT.W D1     ; Primero negamos el número      
    ADDQ.W #1,D1 ; Después sumamos 1
    RTS


;-------------------------------------------------
;               BRANCH A PC
;-------------------------------------------------

BRANCH_PC:

  JSR M 
  MOVE.W D5,EPC
  RTS
 
;-------------------------------------------------
;           FIN SUBRUTINAS EXTRAS
;-------------------------------------------------
 
 
 
    ;--- FSUBR: FIN SUBRUTINAS

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
	; ESCRIBID VUESTRO CODIGO AQUI

    MOVE.W D0,-(SP)  ; Hacemos un PUSH del registro que vamos a usar en la subrutina     
    MOVE.W 6(SP),D0  ; Estamos metiendo en D0 el contenido del EIR
                     ; Empezamos a mirar qué instrucción es empezando por el bit número 15
    BTST.L #15,D0     ; Método de la máscara para comprobar si el bit 15
    BNE BIT_1        ; es 1 o 0
    BEQ BIT_0

BIT_0:
         
    BTST.L #14,D0
    BNE BIT_01
    BRA EXIT
    
BIT_01:
    
    BTST.L #13,D0
    BNE BIT_011
    BEQ BIT_010
    
BIT_011:

    BRA BIT_0110 ; Como no hay 0111, saltamos directamente a 0110
    
BIT_0110:
    
    BTST.L #11,D0        
    BNE STC
    BEQ NOT
        
    ; se acaba esta rama
    
BIT_010:
                    
    BTST.L #12,D0
    BNE BIT_0101
    BEQ BIT_0100
    
BIT_0100:
                      
    BTST.L #11,D0
    BNE ADD
    BEQ COPY
        
    ; se acaba esta rama
    
BIT_0101:
    
    BTST.L #11,D0
    BNE AND
    BEQ SUB
        
    ;se acaba esta rama
                        
BIT_1:
    
    BTST.L #14,D0
    BNE BIT_11
    BEQ BIT_10

BIT_11:
    
    BTST.L #13,D0        
    BNE BRZ
    BEQ BIT_110
   
BIT_110:
    
    BTST.L #12,D0        
    BNE BRC
    BEQ BRI
   
    ; se acaba esta rama
    
BIT_10:
   
    BTST.L #13,D0        
    BNE BIT_101
    BEQ BIT_100
    
BIT_101:
    
    BTST.L #12,D0        
    BNE STOI
    BEQ STO
         
BIT_100:
    
    BTST.L #12,D0
    BNE LOAT
    BEQ LOA
       
    ;se acaba esta rama

;-------------------------------------------------
;         INSTRUCCIONES CODIFICADAS
;-------------------------------------------------  
    
EXIT:
    MOVE.W #0,8(SP)  ;EXIT 00
    BRA RETORNO_DEC  ; Estamos moviendo el índice de la instrucción al espacio reservado

COPY:    
    MOVE.W #1,8(SP)    ;COPY 01000
    BRA RETORNO_DEC

ADD:
    MOVE.W #2,8(SP)    ;ADD 01001
    BRA RETORNO_DEC

SUB:    
    MOVE.W #3,8(SP)    ;SUB 01010
    BRA RETORNO_DEC

AND:
    MOVE.W #4,8(SP)    ;AND 01011
    BRA RETORNO_DEC     
    
NOT:
    MOVE.W #5,8(SP)    ;NOT 01100
    BRA RETORNO_DEC     
    
STC:
    MOVE.W #6,8(SP)    ;STC 01101
    BRA RETORNO_DEC

LOA:    
    MOVE.W #7,8(SP)    ;LOA 1000
    BRA RETORNO_DEC
    
LOAT:
    MOVE.W #8,8(SP)    ;LOAT 1001
    BRA RETORNO_DEC

STO:    
    MOVE.W #9,8(SP)    ;STO 1010
    BRA RETORNO_DEC
    
STOI:
    MOVE.W #10,8(SP)   ;STOI 1011
    BRA RETORNO_DEC  

BRI:    
    MOVE.W #11,8(SP)   ;BRI 1100
    BRA RETORNO_DEC
    
BRC:
    MOVE.W #12,8(SP)   ;BRC 1101
    BRA RETORNO_DEC        

BRZ:
    MOVE.W #13,8(SP)   ;BRZ 1110
    BRA RETORNO_DEC

      
    

RETORNO_DEC:

    MOVE.W (SP)+,D0  ; Hacemos POP del registro utilizado
    RTS              ; Volvemos al código principal.
    
    ;--- FDECOD: FIN DECOD
    END    START
































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
