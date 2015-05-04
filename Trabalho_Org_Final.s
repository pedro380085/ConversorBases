# Disciplina : Organização de Computadores  
#
# Engenharia da Computação - 4º Semestre
#
# Grupo:
#	Andressa Baptistine Andrião	
#	Laís Pessine do Carmo		
#	Marcelo Montanher 		
#	Sindélio Henrique Lima 		
#	
#

.data
	.align 0
	STRINICIAL: .asciiz "       CONVERSOR DECIMAL -> IEEE754    \n\n" # 32 ou 64 bytes
	STRMENU: .asciiz "\n\nDigite:\n\n0 - Decimal -> IEEE754 precisão simples\n1 - Decimal -> IEEE754 precisão dupla\n2 - Encerrar programa\n\n"
	STRDIGITE: .asciiz "\n\nDigite o número decimal a ser convertido: \n\n"
	STRFIM: .asciiz "\n\nPrograma encerrado.\n"
	STRERRO: .asciiz "\nENTRADA INVÁLIDA !!! TENTE NOVAMENTE.\n\n"
	STRCONVERTIDO: .asciiz "00000000000000000000000000000000" # 32 bytes alocados e 1 para o \0 que vão formar o número binário convertido.
	STRCONVERTIDO64: .asciiz "0000000000000000000000000000000000000000000000000000000000000000" #64 bytes alocados e 1 para o '\0'.
	STRPADRAO754: .asciiz "00000000000000000000000000000000" # 32 bytes alocados e 1 para o \0 que vão formar o número no padrão IEEE754.
	STRPADRAO754_64: .asciiz "0000000000000000000000000000000000000000000000000000000000000000" # 64 bytes alocados e 1 para o \0 que vão formar #o número no padrão IEEE754.
	STRTESTE: .asciiz "TESTE!\n\n"
	BYTESINAL: .byte 48 #configuração inicial é positivo
	BYTEMAIS: .byte 43
	BYTEMENOS: .byte 45
	BYTEZERO: .byte 48
	BYTEUM: .byte 49
	BYTEDOIS: .byte 50 
	BYTEVIRGULA: .byte 44
	BYTEBARRAZERO: .byte 10
	
	.align 2
	FLOATPARTEINTEIRADECIMAL: .float 0.0
	FLOATPARTENAOINTEIRADECIMAL: .float 0.0
	INTNUMBITSPARTEINTEIRA: .word 0
	INTNUMBITSPARTENAOINTEIRA: .word 0
	

.text
	.align 2
	.globl main

main:
	#IMPRIME MENSAGEM INICIAL
	la $a0, STRINICIAL
	li $v0, 4
	syscall 

	#ALOCA MEMÓRIA PARA LER O NÚMERO DIGITADO PELO USUÁRIO
	li $v0, 9   #cód para alocação de memória
	li $a0, 20  #quantidade de bytes alocados (2^31 - 1 = 2147483647, 17 dígitos para o número, 1 dígito para o sinal, 1 para a vírgula e 1 #dígito para "/0")
	syscall 
	
	#$s0 APONTA PARA A MEMÓRIA ALOCADA
	move $s0, $v0 #move o conteúdo de $v0 para $s0

	loop:
		#IMPRIME MENU
		li $v0, 4
		la $a0, STRMENU
		syscall

		#LEITURA DA STRING DIGITADA PELO USUÁRIO
		move $a0, $s0 #$a0 aponta para a memória alocada
		li $a1, 2 #coloca em $a1 o tamanho da string a ser lida, no caso 2 bytes (não esquecer do /0!!!).
        	li $v0, 8 #código para leitura de string
		syscall #leitura da string colocada em $a0

		switch:
			lb $t0, 0($s0)
		
			compara_com_zero:
				lb $t1, BYTEZERO				
				bne $t0, $t1, compara_com_um
					move $a0, $s0
					jal conversao_simples
					j loop
			fim_compara_com_zero:
			
			compara_com_um:
				lb $t1, BYTEUM
				bne $t0, $t1, compara_com_dois
					move $a0, $s0
					jal conversao_dupla
					j loop
			fim_compara_com_um:
			
			compara_com_dois:
				lb $t1, BYTEDOIS				
				bne $t0, $t1, msg_erro
					li $v0, 4
					la $a0, STRFIM
					syscall
					li $v0, 10
					syscall
			fim_compara_com_dois:

		fim_switch:

		msg_erro:
			li $v0, 4
			la $a0, STRERRO
			syscall
			j loop
		fim_msg_erro:

	fim_loop:

fim_main:

conversao_simples:
	#$t0 é um ponteiro para a memória alocada
	#$t1 é o 1º byte digitado pelo usuário
	#$t2 é um auxiliar para comparação
	#$t3 é um auxiliar de atribuição 
 
	move $t0, $a0 #$a0 é o argumento da função que contém a referência da memória alocada
	
	#IMPRIME MENSAGEM PARA DIGITAÇÃO DO NÚMERO A SER CONVERTIDO
	li $v0, 4
	la $a0, STRDIGITE
	syscall
			
	#LÊ NÚMERO DIGITADO PELO USUÁRIO
	move $a0, $t0 #não esquecer que $t0 contém o endereço da memória alocada
	li $a1, 32 #mínimo deve ser 20, para o maior caso de teste
	li $v0, 8
	syscall

	#IMPORTANTE !!! $t0 CONTÉM O ENDEREÇO DO NÚMERO DIGITADO PELO USUÁRIO
		
	sinal:
		lb $t1, 0($t0)

		compara_com_mais:
			lb $t2, BYTEMAIS
			bne $t1, $t2, compara_com_menos
				li $t3, 48
				sb $t3, BYTESINAL
				j fim_sinal
		fim_compara_com_mais:

		compara_com_menos:
			lb $t2, BYTEMENOS
			bne $t1, $t2, msg_erro2
				li $t3, 49
				sb $t3, BYTESINAL			
				j fim_sinal
		fim_compara_com_menos:

		msg_erro2:
			li $v0, 4
			la $a0, STRERRO
			syscall
			jr $ra
		fim_msg_erro2:
	
	fim_sinal:

	converte_string_para_decimal:
		parte_inteira:
			addi $t0, $t0, 1
			move $t1, $zero
			move $t2, $zero
			move $t3, $t0
			lb $t4, BYTEVIRGULA
			lb $t5, BYTEBARRAZERO
			lb $t6, 0($t3)

			compara_com_virgula:
				bne $t6, $t4, fim_compara_com_virgula
					li $v0, 4
					la $a0, STRERRO
					syscall
					jr $ra
			fim_compara_com_virgula:

			compara_com_barrazero:
				bne $t6, $t5, fim_compara_com_barrazero
					li $v0, 4
					la $a0, STRERRO
					syscall
					jr $ra
			fim_compara_com_barrazero:

			valida_numero:	
				li $t7, 48		
				blt $t6, $t7, numero_invalido
					li $t7, 57
					bgt $t6, $t7, numero_invalido
						j fim_valida_numero #numero validado

				numero_invalido: 
					li $v0, 4
					la $a0, STRERRO
					syscall 
					jr $ra
				fim_numero_invalido:

			fim_valida_numero:			

			addi $t6, $t6, -48
			sb $t6, 0($t3)	
			addi $t3, $t3, 1
			addi $t1, $t1, 1

			enquanto_nao_virgula:
				lb $t6, 0($t3)
				
				compara_com_virgula2:
					bne $t6, $t4, fim_compara_com_virgula2
						addi $t3, $t3, 1
						j parte_nao_inteira
				fim_compara_com_virgula2:			
				
				compara_com_barrazero2:
					bne $t6, $t5, fim_compara_com_barrazero2
						j coloca_decimal_num_registrador			
				fim_compara_com_barrazero2:

				valida_numero2:	
					li $t7, 48		
					blt $t6, $t7, numero_invalido2
						li $t7, 57
						bgt $t6, $t7, numero_invalido2
							j fim_valida_numero2 #numero validado
	
					numero_invalido2: 
						li $v0, 4
						la $a0, STRERRO
						syscall 
						jr $ra
					fim_numero_invalido2:

				fim_valida_numero2:			


				addi $t6, $t6, -48
				sb $t6, 0($t3)
				addi $t3, $t3, 1
				addi $t1, $t1, 1
				j enquanto_nao_virgula
			fim_enquanto_nao_virgula:			
						
		fim_parte_inteira:			

		parte_nao_inteira:
			
			lb $t6, 0($t3)
		
			compara_com_barrazero3:
				bne $t6, $t5, fim_compara_com_barrazero3
					li $v0, 4
					la $a0, STRERRO
					syscall
					jr $ra
			fim_compara_com_barrazero3:
		
			compara_com_virgula3:
				bne $t6, $t4, fim_compara_com_virgula3
					li $v0, 4
					la $a0, STRERRO
					syscall
					jr $ra
			fim_compara_com_virgula3:

			valida_numero3:	
				li $t7, 48		
				blt $t6, $t7, numero_invalido3
					li $t7, 57
					bgt $t6, $t7, numero_invalido3
						j fim_valida_numero3 #numero validado

				numero_invalido3: 
					li $v0, 4
					la $a0, STRERRO
					syscall 
					jr $ra
				fim_numero_invalido3:

			fim_valida_numero3:			
			
			
			addi $t6, $t6, -48
			sb $t6, 0($t3)
			addi $t3, $t3, 1
			addi $t2, $t2, 1		

			enquanto_nao_barrazero:
				lb $t6, 0($t3)
				
				compara_com_virgula4:
					bne $t6, $t4, fim_compara_com_virgula4
						li $v0, 4
						la $a0, STRERRO
						syscall
						jr $ra
				fim_compara_com_virgula4:			
				
				compara_com_barrazero4:
					bne $t6, $t5, fim_compara_com_barrazero4
						j coloca_decimal_num_registrador			
				fim_compara_com_barrazero4:

				valida_numero4:	
					li $t7, 48		
					blt $t6, $t7, numero_invalido4
						li $t7, 57
						bgt $t6, $t7, numero_invalido4
							j fim_valida_numero4 #numero validado

					numero_invalido4: 
						li $v0, 4
						la $a0, STRERRO
						syscall 
						jr $ra
					fim_numero_invalido4:

				fim_valida_numero4:			


				addi $t6, $t6, -48
				sb $t6, 0($t3)
				addi $t3, $t3, 1
				addi $t2, $t2, 1
				j enquanto_nao_barrazero
			fim_enquanto_nao_barrazero:			
		
		fim_parte_nao_inteira:

	fim_converte_string_para_decimal:
	
	coloca_decimal_num_registrador:
		#backup dos números de dígitos da parte inteira e da parte não inteira
		move $s3, $t1
		move $s4, $t2		
				
		move $t3, $t0 #ponteiro auxiliar
		move $s1, $zero #registrador com a parte inteira do número		
		addi $t1, $t1, -1 #grandeza do dígito			
		
		
		numero_inteiro:
			beq $t1, $zero, adicionando_digito_unidades
				move $t4, $t1 #grandeza auxiliar
				lb $t5, 0($t3)
				
				enquanto_grandeza_maior_que_zero:
					beq $t4, $zero, fim_enquanto_grandeza_maior_que_zero
						mulo $t5, $t5, 10
						addi $t4, $t4, -1
						j enquanto_grandeza_maior_que_zero
				fim_enquanto_grandeza_maior_que_zero:
				
				add $s1, $s1, $t5
				addi $t1, $t1, -1
				addi $t3, $t3, 1
				j numero_inteiro

			adicionando_digito_unidades:
				lb $t5, 0($t3)
				add $s1, $s1, $t5 #adicionando dígito das unidades				
				
		fim_numero_inteiro:

		numero_nao_inteiro:

			move $t3, $t0
			add $t3, $t3, $s3
			addi $t3, $t3, 1
			move $s2, $zero #$s2 = parte não-inteira do número 
			addi $t2, $t2, -1
			
			enquanto_multiplica_por_dez:
				beq $t2, $zero, fim_enquanto_multiplica_por_dez 
					move $t4, $t2
					lb $t5, 0($t3)

					enquanto_existem_multiplicacoes:
						beq $t4, $zero, fim_enquanto_existem_multiplicacoes 
							mulo $t5, $t5, 10
							addi $t4, $t4, -1
							j enquanto_existem_multiplicacoes
					fim_enquanto_existem_multiplicacoes:
				
					add $s2, $s2, $t5
					addi $t2, $t2, -1
					addi $t3, $t3, 1
					j enquanto_multiplica_por_dez	
			fim_enquanto_multiplica_por_dez:
				
			lb $t5, 0($t3)
			add $s2, $s2, $t5

		fim_numero_nao_inteiro:		
		
	fim_coloca_decimal_num_registrador:
	
	cria_sequencia_binaria:
			
		#Salva as partes inteira e fracionária do número
		la $t0, FLOATPARTEINTEIRADECIMAL
		sw $s1, 0($t0)

		la $t0, FLOATPARTENAOINTEIRADECIMAL
		sw $s2, 0($t0)

		sequencia_binaria_parte_inteira:
			
			la $t0, STRCONVERTIDO
			move $t1, $zero #quantidade de bits da parte inteira
			li $t2, 2
			li $t3, 31
			
			enquanto_quociente_diferente_de_zero:
				beq $t1, $t3, fim_sequencia_binaria_parte_nao_inteira
					beq $s1, $zero, fim_enquanto_quociente_diferente_de_zero
 						rem $t4, $s1, $t2
						addi $t4, $t4, 48
						sb $t4, 0($t0)
						div $s1, $s1, 2
						addi $t0, $t0, 1
						addi $t1, $t1, 1
						j enquanto_quociente_diferente_de_zero			
			fim_enquanto_quociente_diferente_de_zero:
			
			#Salva o número de bits da parte inteira
			la $t0, INTNUMBITSPARTEINTEIRA
			sw $t1, 0($t0)

			desinverte_sequencia_binaria:

				move $t0, $t1
				ble $t0, 1, fim_enquanto_inversao
					la $t1, STRCONVERTIDO
					la $t2, STRCONVERTIDO
					add $t2, $t2, $t0
					addi $t2, $t2, -1
					enquanto_inversao:
						bge $t1, $t2, fim_enquanto_inversao
							lb $t3, 0($t1)
							lb $t4, 0($t2)
							sb $t4, 0($t1)
							sb $t3, 0($t2)
							addi $t1, $t1, 1
							addi $t2, $t2, -1
							j enquanto_inversao
					fim_enquanto_inversao:

			fim_desinverte_sequencia_binaria:
						
		fim_sequencia_binaria_parte_inteira:
		
		sequencia_binaria_parte_nao_inteira:		
			
			la $t1, STRCONVERTIDO
			add $t1, $t1, $t0
			move $t2, $s4 #$t2 = quantidade de dígitos da parte não_inteira
			li $t3, 1			

			enquanto_numero_digitos_nao_zerar:
				beq $t2, $zero, fim_enquanto_numero_digitos_nao_zerar
					mulo $t3, $t3, 10
					addi $t2, $t2, -1
					j enquanto_numero_digitos_nao_zerar
			fim_enquanto_numero_digitos_nao_zerar:
			
			li $t4, 32
			move $t2, $t0			

			enquanto_multiplica_por_dois:
				beq $t2, $t4, fim_sequencia_binaria_parte_nao_inteira		
					beq $s2, $zero, fim_sequencia_binaria_parte_nao_inteira
						mulo $s2, $s2, 2
						sle $t5, $t3, $s2
						beqz $t5, salva_byte
							sub $s2, $s2, $t3
						salva_byte:
							addi $t5, $t5, 48
							sb $t5, 0($t1)
							addi $t1, $t1, 1
							addi $t2, $t2, 1
							j enquanto_multiplica_por_dois
			fim_enquanto_multiplica_por_dois:
	
		fim_sequencia_binaria_parte_nao_inteira:
		
		#Salva a quantidade de bits da parte não-inteira	
		la $t0, INTNUMBITSPARTENAOINTEIRA
		sw $t2, 0($t0) 

	fim_sequencia_binaria:
	
	#impressão teste
	#li $v0, 4
	#la $a0, STRCONVERTIDO
	#syscall

	#impressão teste
	#li $v0, 1
	#la $a0, INTPARTEINTEIRADECIMAL
	#lw $a0, 0($a0)
	#syscall
	
	#impressão teste
	#li $v0, 1
	#la $a0, INTPARTENAOINTEIRADECIMAL
	#lw $a0, 0($a0)
	#syscall

	#impressão teste
	#li $v0, 1
	#la $a0, INTNUMBITSPARTEINTEIRA
	#lw $a0, 0($a0)
	#syscall

	#impressão teste
	#li $v0, 1
	#la $a0, INTNUMBITSPARTENAOINTEIRA
	#lw $a0, 0($a0)
	#syscall

	converte_de_binario_para_padrao_IEEE754:

		sinal_padrao754:
			la $t0, STRPADRAO754
			lb $t1, BYTESINAL
			sb $t1, 0($t0) #salva o byte de sinal
			addi $t0, $t0, 1 #anda o ponteiro
		fim_sinal_padrao754:	
		
		#verifica se a parte inteira do número é maior ou igual a 1
		lw $t1, FLOATPARTEINTEIRADECIMAL
		li $t2, 1
		blt $t1, $t2, parte_inteira_menor_que_um

			parte_inteira_maior_igual_que_um:
				lw $t4, INTNUMBITSPARTEINTEIRA
				li $t3, -1
				add $t3, $t3, $t4 #$t3 é o expoente
				addi $t3, $t3, 127 #deslocamento
				
				converte_expoente_para_binario:
					li $t2, 2 #auxiliar de divisão
					
					enquanto_quociente_do_expoente_nao_nulo:
						beq $t3, $zero, fim_enquanto_quociente_do_expoente_nao_nulo						
							rem $t4, $t3, $t2
							addi $t4, $t4, 48
							sb $t4, 0($t0)
							addi $t0, $t0, 1
							div $t3, $t3, $t2
							j enquanto_quociente_do_expoente_nao_nulo 
					fim_enquanto_quociente_do_expoente_nao_nulo:
						
					desinverte_expoente_padrao754:
						la $t1, STRPADRAO754
						addi $t1, $t1, 1 
						addi $t0, $t0, -1 #$t0 aponta para o fim do expoente binário invertido, $t1 para o começo
											
						enquanto_nao_terminar_desinversao:
							bge $t1, $t0, fim_enquanto_nao_terminar_desinversao			
								lb $t3, 0($t1)
								lb $t4, 0($t0)
								sb $t4, 0($t1)
								sb $t3, 0($t0)
								addi $t0, $t0, -1
								addi $t1, $t1, 1
								j enquanto_nao_terminar_desinversao
						fim_enquanto_nao_terminar_desinversao:
											
					fim_desinverte_expoente_padrao754:	

					#Obs.: Não é tratado overflow(expoente>255) e underflow.		
		
				fim_converte_expoente_para_binario:

				#calcula posição inicial da mantissa
				li $t1, 9
				la $t0, STRPADRAO754
				add $t0, $t0, $t1 #$t0 aponta para o início da mantissa no padrão

				#inicializações
				la $t1, STRCONVERTIDO
				addi $t1, $t1, 1 #sempre é 1 no início do convertido se a parte inteira for maior que 1
				li $t2, 1 #conta ateh 24
				li $t3, 24

				enquanto_nao_terminar_mantissa_padrao754:
					beq $t2, $t3, fim_enquanto_nao_terminar_mantissa_padrao754
						lb $t4, 0($t1)
						sb $t4, 0($t0)
						addi $t0, $t0, 1
						addi $t1, $t1, 1
						addi $t2, $t2, 1
						j enquanto_nao_terminar_mantissa_padrao754
				fim_enquanto_nao_terminar_mantissa_padrao754:

			fim_parte_inteira_maior_igual_que_um:

			#teste
			#li $v0, 4
			#la $a0, STRPADRAO754
			#syscall

			parte_inteira_menor_que_um:
			
				la $t0, STRCONVERTIDO
				lb $t1, 0($t0)
				li $t2, 49
				li $t3, -1 # inicialização do expoente
			
				#determina expoente
				enquanto_nao_achar_primeiro_1:
					beq $t1, $t2, fim_enquanto_nao_achar_primeiro_1
						addi $t0, $t0, 1
						lb $t1, 0($t0)	
						addi $t3, $t3, -1								
						j enquanto_nao_achar_primeiro_1
				fim_enquanto_nao_achar_primeiro_1:
			

				addi $t3, $t3, 127 #deslocamento
				addi $t7, $t0, 1 #posição inicial da mantissa
			
				converte_expoente_para_binario2:
				li $t2, 2 #auxiliar de divisão
					la $t0, STRPADRAO754
					addi $t0, $t0, 1
				
					enquanto_quociente_do_expoente_nao_nulo2:
						beq $t3, $zero, fim_enquanto_quociente_do_expoente_nao_nulo2						
							rem $t4, $t3, $t2
							addi $t4, $t4, 48
							sb $t4, 0($t0)
							addi $t0, $t0, 1
							div $t3, $t3, $t2
							j enquanto_quociente_do_expoente_nao_nulo2 
					fim_enquanto_quociente_do_expoente_nao_nulo2:
								
					desinverte_expoente_padrao754_2:
						la $t1, STRPADRAO754
						addi $t1, $t1, 1 
						#$t0 aponta para o fim do expoente binário invertido, $t1 para o começo
											
						enquanto_nao_terminar_desinversao2:
							bge $t1, $t0, fim_enquanto_nao_terminar_desinversao2			
								lb $t3, 0($t1)
								lb $t4, 0($t0)
								sb $t4, 0($t1)
								sb $t3, 0($t0)
								addi $t0, $t0, -1
								addi $t1, $t1, 1
								j enquanto_nao_terminar_desinversao2
						fim_enquanto_nao_terminar_desinversao2:				
											
					fim_desinverte_expoente_padrao754_2:	

					#Obs.: Não é tratado overflow(expoente>255) e underflow.		
	
				fim_converte_expoente_para_binario2:

				#calcula posição inicial da mantissa
				li $t1, 9
				la $t0, STRPADRAO754
				add $t0, $t0, $t1 #$t0 aponta para o início da mantissa no padrão

				#inicializações
				move $t1, $t7 #posição inicial da mantissa da STRCONVERTIDO
				li $t2, 1 #conta ateh 24
				li $t3, 24

				enquanto_nao_terminar_mantissa_padrao754_2:
					beq $t2, $t3, fim_enquanto_nao_terminar_mantissa_padrao754_2
						lb $t4, 0($t1)
						sb $t4, 0($t0)
						addi $t0, $t0, 1
						addi $t1, $t1, 1
						addi $t2, $t2, 1
						j enquanto_nao_terminar_mantissa_padrao754_2
				fim_enquanto_nao_terminar_mantissa_padrao754_2:
			
			fim_parte_inteira_menor_que_um:

	fim_converte_de_binario_para_padrao_IEEE754:

	#imprime no padrão IEEE754
	li $v0, 4
	la $a0, STRPADRAO754
	syscall										
	
	jr $ra

fim_conversao_simples:

conversao_dupla:
	
	#$t0 é um ponteiro para a memória alocada
	#$t1 é o 1º byte digitado pelo usuário
	#$t2 é um auxiliar para comparação
	#$t3 é um auxiliar de atribuição 
 
	move $t0, $a0 #$a0 é o argumento da função que contém a referência da memória alocada
	
	#IMPRIME MENSAGEM PARA DIGITAÇÃO DO NÚMERO A SER CONVERTIDO
	li $v0, 4
	la $a0, STRDIGITE
	syscall
			
	#LÊ NÚMERO DIGITADO PELO USUÁRIO
	move $a0, $t0 #não esquecer que $t0 contém o endereço da memória alocada
	li $a1, 21 #mín 20 para o maior caso de teste
	li $v0, 8
	syscall

	#IMPORTANTE !!! $t0 CONTÉM O ENDEREÇO DO NÚMERO DIGITADO PELO USUÁRIO
		
	sinal_64:
		lb $t1, 0($t0)

		compara_com_mais_64:
			lb $t2, BYTEMAIS
			bne $t1, $t2, compara_com_menos_64
				li $t3, 48
				sb $t3, BYTESINAL
				j fim_sinal_64
		fim_compara_com_mais_64:

		compara_com_menos_64:
			lb $t2, BYTEMENOS
			bne $t1, $t2, msg_erro2_64
				li $t3, 49
				sb $t3, BYTESINAL			
				j fim_sinal_64
		fim_compara_com_menos_64:

		msg_erro2_64:
			li $v0, 4
			la $a0, STRERRO
			syscall
			jr $ra
		fim_msg_erro2_64:
	
	fim_sinal_64:

	converte_string_para_decimal_64:
		parte_inteira_64:
			addi $t0, $t0, 1
			move $t1, $zero
			move $t2, $zero
			move $t3, $t0
			lb $t4, BYTEVIRGULA
			lb $t5, BYTEBARRAZERO
			lb $t6, 0($t3)

			compara_com_virgula_64:
				bne $t6, $t4, fim_compara_com_virgula_64
					li $v0, 4
					la $a0, STRERRO
					syscall
					jr $ra
			fim_compara_com_virgula_64:

			compara_com_barrazero_64:
				bne $t6, $t5, fim_compara_com_barrazero_64
					li $v0, 4
					la $a0, STRERRO
					syscall
					jr $ra
			fim_compara_com_barrazero_64:

			valida_numero_64:	
				li $t7, 48		
				blt $t6, $t7, numero_invalido_64
					li $t7, 57
					bgt $t6, $t7, numero_invalido_64
						j fim_valida_numero_64 #numero validado

				numero_invalido_64: 
					li $v0, 4
					la $a0, STRERRO
					syscall 
					jr $ra
				fim_numero_invalido_64:

			fim_valida_numero_64:			

			addi $t6, $t6, -48
			sb $t6, 0($t3)	
			addi $t3, $t3, 1
			addi $t1, $t1, 1

			enquanto_nao_virgula_64:
				lb $t6, 0($t3)
				
				compara_com_virgula2_64:
					bne $t6, $t4, fim_compara_com_virgula2_64
						addi $t3, $t3, 1
						j parte_nao_inteira_64
				fim_compara_com_virgula2_64:			
				
				compara_com_barrazero2_64:
					bne $t6, $t5, fim_compara_com_barrazero2_64
						j coloca_decimal_num_registrador_64			
				fim_compara_com_barrazero2_64:

				valida_numero2_64:	
					li $t7, 48		
					blt $t6, $t7, numero_invalido2_64
						li $t7, 57
						bgt $t6, $t7, numero_invalido2_64
							j fim_valida_numero2_64 #numero validado
	
					numero_invalido2_64: 
						li $v0, 4
						la $a0, STRERRO
						syscall 
						jr $ra
					fim_numero_invalido2_64:

				fim_valida_numero2_64:			

				addi $t6, $t6, -48
				sb $t6, 0($t3)
				addi $t3, $t3, 1
				addi $t1, $t1, 1
				j enquanto_nao_virgula_64
			fim_enquanto_nao_virgula_64:			
						
		fim_parte_inteira_64:			

		parte_nao_inteira_64:
			
			lb $t6, 0($t3)
		
			compara_com_barrazero3_64:
				bne $t6, $t5, fim_compara_com_barrazero3_64
					li $v0, 4
					la $a0, STRERRO
					syscall
					jr $ra
			fim_compara_com_barrazero3_64:
		
			compara_com_virgula3_64:
				bne $t6, $t4, fim_compara_com_virgula3_64
					li $v0, 4
					la $a0, STRERRO
					syscall
					jr $ra
			fim_compara_com_virgula3_64:

			valida_numero3_64:	
				li $t7, 48		
				blt $t6, $t7, numero_invalido3_64
					li $t7, 57
					bgt $t6, $t7, numero_invalido3_64
						j fim_valida_numero3_64 #numero validado

				numero_invalido3_64: 
					li $v0, 4
					la $a0, STRERRO
					syscall 
					jr $ra
				fim_numero_invalido3_64:

			fim_valida_numero3_64:			
						
			addi $t6, $t6, -48
			sb $t6, 0($t3)
			addi $t3, $t3, 1
			addi $t2, $t2, 1		

			enquanto_nao_barrazero_64:
				lb $t6, 0($t3)
				
				compara_com_virgula4_64:
					bne $t6, $t4, fim_compara_com_virgula4_64
						li $v0, 4
						la $a0, STRERRO
						syscall
						jr $ra
				fim_compara_com_virgula4_64:			
				
				compara_com_barrazero4_64:
					bne $t6, $t5, fim_compara_com_barrazero4_64
						j coloca_decimal_num_registrador_64
				fim_compara_com_barrazero4_64:

				valida_numero4_64:	
					li $t7, 48		
					blt $t6, $t7, numero_invalido4_64
						li $t7, 57
						bgt $t6, $t7, numero_invalido4_64
							j fim_valida_numero4_64 #numero validado

					numero_invalido4_64: 
						li $v0, 4
						la $a0, STRERRO
						syscall 
						jr $ra
					fim_numero_invalido4_64:

				fim_valida_numero4_64:			


				addi $t6, $t6, -48
				sb $t6, 0($t3)
				addi $t3, $t3, 1
				addi $t2, $t2, 1
				j enquanto_nao_barrazero_64
			fim_enquanto_nao_barrazero_64:			
		
		fim_parte_nao_inteira_64:

	fim_converte_string_para_decimal_64:

	coloca_decimal_num_registrador_64:
		#backup dos números de dígitos da parte inteira e da parte não inteira
		move $s3, $t1
		move $s4, $t2		
				
		move $t3, $t0 #ponteiro auxiliar
		move $s1, $zero #registrador com a parte inteira do número		
		addi $t1, $t1, -1 #grandeza do dígito	

		numero_inteiro_64:
			beq $t1, $zero, adicionando_digito_unidades_64
				move $t4, $t1 #grandeza auxiliar
				lb $t5, 0($t3)
				
				enquanto_grandeza_maior_que_zero_64:
					beq $t4, $zero, fim_enquanto_grandeza_maior_que_zero_64
						mulo $t5, $t5, 10
						addi $t4, $t4, -1
						j enquanto_grandeza_maior_que_zero_64
				fim_enquanto_grandeza_maior_que_zero_64:
				
				add $s1, $s1, $t5
				addi $t1, $t1, -1
				addi $t3, $t3, 1
				j numero_inteiro_64

			adicionando_digito_unidades_64:
				lb $t5, 0($t3)
				add $s1, $s1, $t5 #adicionando dígito das unidades	
				
		fim_numero_inteiro_64:

		

		numero_nao_inteiro_64:

			move $t3, $t0
			add $t3, $t3, $s3
			addi $t3, $t3, 1
			move $s2, $zero #$s2 = parte não-inteira do número 
			addi $t2, $t2, -1
			
			enquanto_multiplica_por_dez_64:
				beq $t2, $zero, fim_enquanto_multiplica_por_dez_64 
					move $t4, $t2
					lb $t5, 0($t3)

					enquanto_existem_multiplicacoes_64:
						beq $t4, $zero, fim_enquanto_existem_multiplicacoes_64
							mulo $t5, $t5, 10
							addi $t4, $t4, -1
							j enquanto_existem_multiplicacoes_64
					fim_enquanto_existem_multiplicacoes_64:
				
					add $s2, $s2, $t5
					addi $t2, $t2, -1
					addi $t3, $t3, 1
					j enquanto_multiplica_por_dez_64	
			fim_enquanto_multiplica_por_dez_64:
				
			lb $t5, 0($t3)
			add $s2, $s2, $t5

		fim_numero_nao_inteiro_64:		
		
	fim_coloca_decimal_num_registrador_64:
	
	cria_sequencia_binaria_64:
			
		#Salva as partes inteira e fracionária do número
		la $t0, FLOATPARTEINTEIRADECIMAL
		sw $s1, 0($t0)

		la $t0, FLOATPARTENAOINTEIRADECIMAL
		sw $s2, 0($t0)

		sequencia_binaria_parte_inteira_64:
			
			la $t0, STRCONVERTIDO64
			move $t1, $zero #quantidade de bits da parte inteira
			li $t2, 2
			li $t3, 63
			
			enquanto_quociente_diferente_de_zero_64:
				beq $t1, $t3, fim_sequencia_binaria_parte_nao_inteira_64
					beq $s1, $zero, fim_enquanto_quociente_diferente_de_zero_64
 						rem $t4, $s1, $t2
						addi $t4, $t4, 48
						sb $t4, 0($t0)
						div $s1, $s1, 2
						addi $t0, $t0, 1
						addi $t1, $t1, 1
						j enquanto_quociente_diferente_de_zero_64			
			fim_enquanto_quociente_diferente_de_zero_64:
			
			#Salva o número de bits da parte inteira
			la $t0, INTNUMBITSPARTEINTEIRA
			sw $t1, 0($t0)

			desinverte_sequencia_binaria_64:

				move $t0, $t1
				ble $t0, 1, fim_enquanto_inversao_64
					la $t1, STRCONVERTIDO64
					la $t2, STRCONVERTIDO64
					add $t2, $t2, $t0
					addi $t2, $t2, -1
					enquanto_inversao_64:
						bge $t1, $t2, fim_enquanto_inversao_64
							lb $t3, 0($t1)
							lb $t4, 0($t2)
							sb $t4, 0($t1)
							sb $t3, 0($t2)
							addi $t1, $t1, 1
							addi $t2, $t2, -1
							j enquanto_inversao_64
					fim_enquanto_inversao_64:

			fim_desinverte_sequencia_binaria_64:
						
		fim_sequencia_binaria_parte_inteira_64:
		
		sequencia_binaria_parte_nao_inteira_64:		
			
			la $t1, STRCONVERTIDO64
			add $t1, $t1, $t0
			move $t2, $s4 #$t2 = quantidade de dígitos da parte não_inteira
			li $t3, 1			

			enquanto_numero_digitos_nao_zerar_64:
				beq $t2, $zero, fim_enquanto_numero_digitos_nao_zerar_64
					mulo $t3, $t3, 10
					addi $t2, $t2, -1
					j enquanto_numero_digitos_nao_zerar_64
			fim_enquanto_numero_digitos_nao_zerar_64:
			
			li $t4, 63
			move $t2, $t0			

			enquanto_multiplica_por_dois_64:
				beq $t2, $t4, fim_sequencia_binaria_parte_nao_inteira_64		
					beq $s2, $zero, fim_sequencia_binaria_parte_nao_inteira_64
						mulo $s2, $s2, 2
						sle $t5, $t3, $s2
						beqz $t5, salva_byte_64
							sub $s2, $s2, $t3
						salva_byte_64:
							addi $t5, $t5, 48
							sb $t5, 0($t1)
							addi $t1, $t1, 1
							addi $t2, $t2, 1
							j enquanto_multiplica_por_dois_64
			fim_enquanto_multiplica_por_dois_64:
	
		fim_sequencia_binaria_parte_nao_inteira_64:
		
		#Salva a quantidade de bits da parte não-inteira	
		la $t0, INTNUMBITSPARTENAOINTEIRA
		sw $t2, 0($t0) 

	fim_sequencia_binaria_64:
	
	converte_de_binario_para_padrao_IEEE754_64:

		sinal_padrao754_64:
			la $t0, STRPADRAO754_64
			lb $t1, BYTESINAL
			sb $t1, 0($t0) #salva o byte de sinal
			addi $t0, $t0, 1 #anda o ponteiro
		fim_sinal_padrao754_64:	
		
		#verifica se a parte inteira do número é maior ou igual a 1
		lw $t1, FLOATPARTEINTEIRADECIMAL
		li $t2, 1
		blt $t1, $t2, parte_inteira_menor_que_um_64

			parte_inteira_maior_igual_que_um_64:
				lw $t4, INTNUMBITSPARTEINTEIRA
				li $t3, -1
				add $t3, $t3, $t4 #$t3 é o expoente
				addi $t3, $t3, 127 #deslocamento
				
				converte_expoente_para_binario_64:
					li $t2, 2 #auxiliar de divisão
					
					enquanto_quociente_do_expoente_nao_nulo_64:
						beq $t3, $zero, fim_enquanto_quociente_do_expoente_nao_nulo_64						
							rem $t4, $t3, $t2
							addi $t4, $t4, 48
							sb $t4, 0($t0)
							addi $t0, $t0, 1
							div $t3, $t3, $t2
							j enquanto_quociente_do_expoente_nao_nulo_64 
					fim_enquanto_quociente_do_expoente_nao_nulo_64:
						
					desinverte_expoente_padrao754_64:
						la $t1, STRPADRAO754_64
						addi $t1, $t1, 1 
						addi $t0, $t0, -1 #$t0 aponta para o fim do expoente binário invertido, $t1 para o começo
											
						enquanto_nao_terminar_desinversao_64:
							bge $t1, $t0, fim_enquanto_nao_terminar_desinversao_64			
								lb $t3, 0($t1)
								lb $t4, 0($t0)
								sb $t4, 0($t1)
								sb $t3, 0($t0)
								addi $t0, $t0, -1
								addi $t1, $t1, 1
								j enquanto_nao_terminar_desinversao_64
						fim_enquanto_nao_terminar_desinversao_64:
											
					fim_desinverte_expoente_padrao754_64:	

					#Obs.: Não é tratado overflow(expoente>255) e underflow.		
		
				fim_converte_expoente_para_binario_64:

				#calcula posição inicial da mantissa
				li $t1, 9
				la $t0, STRPADRAO754_64
				add $t0, $t0, $t1 #$t0 aponta para o início da mantissa no padrão

				#inicializações
				la $t1, STRCONVERTIDO64
				addi $t1, $t1, 1 #sempre é 1 no início do convertido se a parte inteira for maior que 1
				li $t2, 1 #conta ateh 24
				li $t3, 24

				enquanto_nao_terminar_mantissa_padrao754_64:
					beq $t2, $t3, fim_enquanto_nao_terminar_mantissa_padrao754_64
						lb $t4, 0($t1)
						sb $t4, 0($t0)
						addi $t0, $t0, 1
						addi $t1, $t1, 1
						addi $t2, $t2, 1
						j enquanto_nao_terminar_mantissa_padrao754_64
				fim_enquanto_nao_terminar_mantissa_padrao754_64:

			fim_parte_inteira_maior_igual_que_um_64:

			parte_inteira_menor_que_um_64:
			
				la $t0, STRCONVERTIDO64
				lb $t1, 0($t0)
				li $t2, 49
				li $t3, -1 # inicialização do expoente
			
				#determina expoente
				enquanto_nao_achar_primeiro_1_64:
					beq $t1, $t2, fim_enquanto_nao_achar_primeiro_1_64
						addi $t0, $t0, 1
						lb $t1, 0($t0)	
						addi $t3, $t3, -1								
						j enquanto_nao_achar_primeiro_1_64
				fim_enquanto_nao_achar_primeiro_1_64:
			

				addi $t3, $t3, 127 #deslocamento
				addi $t7, $t0, 1 #posição inicial da mantissa
			
				converte_expoente_para_binario2_64:
				li $t2, 2 #auxiliar de divisão
					la $t0, STRPADRAO754_64
					addi $t0, $t0, 1
				
					enquanto_quociente_do_expoente_nao_nulo2_64:
						beq $t3, $zero, fim_enquanto_quociente_do_expoente_nao_nulo2_64						
							rem $t4, $t3, $t2
							addi $t4, $t4, 48
							sb $t4, 0($t0)
							addi $t0, $t0, 1
							div $t3, $t3, $t2
							j enquanto_quociente_do_expoente_nao_nulo2_64 
					fim_enquanto_quociente_do_expoente_nao_nulo2_64:
								
					desinverte_expoente_padrao754_2_64:
						la $t1, STRPADRAO754_64
						addi $t1, $t1, 1 
						#$t0 aponta para o fim do expoente binário invertido, $t1 para o começo
											
						enquanto_nao_terminar_desinversao2_64:
							bge $t1, $t0, fim_enquanto_nao_terminar_desinversao2_64			
								lb $t3, 0($t1)
								lb $t4, 0($t0)
								sb $t4, 0($t1)
								sb $t3, 0($t0)
								addi $t0, $t0, -1
								addi $t1, $t1, 1
								j enquanto_nao_terminar_desinversao2_64
						fim_enquanto_nao_terminar_desinversao2_64:				
											
					fim_desinverte_expoente_padrao754_2_64:	

					#Obs.: Não é tratado overflow(expoente>255) e underflow.		
	
				fim_converte_expoente_para_binario2_64:

				#calcula posição inicial da mantissa
				li $t1, 9
				la $t0, STRPADRAO754_64
				add $t0, $t0, $t1 #$t0 aponta para o início da mantissa no padrão

				#inicializações
				move $t1, $t7 #posição inicial da mantissa da STRCONVERTIDO64
				li $t2, 1 #conta ateh 24
				li $t3, 24

				enquanto_nao_terminar_mantissa_padrao754_2_64:
					beq $t2, $t3, fim_enquanto_nao_terminar_mantissa_padrao754_2_64
						lb $t4, 0($t1)
						sb $t4, 0($t0)
						addi $t0, $t0, 1
						addi $t1, $t1, 1
						addi $t2, $t2, 1
						j enquanto_nao_terminar_mantissa_padrao754_2_64
				fim_enquanto_nao_terminar_mantissa_padrao754_2_64:
			
			fim_parte_inteira_menor_que_um_64:

	fim_converte_de_binario_para_padrao_IEEE754_64:

	#imprime no padrão IEEE754
	li $v0, 4
	la $a0, STRPADRAO754_64
	syscall										
	
	jr $ra

fim_conversao_dupla: