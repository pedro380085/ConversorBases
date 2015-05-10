.data
	.align 0
	STR_TITULO: .asciiz "Conversor de Bases\n\n"
	STR_INSIRA_BASE_INICIAL: .asciiz "Qual eh a base do numero a ser inserido? (B)Binario (O)Octal (D)Decimal (H)Hexadecimal\n"
	STR_INSIRA_NUMERO: .asciiz "\nInsira numero a ser convertido:\n"
	STR_INSIRA_BASE_FINAL: .asciiz "O numero deve ser convertido para qual base? (B)Binario (O)Octal (D)Decimal (H)Hexadecimal\n"
	STR_ENTRADA_INVALIDA: .asciiz "\nEntrada Invalida"
	
.text
	.globl main
	
main:	

	# Print ("Conversor de Bases")
	li	$v0, 4
	la	$a0, STR_TITULO
	syscall
	
	# Print ("Qual eh a base do numero a ser inserido? (B)Binario (O)Octal (D)Decimal (H)Hexadecimal")
	li	$v0, 4
	la	$a0, STR_INSIRA_BASE_INICIAL
	syscall
	
	# Lê a base do número inicial
	li	$v0, 12
	syscall
	move	$a0, $v0			# insere valor lido como parametro da funcao
	move	$s0, $v0			# armazena o valor de base inicial em s0
	jal 	verificaBase
	beq	$v0, $zero, encerraPrograma	# se a função retornou 0, a entrada foi inválida
			
	# Print ("Insira numero a ser convertido:")
	li	$v0, 4
	la	$a0, STR_INSIRA_NUMERO
	syscall
	
	# Lê número digitado pelo usuário como string
	li $v0,8 			# take in input
	la $a0, $gt 		# load byte space into address
	li $a1, 20 			# allot the byte space for string
	move $s2, $a0 		# armazena a string em s2
	syscall
	
	# Print ("O numero deve ser convertido para qual base? (B)Binario (O)Octal (D)Decimal (H)Hexadecimal")
	li	$v0, 4
	la	$a0, STR_INSIRA_BASE_FINAL
	syscall
	
	# Lê a base do resultado final
	li	$v0, 12
	syscall
	move	$a0, $v0			# insere valor lido como parametro da funcao
	move	$s1, $v0			# armazena o valor de base final em s1
	jal 	verificaBase
	beq	$v0, $zero, encerraPrograma	# se a função retornou 0, a entrada foi inválida
	
	
	# Verifica qual será a conversão 
	#	$s0 -> base inicial
	#	$s1 -> base final
	#	$s2 -> numero
	
	move 	$a0, $s2	# já define o numero como parametro da função de conversão
	
	li	$t0, 'B'
	bne	$s0, $t0, baseInicialNaoEhBinaria
	
	li	$t0, 'O'
	beq	$s1, $t0, BinToOct
	li	$t0, 'D'
	beq	$s1, $t0, BinToDec
	li	$t0, 'H'
	beq	$s1, $t0, BinToHex
	
	j	encerraPrograma
	
baseInicialNaoEhBinaria:
	li	$t0, 'O'
	bne	$s0, $t0, baseInicialNaoEhOctal
	
	li	$t0, 'B'
	beq	$s1, $t0, OctToBin
	li	$t0, 'D'
	beq	$s1, $t0, OctToDec
	li	$t0, 'H'
	beq	$s1, $t0, OctToHex
	
	j	encerraPrograma
	
baseInicialNaoEhOctal:
	li	$t0, 'D'
	bne	$s0, $t0, baseInicialNaoEhDecimal
	
	li	$t0, 'B'
	beq	$s1, $t0, DecToBin
	li	$t0, 'O'
	beq	$s1, $t0, DecToOct
	li	$t0, 'H'
	beq	$s1, $t0, DecToHex
	
	j	encerraPrograma
	
baseInicialNaoEhDecimal:
	
	li	$t0, 'B'
	beq	$s1, $t0, HexToBin
	li	$t0, 'O'
	beq	$s1, $t0, HexToOct
	li	$t0, 'H'
	beq	$s1, $t0, HexToDec
	
	j	encerraPrograma
	
	
imprimeResultado:
	
	
	# Encerra programa
encerraPrograma:
	li	$v0, 10
	syscall
	
#------------- Definição de fluxo do programa -------------#
# Binario
BinToOct:
	jal	funcao_BinToDec
	move	$a0, $v0
	jal	funcao_DecToOct
	j	imprimeResultado
BinToDec:
	jal	funcao_BinToDec
	j	imprimeResultado
BinToHex:
	jal	funcao_BinToDec
	move	$a0, $v0
	jal	funcao_DecToHex
	j	imprimeResultado

# Octal
OctToBin:
	jal	funcao_OctToDec
	move	$a0, $v0
	jal	funcao_DecToBin
	j	imprimeResultado
OctToDec:
	jal	funcao_OctToDec
	j	imprimeResultado
OctToHex:
	jal	funcao_OctToDec
	move	$a0, $v0
	jal	funcao_DecToHex
	j	imprimeResultado

# Decimal	
DecToBin:
	jal	funcao_DecToBin
	j	imprimeResultado
DecToOct:
	jal	funcao_DecToOct
	j	imprimeResultado
DecToHex:
	jal	funcao_DecToHex
	j	imprimeResultado

# Hexadecimal
HexToBin:
	jal	funcao_HexToDec
	move	$a0, $v0
	jal	funcao_DecToBin
	j	imprimeResultado
HexToOct:
	jal	funcao_HexToDec
	move	$a0, $v0
	jal	funcao_DecToOct
	j	imprimeResultado
HexToDec:
	jal	funcao_HexToDec
	j	imprimeResultado


#****************************************** Funções de Conversão ******************************************#

#-----------------------------------------------------------------------------------#
#	Converte qualquer número para decimal e em seguida para a base desejada			#
#	Retorna $v0 = número, na base desejada (como definida no nome da funcao)		#
#-----------------------------------------------------------------------------------#

# TODO
funcao_DecToBin:

	li $a0, 2
	jal funcao_DecToAny

	jr	$ra

# TODO
funcao_DecToOct:

	li $a0, 8
	jal funcao_DecToAny

	jr	$ra


# TODO
funcao_DecToHex:

	li $a0, 16
	jal funcao_DecToAny

	jr	$ra

#-----------------------------------------------------------------------#
#	Converte decimal para qualquer número 								#
#	Entrada $a0 = tipo da base destino									#
#	Retorna $v0 = numero em binario										#
#-----------------------------------------------------------------------#

funcao_DecToAny:
	li $t0, 32			# Run all 32 bits of our number width = z
	move $t1, $s1		# Move our number to our temporary register
	li $t5, 0			# Define our return as zero for now
	jal funcao_DecToAny_loop

funcao_DecToAny_loop:
	move $a0, $a0		# Define our base to be exponentiated
	move $a1, $t0		# Move our main argument to our exponential function
	jal exponential
	move $t2, $t5		# Move our result to our temporary register
	sub $t3, $t1, $t2	# Get the result from y - (base ^ (z))

	bge $t3, $zero, funcao_DecToAny_gotRight

	subi $t0, $t0, 1   	# Reduce our base until we got zero

	beq $t0, $zero, funcao_DecToAny_end

funcao_DecToAny_gotRight:
	li $a0, 10		# Define our base to be exponentiated
	move $a1, $t0		# Move our main argument to our exponential function
	jal exponential

	add	$t5, $t5, $v0	# Sum our base to the temporary return register

funcao_DecToAny_end:
	move $v0, $t5

	jr	$ra

# -------------------------


# TODO
funcao_BinToDec:

	jr	$ra

# TODO
funcao_OctToDec:

	# 

	jr	$ra

# TODO	
funcao_HexToDec:

	jr	$ra
	
#****************************************** Funções Auxiliares ******************************************#

#-----------------------------------------------------------------------#
#	Verifica se a base passada por parametro é B, O, D ou H				#
#	Retorna $v0 = 1, se tudo estiver ok									#
#-----------------------------------------------------------------------#
verificaBase:
	# Empilha registradores da função
	
	li	$v0, 0		# inicia retorno como falso
	
	li	$t0, 'B'	# compara com B
	beq	$t0, $a0, verificaBaseConfirma
	
	li	$t0, 'O'	# compara com O
	beq	$t0, $a0, verificaBaseConfirma
	
	li	$t0, 'D'	# compara com D
	beq	$t0, $a0, verificaBaseConfirma
	
	li	$t0, 'H'	# compara com H
	beq	$t0, $a0, verificaBaseConfirma
	
	# Se chegou até aqui é porque a entrada foi invalida
	# Print ("Conversor de Bases")
	li	$v0, 4
	la	$a0, STR_ENTRADA_INVALIDA
	syscall
	
	j	verificaBaseFim
	
verificaBaseConfirma:
	li	$v0, 1		# retorna positivo
	
verificaBaseFim:
	jr	$ra

#-----------------------------------------------------------------------#
#	Realiza a exponeciacao do numero										#
#	Entrada $a0 = base; $a1 = expoente 									#
#	Retorna $v0 = 1, se tudo estiver ok									#
#-----------------------------------------------------------------------#
exponential:
	addi $sp, $sp, -4
	sw $t0, 4($sp)
	move $t0, $zero
	li $v0, 1
exponential_loop: 
	beq	$t0, $a1, exponential_end	# Checks to see if $t0 is equal to $a1 if not
						# it continues, if it is it jumps to end
	mul	$v0, $v0, $a0	# Multiplies the value in $a0 by the value in $v0
	addi $t0, $t0, 1	# Adds 1 to $t0 and stores it in $t0 because
						# $t0 is the loop counter
	j exponential_loop	# Jumps to the beginning of the loop to start
						# the process over
exponential_end:
	#restore $t0 and the stack
	lw	$t0, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
	














