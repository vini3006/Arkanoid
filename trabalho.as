;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
WRITE	        EQU     FFFEh
INITIAL_SP      EQU     FDFFh
CURSOR		    EQU     FFFCh
CURSOR_INIT		EQU		FFFFh

FIM_TEXTO       EQU     '@'
TIMER_UNIT 		EQU 	FFF6h
ACTIVATE_TIME 	EQU 	FFF7h
ON 				EQU		1d
OFF 			EQU 	0d

LINHA_NAVE 		EQU 	21d
BOLA_CHAR		EQU 	'o'
EMPTY           EQU 	' '
NAVE_CHAR 	    EQU		'-'
NAVE_TAM		EQU		9d
POS_PAREDEDIR 	EQU 	78d
POS_PAREDEESQ 	EQU 	1d
POS_TETO		EQU		3d
POS_CHAO		EQU     22d
VIDA_LINHA 		EQU 	1d
VIDA_COLUNA 	EQU 	76d
MEIO_NAVE 		EQU 	4d
GAMEOVER		EQU 	0d
CONTINUEGAME	EQU 	1d
NUMERO_DE_VIDAS	EQU 	3d
;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

        	   ORIG      8000h
linha0         STR  	'#==============================================================================#', FIM_TEXTO
linha1		   STR		'#     Score:                        ARKANOID                         Vidas: 3  #', FIM_TEXTO
linha2		   STR	 	'#==============================================================================#', FIM_TEXTO
linha3         STR		'#                                                                              #', FIM_TEXTO	
linha4         STR		'#                                                                              #', FIM_TEXTO	
linha5         STR		'#                                                                              #', FIM_TEXTO	
linha6         STR		'#                                                                              #', FIM_TEXTO	
linha7         STR		'#                                                                              #', FIM_TEXTO	
linha8         STR		'#                                                                              #', FIM_TEXTO	
linha9         STR		'#                                                                              #', FIM_TEXTO	
linha10        STR		'#                                                                              #', FIM_TEXTO	
linha11        STR		'#                                                                              #', FIM_TEXTO	
linha12        STR		'#                                                                              #', FIM_TEXTO	
linha13        STR		'#                                                                              #', FIM_TEXTO	
linha14        STR		'#                                                                              #', FIM_TEXTO	
linha15        STR		'#                                                                              #', FIM_TEXTO	
linha16        STR		'#                                                                              #', FIM_TEXTO	
linha17        STR		'#                                                                              #', FIM_TEXTO	
linha18        STR		'#                                                                              #', FIM_TEXTO	
linha19        STR		'#                                                                              #', FIM_TEXTO	
linha20        STR		'#                                         o                                    #', FIM_TEXTO	
linha21        STR		'#                                     ---------                                #', FIM_TEXTO
linha22        STR		'#                                                                              #', FIM_TEXTO
linha23        STR		'#==============================================================================#', FIM_TEXTO
linhagameover  STR		'#                                     GAMEOVER                                 #', FIM_TEXTO	
linha 		   WORD 	0d
coluna         WORD     0d	
nave_pos	   WORD		38d
bola_linha	   WORD		20d
bola_coluna	   WORD		42d	 
direct_X 	   WORD		1d
direct_Y 	   WORD		-1d
gamestate	   WORD 	CONTINUEGAME
lifenumber	   WORD 	NUMERO_DE_VIDAS
;------------------------------------------------------------------------------
; ZONA III: definicao de tabela de interrupções
;------------------------------------------------------------------------------
				ORIG	FE00h
INT0			WORD	MovDir
INT1			WORD	MovEsq
				ORIG 	FE0Fh
INT15 			WORD 	Timer				
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





Timer:   		PUSH R1

				MOV  R1, M[ gamestate ]
				CMP  R1, GAMEOVER
				JMP.Z DeactiveTimer

				CALL MovBall
				CALL ConfigurarTimer
				JMP EndTimer

DeactiveTimer:  MOV R1, OFF
				MOV M[ ACTIVATE_TIME ], R1

EndTimer:		POP R1
				RTI

;------------------------------------------------------------------------------
; MovDir: mexe a nave para a direita
;------------------------------------------------------------------------------

MovDir:			PUSH R1
				PUSH R2	
				PUSH R3

				MOV R2, LINHA_NAVE
				MOV R1, EMPTY
				MOV R3, M [ nave_pos ]
				CMP R3, 70d
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
; MovBall: mexe a bola
;          R1: caracter
;   	   R2: linha
;  	   	   R3: coluna	
;------------------------------------------------------------------------------

MovBall: 		PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				PUSH R6

				MOV R4, M[ direct_X ]
				MOV R5, M[ direct_Y ]

				MOV R1, EMPTY
				MOV R2, M[ bola_linha ]
				MOV R3, M[ bola_coluna ]
				CALL printchar

				ADD R2, R5
				MOV M[ bola_linha ], R2
				ADD R3, R4
				MOV M[ bola_coluna ], R3
				MOV R1, BOLA_CHAR
				CALL printchar

comparaDir:		MOV R6, POS_PAREDEDIR
				CMP M[ bola_coluna ], R6
				JMP.nz comparaEsq
				CALL ColisaoNaDir

comparaEsq:		MOV R6, POS_PAREDEESQ
				CMP M[ bola_coluna ], R6
				JMP.nz comparaTeto
				CALL ColisaoNaEsq

comparaTeto:	MOV R6, POS_TETO
				CMP M[ bola_linha ], R6
				JMP.nz comparaChao
				CALL ColisaoEmCima

comparaChao:	MOV R6, POS_CHAO
				CMP M[ bola_linha ], R6
				JMP.nz comparaNave
				CALL ReiniciaJogo

comparaNave: 	MOV R6, 20d
				CMP M[ bola_linha ], R6
				JMP.nz fimBola
				MOV R6, M[nave_pos]
				CMP M[ bola_coluna ], R6
				JMP.n fimBola
				MOV R6, M[ bola_coluna ]
				SUB R6, M[ nave_pos ]
				CMP R6, NAVE_TAM
				JMP.nn fimBola
				CALL ColisaoEmBaixo

fimBola:		POP R6
				POP R5
				POP R4
				POP R3
				POP R2
				POP R1
				RET

;------------------------------------------------------------------------------
; ColisaoEmCima: troca a direção em Y
;------------------------------------------------------------------------------

ColisaoEmCima:  PUSH R6

				MOV R6, 2
				ADD M[ direct_Y ], R6

				POP R6
				RET

;------------------------------------------------------------------------------
; ColisaoEmBaixo: troca a direção em Y 
;------------------------------------------------------------------------------

ColisaoEmBaixo: 	PUSH R6

				MOV R6, 2
				SUB M[ direct_Y ], R6

				POP R6
				RET

;------------------------------------------------------------------------------
; ColisaoNaDir: troca a direção em X 
;------------------------------------------------------------------------------
ColisaoNaDir:  		PUSH R6

					 MOV R6, 2
					 SUB M[ direct_X ], R6

					 POP R6
					 RET

;------------------------------------------------------------------------------
; ColisaoNaEsq: troca a direção em X 
;------------------------------------------------------------------------------
ColisaoNaEsq:  PUSH R6

					 MOV R6, 2
					 ADD M[ direct_X ], R6

					 POP R6
					 RET

;------------------------------------------------------------------------------
; ReiniciaJogo: reiniciar o jogo
;				R1: Bola
;				R2: linha
;				R3: coluna
; 				R4: aux
;------------------------------------------------------------------------------
ReiniciaJogo:  	PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5

				MOV R1, EMPTY
				MOV R2, M[ bola_linha ]
				MOV R3, M[ bola_coluna ]
				CALL printchar

				MOV R2, 20d
				MOV M[ bola_linha ], R2
				MOV R3, M [ nave_pos ]
				ADD R3, MEIO_NAVE
				MOV M[ bola_coluna ], R3

				MOV R1, BOLA_CHAR
				CALL printchar

				MOV R4, linha1
				ADD R4, VIDA_COLUNA
				DEC M[ lifenumber ]
				MOV R5, M[ lifenumber ]
				DEC M[ R4 ]
				MOV R1, M[ R4 ]
				MOV R2, VIDA_LINHA
				MOV R3, VIDA_COLUNA
				CALL printchar
				CMP R5, GAMEOVER
				JMP.z gameover
				JMP continue

gameover: 		MOV R5, GAMEOVER
				MOV M[ gamestate ], R5
				MOV R1, linhagameover
				MOV R2, 12d
				MOV R3, 0d
				CALL printf

continue:		POP R5
				POP R4
				POP R3
				POP R2
				POP R1

				RET
			
				
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
;		R6 = SALVA A linha PRA NAO MATAR O Alinhamento
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
				POP R5
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

;------------------------------------------------------------------------------
; ConfigurarTimer: configurar timer
;------------------------------------------------------------------------------

ConfigurarTimer: PUSH R1

				 MOV R1, 2d
				 MOV M[ TIMER_UNIT ], R1
				 MOV R1, ON
				 MOV M[ ACTIVATE_TIME ], R1

			     POP R1
				 RET

Main:			ENI
				MOV		R1, INITIAL_SP
				MOV		SP, R1		 		; We need to initialize the stack
				MOV		R1, CURSOR_INIT		; We need to initialize the cursor 
				MOV		M[ CURSOR ], R1		; with value CURSOR_INIT
                
				MOV		R1, linha0
				MOV		R2, M[ linha ]
				MOV     R4, 0d

				CALL printmapa
				CALL ConfigurarTimer
				

Cycle: 			BR		Cycle	
Halt:           BR		Halt