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

TAM_LINHA 		EQU 	81d
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
BLOCK_LEFT 		EQU 	'['
BLOCK_MIDDLE	EQU 	'X'
BLOCK_RIGHT 	EQU		']'
BASE_ASCII      EQU     48d
CENTENA         EQU     100d
DEZENA          EQU     10d
SCOREINC        EQU     10d
SCORELINHA      EQU     1d
SCORECOLUNA     EQU     13d
LINHABLOCO1		EQU 	5d
LINHABLOCO2		EQU 	6d
LINHABLOCO3		EQU 	9d
LINHABLOCO4		EQU 	10d
;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

        	   ORIG      8000h
linha0         STR  	'#==============================================================================#', FIM_TEXTO
linha1		   STR		'#     Score: 000                    ARKANOID                         Vidas: 3  #', FIM_TEXTO
linha2		   STR	 	'#==============================================================================#', FIM_TEXTO
linha3         STR		'#                                                                              #', FIM_TEXTO	
linha4         STR		'#                                                                              #', FIM_TEXTO	
linha5         STR		'#            [X][X][X]   [X][X][X]  [X][X][X]  [X][X][X]  [X][X][X]            #', FIM_TEXTO	
linha6         STR		'#            [X][X][X]   [X][X][X]  [X][X][X]  [X][X][X]  [X][X][X]            #', FIM_TEXTO	
linha7         STR		'#                                                                              #', FIM_TEXTO	
linha8         STR		'#                                                                              #', FIM_TEXTO	
linha9         STR		'#            [X][X][X]   [X][X][X]  [X][X][X]  [X][X][X]  [X][X][X]            #', FIM_TEXTO	
linha10        STR		'#            [X][X][X]   [X][X][X]  [X][X][X]  [X][X][X]  [X][X][X]            #', FIM_TEXTO	
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
linhareset	   STR      '#                                 PRESS R TO RESET                             #', FIM_TEXTO	
linhaSaveBloco STR      '#            [X][X][X]   [X][X][X]  [X][X][X]  [X][X][X]  [X][X][X]            #', FIM_TEXTO
linhaWin 	   STR      '#                              CONGRATULATIONS! YOU WON!                       #', FIM_TEXTO
linha 		   WORD 	0d
coluna         WORD     0d	
nave_pos	   WORD		38d
bola_linha	   WORD		20d
bola_coluna	   WORD		42d	 
direct_X 	   WORD		1d
direct_Y 	   WORD		-1d
gamestate	   WORD 	CONTINUEGAME
lifenumber	   WORD 	NUMERO_DE_VIDAS
ScoreTotal     WORD     0d
ScoreCentena   WORD     0d
ScoreDezena    WORD     0d
ScoreUnidade   WORD     0d 	
totalBlocks    WORD	    60d
;------------------------------------------------------------------------------
; ZONA III: definicao de tabela de interrupções
;------------------------------------------------------------------------------
				ORIG	FE00h
INT0			WORD	MovDir
INT1			WORD	MovEsq
INT2 			WORD 	Reset
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

;------------------------------------------------------------------------------
; Timer: interrupção do timer
;------------------------------------------------------------------------------

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
				MOV R2, M[ bola_linha ]
				MOV R3, M[ bola_coluna ]

				MOV R1, EMPTY
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
				CALL InverteX
				JMP fimBola

comparaEsq:		MOV R6, POS_PAREDEESQ
				CMP M[ bola_coluna ], R6
				JMP.nz comparaTeto
				CALL InverteX
				JMP fimBola

comparaTeto:	MOV R6, POS_TETO
				CMP M[ bola_linha ], R6
				JMP.nz comparaChao
				CALL InverteY
				JMP fimBola

comparaChao:	MOV R6, POS_CHAO
				CMP M[ bola_linha ], R6
				JMP.nz comparaNave
				CALL ReiniciaJogo
				JMP fimBola

comparaNave: 	MOV R6, 20d
				CMP M[ bola_linha ], R6
				JMP.nz comparaBloco
				MOV R6, M[nave_pos]
				CMP M[ bola_coluna ], R6
				JMP.n comparaBloco
				MOV R6, M[ bola_coluna ]
				SUB R6, M[ nave_pos ]
				CMP R6, NAVE_TAM
				JMP.nn comparaBloco
				CALL InverteY

comparaBloco:   CALL ColisaoBloco			

fimBola:		POP R6
				POP R5
				POP R4
				POP R3
				POP R2
				POP R1
				RET
;------------------------------------------------------------------------------
; ColisaoBloco: confere colisoes com o bloco
;------------------------------------------------------------------------------
ColisaoBloco:	PUSH R1
				PUSH R2 ; linha
				PUSH R3 ; coluna
				PUSH R4	; direção X (coluna)
				PUSH R5 ; direção Y (linha)
				PUSH R6
				PUSH R7

				MOV R1, linha0

comparaBlocoEmY: 	ADD R2, R5
					MOV R6, TAM_LINHA ; multiplicador pra acessar a linha
					MOV R7, R2 ; move a linha para R7 para guardar o valor de R2
					MUL R6, R7 ; guarda em R7
					ADD R7, R3 ; adiciono a coluna 
					ADD R1, R7 ; acesso o endereço certo da proxima posição acima ou abaixo do bloco

comparaBlocoEmYesq: MOV R6, M[R1] ; pego o conteudo do proximo end acima ou abaixo
					CMP R6, BLOCK_LEFT
					JMP.nz comparaBlocoEmYmid
					CALL InverteY
					CALL ApagaBloco
                    JMP EndBloco

comparaBlocoEmYmid: CMP R6, BLOCK_MIDDLE
					JMP.nz comparaBlocoEmYdir
					CALL InverteY
					CALL ApagaBloco
                    JMP EndBloco

comparaBlocoEmYdir: CMP R6, BLOCK_RIGHT
					JMP.nz comparaBlocoEmX
					CALL InverteY
					CALL ApagaBloco
                    JMP EndBloco

comparaBlocoEmX: 	MOV R1, linha0 
                    MOV R2, M[ bola_linha ]
                    MOV R3, M[ bola_coluna ]
                    
                    MOV R6, TAM_LINHA ; multiplicador para acessar a linha 
                    MOV R7, R2 ; move a linha para R7 para guardar R2
                    MUL R6, R7 ; guarda em R7
                    ADD R7, R3 ; adiciona a coluna
                    ADD R7, R4 ; adiciona a direção em Y
                    ADD R1, R7 ; acesso endereço do bloco à lateral da bola

comparaBlocoemXdir: MOV R6, M[R1]
                    CMP R6, BLOCK_LEFT
                    JMP.nz comparaBlocoemXesq
                    CALL InverteX
                    INC R3
                    CALL ApagaBloco
                    JMP EndBloco

comparaBlocoemXesq: CMP R6, BLOCK_RIGHT
                    JMP.nz comparaBlocoDiagonal
                    CALL InverteX
                    DEC R3
                    CALL ApagaBloco
                    JMP EndBloco

comparaBlocoDiagonal: MOV R1, linha0
                      MOV R2, M[ bola_linha ]
                      MOV R3, M[ bola_coluna ]

                      ADD R2, R5 ; indice da proxima linha (Y)
                      MOV R6, TAM_LINHA 
                      MOV R7, R2
                      MUL R6, R7
                      ADD R7, R3
                      ADD R7, R4
                      ADD R1, R7

comparaBlocoDiagonalEsq: MOV R6, M[R1]
						 CMP R6, BLOCK_RIGHT
                         JMP.nz comparaBlocoDiagonalDir
                         CALL InverteX
                         CALL InverteY
                         DEC R3
                         CALL ApagaBloco

comparaBlocoDiagonalDir: CMP R6, BLOCK_LEFT
						 JMP.nz EndBloco
						 CALL InverteX
						 CALL InverteY
						 INC R3 
						 CALL ApagaBloco

EndBloco:		POP R7
				POP R6
				POP R5
				POP R4
				POP R3
				POP R2
				POP R1
				RET 

;------------------------------------------------------------------------------
; ApagaBloco: apaga o bloco após a colisão
;------------------------------------------------------------------------------
ApagaBloco:     PUSH R1
                PUSH R2
                PUSH R3
                PUSH R4

				CALL AtualizaScore

                CMP R6, BLOCK_LEFT
                JMP.z ApagaBlocoEsq
                CMP R6, BLOCK_MIDDLE
                JMP.z ApagaBlocoMid
                CMP R6, BLOCK_RIGHT
                JMP.z ApagaBlocoDir
                JMP FimApagaBloco

ApagaBlocoEsq:  MOV R4, EMPTY
                MOV M[R1], R4
                INC R1
                MOV M[R1], R4
                INC R1
                MOV M[ R1 ], R4
                MOV R1, EMPTY
                CALL printchar
                INC R3
                CALL printchar
                INC R3
                CALL printchar
				DEC M[totalBlocks]
                JMP ConfereWin

ApagaBlocoMid:  DEC R1
                DEC R3
                JMP ApagaBlocoEsq

ApagaBlocoDir:  SUB R1, 2
                SUB R3, 2
                JMP ApagaBlocoEsq

ConfereWin: 	MOV R4, M[totalBlocks]
				CMP R4, 0d
				JMP.nz FimApagaBloco
				CALL Win

FimApagaBloco:  POP R4
                POP R3
                POP R2
                POP R1

                RET

;------------------------------------------------------------------------------
; Win: Mostra que o jogador venceu
;------------------------------------------------------------------------------
Win: 			PUSH R1
				PUSH R2
				PUSH R3

				MOV R1, GAMEOVER
				MOV M[ gamestate ], R1

				MOV R1, linhaWin
				MOV R2, 12d
				MOV R3, 0d
				CALL printf
				MOV R1, linhareset
				INC R2
				CALL printf

				MOV R1, EMPTY
				MOV R2, M[bola_linha]
				MOV R3, M[bola_coluna]
				CALL printchar

				POP R3
				POP R2
				POP R1

				RET
;------------------------------------------------------------------------------
; AtualizaScore: atualiza a pontuação
;------------------------------------------------------------------------------
AtualizaScore:  PUSH R1
                PUSH R2
                PUSH R3
                PUSH R4

                MOV R1, SCOREINC ; R1 = 10 (incremento do score)
                ADD M[ScoreTotal], R1 ; Adiciono o incremento no total de pontos

                MOV R1, M[ScoreTotal] ; R1 = pontuação, 123
                MOV R2, CENTENA;
                DIV R1, R2; R1 = RESULTADO, 1   R2 = RESTO, 23
                MOV M[ScoreCentena], R1 ; 1

                MOV R1, DEZENA
                DIV R2, R1; R2 = RESULADO, 2 , R1 = RESTO, 3
                MOV M[ScoreDezena], R2 ; 2

                MOV M[ScoreUnidade], R1 ; 3

                MOV R1, M[ScoreCentena]
                MOV R2, BASE_ASCII
                ADD R1, R2
                MOV R2, SCORELINHA
                MOV R3, SCORECOLUNA
                CALL printchar

                MOV R1, M[ScoreDezena]
                MOV R2, BASE_ASCII
                ADD R1, R2
				MOV R2, SCORELINHA
                MOV R3, SCORECOLUNA
                INC R3
                CALL printchar

                MOV R1, M[ScoreUnidade]
                MOV R2, BASE_ASCII
                ADD R1, R2
				MOV R2, SCORELINHA
                MOV R3, SCORECOLUNA
                INC R3
				INC R3
                CALL printchar

                POP R4
                POP R3
                POP R2
                POP R1

                RET         
;------------------------------------------------------------------------------
; InverteY: troca a direção em Y
;------------------------------------------------------------------------------

InverteY:  		NEG M[ direct_Y ]
				RET

;------------------------------------------------------------------------------
; InverteX: troca a direção em X 
;------------------------------------------------------------------------------
InverteX:  	NEG M[ direct_X ]	
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

                MOV R1, -1d 
                MOV M[ direct_Y ], R1

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
				MOV R1, linhareset
				INC R2
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
				JMP.z endprintf						
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

				ADD     R1, TAM_LINHA
				INC     R2
				INC		R4
				JMP     Ciclo1 
				
Endciclo1:      POP     R4
				POP		R3
				POP		R2
				POP		R1
				RET
;------------------------------------------------------------------------------
; reset: reinicia o jogo após derrota 
;------------------------------------------------------------------------------				
Reset: 			PUSH R1
				PUSH R2
				PUSH R3

				MOV R1, M[ gamestate ]
				CMP R1, 1
				JMP.z FimReset 

				MOV R1, 20d 
				MOV M[ bola_linha ], R1

				MOV R1, 42d
				MOV M[ bola_coluna ], R1

				MOV R1, 38d
				MOV M[ nave_pos ], R1 

				MOV R1, NUMERO_DE_VIDAS
				MOV M[ lifenumber ], R1

				MOV R2, VIDA_LINHA	
				MOV R3, VIDA_COLUNA
				MOV R1, '3'
				CALL printchar	

				MOV R2, linha0 
				ADD R2, TAM_LINHA
				ADD R2, R3
				MOV M[R2], R1
				MOV R1, linha12
				MOV R2, 12d
				MOV R3, 0d 
				CALL printf

				MOV R1, linha13
				INC R2
				CALL printf

				MOV R1, linha20

				MOV R2, 20
				CALL printf

				MOV R1, linha21
				MOV R2, 21
				CALL printf	

				MOV R1, 0d
				MOV M[ScoreTotal], R1

				ADD R1, BASE_ASCII

				MOV R2, SCORELINHA
				MOV R3, SCORECOLUNA
				CALL printchar
				INC R3
				CALL printchar
				INC R3
				CALL printchar	

				MOV R1, linhaSaveBloco
				MOV R2, LINHABLOCO1
				CALL ResetBlocos
				MOV R3, 0d
				CALL printf
				MOV R2, LINHABLOCO2
				CALL ResetBlocos
				CALL printf
				MOV R2, LINHABLOCO3
				CALL ResetBlocos
				CALL printf
				MOV R2, LINHABLOCO4
				CALL ResetBlocos
				CALL printf

				MOV R1, CONTINUEGAME
				MOV M[ gamestate ], R1
				CALL ConfigurarTimer

FimReset: 		POP R3
				POP R2
				POP R1
				RTI
;------------------------------------------------------------------------------
; ResetBlocos: coloca os blocos de volta na memoria
; 			   R1 = Linha que vai ser colocada de volta	 
; 			   R2 = Linha em que vai ser feita a reposição na memória
; 			   R3 = Contador/iterador sobre as colunas
; 			   R4 = Salva o contexto de R2
;			   R5 = auxiliar
;------------------------------------------------------------------------------
ResetBlocos:	PUSH R1
            	PUSH R2
           		PUSH R3
            	PUSH R4

				MOV R3, 0
LoopBlocos:		CMP R3, TAM_LINHA
            	JMP.z EndResetBlocos

				MOV R1, TAM_LINHA
				MOV R4, R2 ; Salva o contexto do 2 (nao pode ser alterado ao longo da execução)
				MUL R1, R4 ; Guarda a quantidade a ser adicionada à linha 0
				MOV R1, linha0
				ADD R4, R1 ; Guarda o resultado da soma em R4
				
				MOV R1, linhaSaveBloco 
				ADD R4, R3
				ADD R1, R3

				MOV R5, M[R1]
				MOV M[R4], R5

				INC R3
				JMP LoopBlocos

EndResetBlocos: POP R4
            	POP R3
            	POP R2
            	POP R1
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