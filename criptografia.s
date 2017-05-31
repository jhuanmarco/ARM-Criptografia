.global _start @ ROTULO INICIAL

@----------- MAPA DISPLAY KEYBOARD 
		.set KBD_DATA,   0x90010		@ ENDEREÇO DE DADOS DO KEYBOARD
		.set KBD_STATUS, 0x90011		@ ENDEREÇO DE STATUS DO KEYBOARD
		
@----------- CONSTANTES

		.equ KBD_READY,	0x1 			@ VERIFICAÇÃO DE TECLADO PRESSIONADO
		.equ MSG_TAMANHO,256			@ TAMANHO MAXIMO DA MENSAGEM
		.equ CHAVE_TAMANHO, 20			@ TAMANHO MAXIMO DA CHAVE
		
@----------- VARIAVEIS
		
		chave: .skip CHAVE_TAMANHO		@ ALOCA CHAVE_TAMANHO BYTES NA MEMORIA PARA A CHAVE
		mensagem_desc: .skip MSG_TAMANHO	@ ALOCA CHAVE_TAMANHO BYTES NA MEMORIA PARA A MSG DESCRIPTOGRAFADA
		mensagem: .skip MSG_TAMANHO		@ ALOCA MSG_TAMANHO BYTES NA MEMORIA PARA A MSG
	
@----------- MENSAGENS
		@ MENSAGENS QUE APARECEM NA JANELA AO RODAR O CÓDIGO, LEN SO OS TAMANHOS DAS MENSAGENS (NECESSARIO PARA PRINTAR DE ACORDO COM A FUNCAO DO SISTEMA)

		msg_inicial:				
			.ascii "----------------------------------------\n -- CRIPTOGRAFIA DE MENSAGEM ARMSIM --\n----------------------------------------\n * - PARA DIGITAR A CHAVE DE CRIPTOGRAFIA\n # - PARA SAIR\n\n"
		
		len_inicial = . - msg_inicial		
		
		msg_inserir_chave:			
			.ascii " DIGITE A CHAVE DE CRIPTOFRAFIA (MIN 10 E MAX 20 DIGITOS)\n '#' PARA TERMINAR A INSERCAO\n\n CHAVE = "
			
		len_inserir_chave = . - msg_inserir_chave 	
		
		escreve_asterisco:			
			.ascii "*"
		
		msg_inserir_msg:			
			.ascii "\n\n INSIRA A MENSAGEM A SER CRIPTOGRAFADA\n\n"
			
		len_inserir_msg= . - msg_inserir_msg	
		
		msg_cripto:				
			.ascii " MENSAGEM CRIPTOGRAFADA: " 
			
		len_cripto = . - msg_cripto 		
		
		msg_menu_desc:
			.ascii "\n\n----------------------------------------\n -- DESCRIPTOGRAFIA DE MENSAGEM ARMSIM -- \n----------------------------------------\n * - PARA DIGITAR A CHAVE DE DESCRIPTOGRAFIA\n # - PARA SAIR\n\n"			 
		
		len_menu_desc= . - msg_menu_desc
		
		msg_desc:				
			.ascii " DIGITE A CHAVE DE DESCRIPTOFRAFIA\n '#' PARA TERMINAR A INSERCAO\n\n CHAVE =  "
			
		len_msg_desc = . - msg_desc     	
		
		msg_descriptografada:			
			.ascii "\n\n MENSAGEM DESCRIPTOGRAFADA: "
			
		len_descriptografada = . - msg_descriptografada		
		
		msg_fim:						
			.ascii "\n\n -- EXECUCAO FINALIZADA --\n\n\n"
			
		len_msg_fim = . - msg_fim 		
				
@----------- FUNCOES
							@ NÃO FUNCIONAL (CALL E RET NAO RECONHECIDOS PELO MONTADOR)
	
@----------- INICIO
	
	inicio:
		
		@ ESCREVE A MENSAGEM INICIAL DO PROGRAMA
		mov	r0, #1				@ 1 PARA WRITE, 0 PARA READ
		ldr     r1, =msg_inicial   		@ R1 CONTEM ENDEREÇO DA MENSAGEM
		ldr     r2, =len_inicial 		@ R2 CONTEM TAMANHO DA MENSAGEM
		mov     r7, #4      			@ 4 PARA WRITE, 3 PARA READ
		svc     0x055   			@ FUNCAO PARA WRITE, R0 E R7 COFIGURAÇÃO DO SIMULADOR, R1 CONTEM BUFFER DE MSG E R2 O TAMANHO
				
@----------- MENU INICIAL

		le_asterisco:
			ldr	r3, =KBD_STATUS			@ R3 CONTEM ENDEREÇO DE STATUS DO TECLADO
			ldr	r4, [r3]			@ CARREGA EM R4 O STATUS DO TECLADO, SE PRESSIONADO UMA TECLA STATUS = 1
			cmp 	r4, #KBD_READY			@ VERIFICA SE FOI PRESSIONADO UMA TECLA	(KDB_READY = 1 ?)
			bne	le_asterisco			@ SE NAO FOR PRESSIONADO VOLTA A LER A CHAVE
			
			ldr	r5, =KBD_DATA			@ SE PRESSIONADO R5 RECEBE ENDEREÇO DA TECLA PRESSIONADA
			ldr	r6, [r5]			@ R6 RECEBE A TECLA PRESSIONADA
			cmp	r6, #10				@ VERIFICA SE É O CARACTERE *
			beq	bloco_chave			@ SE FOR COMEÇA A LEITURA DA CHAVE
			
			cmp	r6, #11				@ SE NÃO, VERIFICA SE É O CARACTERE #
			bne	le_asterisco			@ SE NAO FOR, ENCERRA A EXECUÇÃO
			b	fim				@ SE FOR, TERMINA A EXECUÇÃO

@----------- DIGITAR A CHAVE INICIAL
			
		bloco_chave:
		
			@ MSG PARA INSERIR A CHAVE
			mov	r0, #1				@ 1 PARA WRITE, 0 PARA READ
			ldr     r1, =msg_inserir_chave	 	@ R1 CONTEM ENDEREÇO DA MENSAGEM
			ldr     r2, =len_inserir_chave	 	@ R2 CONTEM TAMANHO DA MENSAGEM
			mov     r7, #4      			@ 4 PARA WRITE, 3 PARA READ
			svc     0x055   			@ FUNCAO PARA WRITE, R0 E R7 COFIGURAÇÃO DO SIMULADOR, R1 CONTEM BUFFER DE MSG E R2 O TAMANHO
		
			mov 	r3, #0				@ R3 CONTEM A QUANTIDADE DE CARACTERES DA CHAVE
			ldr	r8, =chave			@ R8 RECEBE ENDEREÇO DA CHAVE
		
		le_chave:
			ldr	r4, =KBD_STATUS			@ R3 CONTEM ENDEREÇO DE STATUS DO TECLADO
			ldr	r5, [r4]			@ CARREGA EM R4 O STATUS DO TECLADO, SE PRESSIONADO UMA TECLA STATUS = 1
			cmp 	r5, #KBD_READY			@ VERIFICA SE FOI PRESSIONADO UMA TECLA	(KDB_READY = 1 ?)
			bne	le_chave			@ SE NAO FOR PRESSIONADO VOLTA A LER A CHAVE
			
			ldr	r6, =KBD_DATA			@ SE PRESSIONADO R5 RECEBE ENDEREÇO DA TECLA PRESSIONADA
			ldr	r7, [r6]			@ R7 RECEBE A TECLA PRESSIONADA
			cmp	r7, #10				@ VERIFICA SE É O CARACTERE *
			beq	le_chave			@ SE FOR VOLTA PARA LER A CHAVE (IGNORA *)
			
			cmp	r7, #11				@ VERIFICA SE FOR O CARACTERE #
			bne	armazena_chave      		@ SE NAO FOR #
			cmp	r3, #10				@ SE FOR # VERIFICA SE JÁ HÁ AO MENOS 10 DIGITOS A CHAVE
			blt	le_chave			@ CASO NAO HAJA AO MENOS 10 DIGITOS IGNORA O #
			b	bloco_mensagem			@ E CASO HAJA 10 OU MAIS DIGITOS COMEÇA LEITURA DA MENSAGEM
						
		armazena_chave:
			strb	r7, [r8, r3]			@ GUARDA O BYTE COM A CHAVE NO ENDEREÇO DA CHAVE + O DESLOCAMENTO (QUE ESTA EM R3)	
			add 	r3, r3, #1			@ SOMA 1 AO DESLOCAMENTO (QUE É A LARGURA DA CHAVE)
			
			@ESCREVE * AO PRESSIONAR A CHAVE
			mov	r0, #1			@ 1 PARA WRITE, 0 PARA READ
			ldr     r1, =escreve_asterisco	 	@ R1 CONTEM ENDEREÇO DA MENSAGEM
			mov     r2, #1			 	@ R2 CONTEM TAMANHO DA MENSAGEM
			mov     r7, #4      			@ 4 PARA WRITE, 3 PARA READ
			svc     0x055   			@ FUNCAO PARA WRITE, R0 E R7 COFIGURAÇÃO DO SIMULADOR, R1 CONTEM END. DE MSG E R2 O TAMANHO
			
			cmp	r3, #CHAVE_TAMANHO		@ COMPARA SE A CHAVE POSSUI 20 DIGITOS
			bne	le_chave			@ CASO NAO TENHA CONTINUA LENDO MAIS DIGITOS, ATE ATINGIR 20 OU PRESSIONAR #
		
@----------- DIGITAR A MENSAGEM

		bloco_mensagem:
		
			@ MSG PARA INSERIR A MENSAGEM
			mov	r0, #1				@ 1 PARA WRITE, 0 PARA READ
			ldr     r1, =msg_inserir_msg	 	@ R1 CONTEM ENDEREÇO DA MENSAGEM
			ldr     r2, =len_inserir_msg	 	@ R2 CONTEM TAMANHO DA MENSAGEM
			mov     r7, #4      			@ 4 PARA WRITE, 3 PARA READ
			svc     0x055   			@ FUNCAO PARA WRITE, R0 E R7 COFIGURAÇÃO DO SIMULADOR, R1 CONTEM BUFFER DE MSG E R2 O TAMANHO


			mov     r0, #0     			@ 1 PARA WRITE, 0 PARA READ
			ldr     r1, =mensagem 			@ R1 CONTEM ENDEREÇO DE ARMAZENAMENTO
			ldr     r2, =MSG_TAMANHO		@ R2 CONTEM TAMANHO DA MENSAGEM A SER LIDA
			mov     r7, #3      			@ 4 PARA WRITE, 3 PARA READ
			svc     #0x55      			@ FUNCAO PARA READ, R0 E R7 COFIGURAÇÃO DO SIMULADOR, R1 CONTEM END. DE MSG E R2 O TAMANHO
			mov	r4, r0				@ R0 NO FINAL DA INSTRUCAO POSSUI O NUMERO DE BYTES LIDOSX'
			
	
@----------- CRIPTOGRAFIA

			@ R3 CONTEM O TAMANHO DA CHAVE (NAO MODIFICADO DO BLOCO DA CHAVE)
			@ R4 POSSUI O TAMANHO DA MENSAGEM (MANTIDO DO BLOCO ANTERIOR)
			
			mov	r12, r4				@ R12 RECEBE O TAMANHO DA MENSAGEM (R11 É USADO POSTERIORMENTE PARA DESCRIPTOGRAFAR, VISTO QUE R4 É USADO PARA OUTRAS TAREFAS ATÉ LÁ [LINHA 270])
			
			mov	r6, #0				@ COUNT PARA ANDAR NA MENSAGEM
			mov 	r5, #0 				@ COUNT PARA ANDAR NA CHAVE
			ldr 	r7, =chave			@ R5 APONTA PARA INICIO DA MENSAGEM
			ldr	r8, =mensagem			@ R6 APONTA PARA INICIO DA CHAVE
	
			
		criptografa:	
			ldrb	r9, [r7, r5]			@ R9 POSSUI O BYTE ATUAL DA CHAVE
			ldrb	r10, [r8, r6]			@ R10 POSSUI O BYTE ATUAL DA MSG
			
			add	r10, r10, r9			@ R10 É ATUALIZADO R10 = R10 + CHAVE
			strb	r10, [r8, r6]			@ O BYTE ATUAL DA MESAGEM É ATUALIZADO COM R10
			
			add     r6, r6, #1			@ PERCORRE A MENSAGEM
			cmp 	r6, r4				@ COMPARA SE CHEGOU NO FINAL DELA
			beq	criptografia_concluida		@ SE CHEGOU PULA PARA A CONCLUSAO
				
			add	r5, r5, #1			@ PERCORRE A CHAVE
			cmp	r5, r3				@ COMPARA SE CHEGOU NO FINAL DA CHAVE 
			moveq	r5, #0				@ SE CHEGOU NO FINAL VOLTA PARA O INICIO DELA NOVAMENTE
			
			b 	criptografa			@ PULA PARA O PROX BYTE DA MENSAGEM			
			
		criptografia_concluida:
			@ ESCREVE A MENSAGEM CRIPTOGRAFADA
			mov	r0, #1				@ 1 PARA WRITE, 0 PARA READ
			ldr     r1, =msg_cripto   		@ R1 CONTEM ENDEREÇO DA MENSAGEM
			ldr     r2, =len_cripto 		@ R2 CONTEM TAMANHO DA MENSAGEM
			mov     r7, #4      			@ 4 PARA WRITE, 3 PARA READ
			svc     0x055   			@ FUNCAO PARA WRITE, R0 E R7 COFIGURAÇÃO DO SIMULADOR, R1 CONTEM BUFFER DE MSG E R2 O TAMANHO
			
			mov	r0, #1				@ 1 PARA WRITE, 0 PARA READ
			mov     r1, r8  			@ R1 CONTEM ENDEREÇO DA MENSAGEM
			mov     r2, r4			 	@ R2 CONTEM TAMANHO DA MENSAGEM
			mov     r7, #4      			@ 4 PARA WRITE, 3 PARA READ
			svc     0x055   			@ FUNCAO PARA WRITE, R0 E R7 COFIGURAÇÃO DO SIMULADOR, R1 CONTEM BUFFER DE MSG E R2 O TAMANHO
		
@----------- MENU DESCRIPTOGRAFIA	

		descriptografia:		
		
		@ MSG DO MENU DE DESCRIPTOGRAFIA
		mov	r0, #1					@ 1 PARA WRITE, 0 PARA READ
		ldr     r1, =msg_menu_desc			@ R1 CONTEM ENDEREÇO DA MENSAGEM
		ldr     r2, =len_menu_desc			@ R2 CONTEM TAMANHO DA MENSAGEM
		mov     r7, #4      				@ 4 PARA WRITE, 3 PARA READ
		svc     0x055   				@ FUNCAO PARA WRITE, R0 E R7 COFIGURAÇÃO DO SIMULADOR, R1 CONTEM BUFFER DE MSG E R2 O TAMANHO
		
		le_asterisco_desc:
			ldr	r3, =KBD_STATUS			@ R3 CONTEM ENDEREÇO DE STATUS DO TECLADO
			ldr	r4, [r3]			@ CARREGA EM R4 O STATUS DO TECLADO, SE PRESSIONADO UMA TECLA STATUS = 1
			cmp 	r4, #KBD_READY			@ VERIFICA SE FOI PRESSIONADO UMA TECLA	(KDB_READY = 1 ?)
			bne	le_asterisco_desc		@ SE NAO FOR PRESSIONADO VOLTA A LER A CHAVE
		
			ldr	r5, =KBD_DATA			@ SE PRESSIONADO R5 RECEBE ENDEREÇO DA TECLA PRESSIONADA
			ldr	r6, [r5]			@ R6 RECEBE A TECLA PRESSIONADA
			cmp	r6, #10				@ COMPARA DE R6 É ASTERISCO
			beq	bloco_chave_desc		@ SE FOR * COMEÇA A LER A CHAVE
			
			cmp 	r6, #11				@ SE NAO FOR ASTERISCO COMPARA SE É #
			bne	le_asterisco_desc		@ SE NAO FOR # VOLTA A ESPERAR ASTERISCO
			
			b	fim				@ SE FOR # ENCERRA A EXECUCAO
				
@----------- RECEBE CHAVE DESCRIPTOGRAFIA	
			
		bloco_chave_desc:
			mov	r0, #1				@ 1 PARA WRITE, 0 PARA READ
			ldr     r1, =msg_desc			@ R1 CONTEM ENDEREÇO DA MENSAGEM
			ldr     r2, =len_msg_desc		@ R2 CONTEM TAMANHO DA MENSAGEM
			mov     r7, #4      			@ 4 PARA WRITE, 3 PARA READ
			svc     0x055   			@ FUNCAO PARA WRITE, R0 E R7 COFIGURAÇÃO DO SIMULADOR, R1 CONTEM BUFFER DE MSG E R2 OTAMANHO
			
			mov 	r3, #0				@ R3 É O TAMANHO DA CHAVE
			ldr	r8, =chave			@ R8 RECEBE O ENDEREÇO DA CHAV
			
		le_chave_desc:			
			ldr	r4, =KBD_STATUS			@ R4 CONTEM ENDEREÇO DE STATUS DO TECLADO
			ldr	r5, [r4]			@ CARREGA EM R5 O STATUS DO TECLADO, SE PRESSIONADO UMA TECLA STATUS = 1
			cmp 	r5, #KBD_READY			@ VERIFICA SE FOI PRESSIONADO UMA TECLA	(KDB_READY = 1 ?)
			bne	le_chave_desc			@ SE NAO FOR PRESSIONADO VOLTA A LER A CHAVE
			
			ldr	r6, =KBD_DATA			@ SE PRESSIONADO R6 RECEBE ENDEREÇO DA TECLA PRESSIONADA
			ldr	r7, [r6]			@ R7 RECEBE A TECLA PRESSIONADA
			
			cmp 	r7, #10				@ COMPARA SE R7 É *
			beq	le_chave_desc			@ SE FOR, IGNORA
			
			cmp 	r7, #11				@ COMPARA SE R7 É #
			bne	armazena_chave_desc		@ SE NAO FOR, ESCREVE A CHAVE DE DESCRIPTOGRAFIA
			
			cmp	r3, #1				@ SE FOR, COMPARA SE A CHAVE TEM AO MENOS UM DIGITO
			bge	bloco_descriptografia		@ SE TIVER AO MENOS 1 DIGITO VAI PARA DESCRIPTOGRAFIA
			
			b	le_chave_desc			@ SE NAO, IGNORA
			
		armazena_chave_desc:
			strb	r7, [r8,r3]			@ ARMAZENA NA CHAVE O VALOR PRESSIONADO
			add	r3, r3, #1			@ SOMA R3 PARA DESLOCAR PARA A PROXIMA POSICAO
			
			@ESCREVE * AO PRESSIONAR A CHAVE
			mov	r0, #1				@ 1 PARA WRITE, 0 PARA READ
			ldr     r1, =escreve_asterisco	 	@ R1 CONTEM ENDEREÇO DA MENSAGEM
			mov     r2, #1			 	@ R2 CONTEM TAMANHO DA MENSAGEM
			mov     r7, #4      			@ 4 PARA WRITE, 3 PARA READ
			svc     0x055   			@ FUNCAO PARA WRITE, R0 E R7 COFIGURAÇÃO DO SIMULADOR, R1 CONTEM END. DE MSG E R2 O TAMANHO
			
			cmp	r3, #CHAVE_TAMANHO		@ COMPARA SE ATINGIU TAMANHO MAXIMO DA CHAVE
			bne	le_chave_desc			@ CASO NAO TENHA ATINGIDO MANTEM AGUARDANDO MAIS DIGITOS
			
@----------- DESCRIPTOGRAFIA
			
		bloco_descriptografia:	
			@ R3 POSSUI O TAMANHO DA CHAVE DE DESCRIPTOGRAFIA CONFORME BLOCO ANTERIOR
			@ R12 POSSUI O TAMANHO DA MENSAGEM CRIPTOGRAFADA CONFORME ESPECIFICADO ANTERIORMENTE 
			
			mov 	r5, #0 				@ COUNT PARA ANDAR NA CHAVE
			mov	r6, #0				@ COUNT PARA ANDAR NA MENSAGEM
			ldr 	r7, =chave			@ R7 APONTA PARA INICIO DA CHAVE
			ldr	r8, =mensagem			@ R8 APONTA PARA INICIO DA MENSAGEM
			ldr r9, =mensagem_desc
			
		descriptografar:
			ldrb 	r1, [r7, r5]			@ R1 RECEBE BYTE DA POSICAO R7 + R6 DA CHAVE DE DESCPRITOGRAFIA 
			ldrb 	r2, [r8, r6]			@ R2 RECEBE BYTE DA POSICAO R8 + R6 DE MENSAGEM
			sub	r2, r2, r1			@ R2 = R2 - R1 (INVERSO DA CRIPTOGRAFIA)
			strb	r2, [r9, r6]			@ ARMAZENA NA MENSAGEM O RESULTADO DA SUBTRACAO
			
			add	r5, r5, #1			@ PERCORRE CHAVE
			add	r6, r6, #1			@ PERCORRE MENSAGEM
			
			cmp	r5, r3				@ COMPARA SE R5 CHEGOU NO FINAL DA CHAVE
			moveq	r5, #0				@ CASO TENHA CHEGO VOLTA AO INICIO
			
			cmp	r6, r12				@ COMPARA SE R2 CHEGOU NO FINAL DA MENSAGEM
			bne	descriptografar			@ CASO NAO TENHA CHEGO CONTINUA
			
@----------- EXIBE DESCRIPTOGRAFIA
			
			mov	r0, #1				@ 1 PARA WRITE, 0 PARA READ
			ldr     r1, =msg_descriptografada	@ R1 CONTEM ENDEREÇO DA MENSAGEM
			ldr     r2, =len_descriptografada	@ R2 CONTEM TAMANHO DA MENSAGEM
			mov     r7, #4      			@ 4 PARA WRITE, 3 PARA READ
			svc     0x055   			@ FUNCAO PARA WRITE, R0 E R7 COFIGURAÇÃO DO SIMULADOR, R1 CONTEM BUFFER DE MSG E R2 OTAMANHO
		
			mov	r0, #1				@ 1 PARA WRITE, 0 PARA READ
			ldr     r1, =mensagem_desc		@ R1 CONTEM ENDEREÇO DA MENSAGEM
			mov     r2, r12				@ R2 CONTEM TAMANHO DA MENSAGEM
			mov     r7, #4      			@ 4 PARA WRITE, 3 PARA READ
			svc     0x055   			@ FUNCAO PARA WRITE, R0 E R7 COFIGURAÇÃO DO SIMULADOR, R1 CONTEM BUFFER DE MSG E R2 O TAMANHO
			
			b	descriptografia			@ MANTEM EM LOOP ATÉ USUÁRIO DESEJAR SAIR
			
@----------- FIM	

		fim:
			@ MSG FINAL DE EXECUÇÃO
			mov	r0, #1			@ 1 PARA WRITE, 0 PARA READ
			ldr     r1, =msg_fim  	 	@ R1 CONTEM ENDEREÇO DA MENSAGEM
			ldr     r2, =len_msg_fim 	@ R2 CONTEM TAMANHO DA MENSAGEM
			mov     r7, #4      		@ 4 PARA WRITE, 3 PARA READ
			svc     0x055   		@ FUNCAO PARA WRITE, R0 E R7 COFIGURAÇÃO DO SIMULADOR, R1 CONTEM BUFFER DE MSG E R2 O TAMANHO
