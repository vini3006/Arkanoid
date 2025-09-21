;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
WRITE	        EQU     FFFEh
INITIAL_SP      EQU     FDFFh
CURSOR		    EQU     FFFCh
CURSOR_INIT		EQU		FFFFh
FIM_TEXTO       EQU     '@'
LINHA_NAVE 		EQU 	21d
EMPTY           EQU 	' '
NAVE_CHAR 	    EQU		'_'
NAVE_TAM		EQU		7d
;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

        	   ORIG      8000h
linha0         STR  	'%==============================================================================%', FIM_TEXTO
linha1		   STR		'%     Score:                        ARKANOID                         Vidas:    %', FIM_TEXTO
linha2		   STR	 	'%==============================================================================%', FIM_TEXTO
linha3         STR		'|                                                                              |', FIM_TEXTO	
linha4         STR		'|                                                                              |', FIM_TEXTO	
linha5         STR		'|                                                                              |', FIM_TEXTO	
linha6         STR		'|                                                                              |', FIM_TEXTO	
linha7         STR		'|                                                                              |', FIM_TEXTO	
linha8         STR		'|                                                                              |', FIM_TEXTO	
linha9         STR		'|                                                                              |', FIM_TEXTO	
linha10        STR		'|                                                                              |', FIM_TEXTO	
linha11        STR		'|                                                                              |', FIM_TEXTO	
linha12        STR		'|                                                                              |', FIM_TEXTO	
linha13        STR		'|                                                                              |', FIM_TEXTO	
linha14        STR		'|                                                                              |', FIM_TEXTO	
linha15        STR		'|                                                                              |', FIM_TEXTO	
linha16        STR		'|                                                                              |', FIM_TEXTO	
linha17        STR		'|                                                                              |', FIM_TEXTO	
linha18        STR		'|                                                                              |', FIM_TEXTO	
linha19        STR		'|                                                                              |', FIM_TEXTO	
linha20        STR		'|                                                                              |', FIM_TEXTO	
linha21        STR		'|                                     _______                                  |', FIM_TEXTO
linha22        STR		'|                                                                              |', FIM_TEXTO
linha23        STR		'|==============================================================================|', FIM_TEXTO
linha 		   WORD 	0d
coluna         WORD     0d	
nave_pos	   WORD		38d
;------------------------------------------------------------------------------
; ZONA III: definicao de tabela de interrupções
;------------------------------------------------------------------------------
				ORIG	FE00h
INT0			WORD	MovDir
INT1			WORD	MovEsq
;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main

Rotina:			PUSH R1
				PUSH R2	
				PUSH R3
			
				POP R3
				POP R2
				POP R1
				RET


;------------------------------------------------------------------------------
; MovDir: mexe a nave para a direita
;------------------------------------------------------------------------------

MovDir:			PUSH R1
				PUSH R2	
				PUSH R3

				MOV R2, LINHA_NAVE
				MOV R1, EMPTY
				MOV R3, M [ nave_pos ]
				CMP R3, 72d
				JMP.z terminadir
 				CALL printchar

				MOV R1, NAVE_CHAR
				ADD R3,NAVE_TAM
				CALL printchar	

				INC M[ nave_pos ]

terminadir:		POP R3
				POP R2
				POP R1
				RTI

;------------------------------------------------------------------------------
; MovEsq: mexe a nave para a direita
;------------------------------------------------------------------------------

MovEsq:			PUSH R1
				PUSH R2	
				PUSH R3
				
				MOV R3, M[ nave_pos ]
				CMP R3, 1d
				JMP.z terminaesq

				DEC M[ nave_pos ]
				MOV R3, M[ nave_pos ]
				MOV R2, LINHA_NAVE
				MOV R1, NAVE_CHAR
 				CALL printchar

				MOV R1, EMPTY
				ADD R3, NAVE_TAM
				CALL printchar	

terminaesq:		POP R3
				POP R2
				POP R1
				RTI
;------------------------------------------------------------------------------
; printchar: imprime caracter
;		R1 = caracter
;		R2 = linha
;		R3 = COLUNA
;------------------------------------------------------------------------------

printchar:		PUSH 	R1
				PUSH 	R2
				PUSH 	R3

				SHL		R2, 8d
				OR		R2, R3
				MOV		M[ CURSOR ], R2
				MOV     M[ WRITE ], R1

				POP  	R3
				POP  	R2
				POP  	R1	
				RET
;------------------------------------------------------------------------------
; printf: imprime string
;		R1 = endereco da string;
;		R2 = linha
;		R3 = COLUNA
;		R4 = CARACTER ATUAL
;		R5 = CONTADOR
;		R6 = SALVA A linha PRA NAO MATAR O AlinhaMENTO
;------------------------------------------------------------------------------

printf:			PUSH R1
				PUSH R2	
				PUSH R3
				PUSH R4
				PUSH R5
				PUSH R6

				MOV R5, 0d
Ciclo:			MOV R6, R2
				ADD R1, R5
				MOV R4, M[R1]
				CMP R4, FIM_TEXTO		
				JMP.z   endprintf						
				ADD R3, R5; COLUNA
				SHL R6, 8
				OR  R6, R3
				MOV M[CURSOR], R6
				MOV M[WRITE], R4
				SUB R1, R5
				SUB R3, R5
				INC R5
				JMP Ciclo

endprintf:		POP R6
				POP R6
				POP R4
				POP R3
				POP R2
				POP R1		
				RET

;------------------------------------------------------------------------------
; printmapa: imprime mapa
;		R1 = endereco da string;
;		R2 = linha
;		R3 = COLUNA
;		R4 = Contador
;------------------------------------------------------------------------------

printmapa:      PUSH 	R1
				PUSH	R2
				PUSH	R3
				PUSH	R4

				MOV		R1, linha0
				MOV		R2, M[ linha ]
				MOV     R4, 0d

Ciclo1:			CMP     R4, 24d                
				JMP.z   Endciclo1

				MOV		R3, M[ coluna ]
				CALL	printf

				ADD     R1, 81d
				INC     R2
				INC		R4
				JMP     Ciclo1 
				
Endciclo1:      POP     R4
				POP		R3
				POP		R2
				POP		R1
				RET



Main:			ENI
				MOV		R1, INITIAL_SP
				MOV		SP, R1		 		; We need to initialize the stack
				MOV		R1, CURSOR_INIT		; We need to initialize the cursor 
				MOV		M[ CURSOR ], R1		; with value CURSOR_INIT
                
				MOV		R1, linha0
				MOV		R2, M[ linha ]
				MOV     R4, 0d

				CALL	printmapa


Cycle: 			BR		Cycle	
Halt:           BR		Halt