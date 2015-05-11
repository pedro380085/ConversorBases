.data
	.align 0
	STR_TITULO: .asciiz "Conversor de Bases\n\n"
	STR_INSIRA_BASE_INICIAL: .asciiz "Qual eh a base do numero a ser inserido? (B)Binario (O)Octal (D)Decimal (H)Hexadecimal\n"
	STR_INSIRA_NUMERO: .asciiz "\nInsira numero a ser convertido:\n"
	STR_INSIRA_BASE_FINAL: .asciiz "O numero deve ser convertido para qual base? (B)Binario (O)Octal (D)Decimal (H)Hexadecimal\n"
	STR_ENTRADA_INVALIDA: .asciiz "\nEntrada Invalida"
	STR_INPUT: .space 64
	STR_OUTPUT: .space 64
	
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
	
	# Le a base do numero inicial
	li	$v0, 12
	syscall
	move	$a0, $v0			# insere valor lido como parametro da funcao
	move	$s0, $v0			# armazena o valor de base inicial em s0
	jal 	verificaBase
	beq	$v0, $zero, encerraPrograma	# se a funcao retornou 0, a entrada foi invAlida
			
	# Print ("Insira numero a ser convertido:")
	li	$v0, 4
	la	$a0, STR_INSIRA_NUMERO
	syscall
	
	# Le numero digitado pelo usuario como string
	li $v0, 8 			# take in input
	la $a0, STR_INPUT 	# load byte space into address
	li $a1, 20 			# allot the byte space for string
	move $s2, $a0 		# armazena a string em s2
	syscall
	
	# Print ("O numero deve ser convertido para qual base? (B)Binario (O)Octal (D)Decimal (H)Hexadecimal")
	li	$v0, 4
	la	$a0, STR_INSIRA_BASE_FINAL
	syscall
	
	# Le a base do resultado final
	li	$v0, 12
	syscall
	move	$a0, $v0			# insere valor lido como parametro da funcao
	move	$s1, $v0			# armazena o valor de base final em s1
	jal 	verificaBase
	beq	$v0, $zero, encerraPrograma	# se a funcao retornou 0, a entrada foi invalida

	# Carrega a posicao final
	la	$s3, STR_OUTPUT
		
	# Verifica qual sera a conversao 
	#	$s0 -> base inicial
	#	$s1 -> base final
	#	$s2 -> string inicial
	# 	$s3 -> string final
	
	move 	$a0, $s2	# define o numero como parametro da funcao de conversao
	
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
	li	$t0, 'D'
	beq	$s1, $t0, HexToDec
	
	j	encerraPrograma
	
imprimeResultado:
	
	
	# Encerra programa
encerraPrograma:
	li	$v0, 10
	syscall
	
#------------- Definicao de fluxo do programa -------------#
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


#****************************************** Funcoes de Conversao ******************************************#

#-----------------------------------------------------------------------------------#
#	Converte qualquer numero para decimal e em seguida para a base desejada			#
#	Retorna $v0 = numero, na base desejada (como definida no nome da funcao)		#
#-----------------------------------------------------------------------------------#

funcao_DecToBin:

	li $a0, 2

	move $t7, $ra
	jal funcao_DecToAny
	move $ra, $t7

	jr	$ra

funcao_DecToOct:

	li $a0, 8

	move $t7, $ra
	jal funcao_DecToAny
	move $ra, $t7

	jr	$ra


funcao_DecToHex:

	li $a0, 16

	move $t7, $ra
	jal funcao_DecToAny
	move $ra, $t7

	jr	$ra

funcao_BinToDec:

	li $a0, 2

	move $t7, $ra
	jal funcao_AnyToDec
	move $ra, $t7

	jr	$ra

funcao_OctToDec:

	li $a0, 8

	move $t7, $ra
	jal funcao_AnyToDec
	move $ra, $t7

	jr	$ra
	
funcao_HexToDec:

	li $a0, 16

	move $t7, $ra
	jal funcao_AnyToDec
	move $ra, $t7

	jr	$ra

#-----------------------------------------------------------------------#
#	Converte decimal para qualquer numero 								#
#	Entrada $a0 = tipo da base destino									#
#	Retorna $v0 = numero em binario										#
#-----------------------------------------------------------------------#

funcao_DecToAny:
	# Save our return pointer
	addi $sp, $sp, -4
	sw $ra, 4($sp)

	li $t0, 31			# Run all 32 bits of our number width = z
	move $t1, $s2		# Move our number to our temporary register
	li $t5, 0			# Define our return as zero for now
	move $t6, $a0		# Move our exponent base to a safe place
	jal funcao_DecToAny_loop

funcao_DecToAny_loop:
	move $a0, $t6		# Define our base to be exponentiated
	move $a1, $t0		# Move our main argument to our exponential function
	jal exponential
	move $t2, $v0		# Move our result to our temporary register
	sub $t3, $t1, $t2	# Get the result from y - (base ^ (z))

	blt $t3, $zero, funcao_DecToAny_continue

	move $t1, $t3		# Reduce our number for the next interaction

	li $a0, 10			# Define our base to be exponentiated
	move $a1, $t0		# Move our main argument to our exponential function
	jal exponential

	add	$t5, $t5, $v0	# Sum our base to the temporary return register

funcao_DecToAny_continue:
	subi $t0, $t0, 1   	# Reduce our base until we got zero

	bne $t0, $zero, funcao_DecToAny_loop

funcao_DecToAny_end:
	move $v0, $t5		# Move to our end pointer

	# Restore our return pointer
	lw	$ra, 4($sp)
	addi $sp, $sp, 4

	jr	$ra

#-----------------------------------------------------------------------#
#	Converte qualquer numero para decimal								#
#	Entrada $a0 = tipo da base origem									#
#	Retorna $v0 = numero em decimal										#
#-----------------------------------------------------------------------#

funcao_AnyToDec:
	# Save our return pointer
	addi $sp, $sp, -4
	sw $ra, 4($sp)

	# Save our base size
	move $t6, $a0

	# Get string length
	move $a0, $s2
	jal strlen
	move $t3, $v0

	# Inicia o retorno
	move $t4, $s2
	li $t5, 0

funcao_AnyToDec_loop:
	lb $t2, 0($t4)   						# load the next character to t2
	beq $t2, $zero, funcao_AnyToDec_end 	# end loop if null character is reached

	li $t0, '0'
	li $t1, 0
	beq $t0, $t2, funcao_AnyToDec_continue

	li $t0, '1'
	li $t1, 1
	beq $t0, $t2, funcao_AnyToDec_continue

	li $t0, '2'
	li $t1, 2
	beq $t0, $t2, funcao_AnyToDec_continue

	li $t0, '3'
	li $t1, 3
	beq $t0, $t2, funcao_AnyToDec_continue

	li $t0, '4'
	li $t1, 4
	beq $t0, $t2, funcao_AnyToDec_continue

	li $t0, '5'
	li $t1, 5
	beq $t0, $t2, funcao_AnyToDec_continue

	li $t0, '6'
	li $t1, 6
	beq $t0, $t2, funcao_AnyToDec_continue

	li $t0, '7'
	li $t1, 7
	beq $t0, $t2, funcao_AnyToDec_continue

	li $t0, '8'
	li $t1, 8
	beq $t0, $t2, funcao_AnyToDec_continue

	li $t0, '9'
	li $t1, 9
	beq $t0, $t2, funcao_AnyToDec_continue

	li $t0, 'A'
	li $t1, 10
	beq $t0, $t2, funcao_AnyToDec_continue

	li $t0, 'B'
	li $t1, 11
	beq $t0, $t2, funcao_AnyToDec_continue

	li $t0, 'C'
	li $t1, 12
	beq $t0, $t2, funcao_AnyToDec_continue

	li $t0, 'D'
	li $t1, 13
	beq $t0, $t2, funcao_AnyToDec_continue

	li $t0, 'E'
	li $t1, 14
	beq $t0, $t2, funcao_AnyToDec_continue

	li $t0, 'F'
	li $t1, 15
	beq $t0, $t2, funcao_AnyToDec_continue

funcao_AnyToDec_continue:
	move $a0, $t6		# Define our base to be exponentiated
	move $a1, $t3		# Move our main argument to our exponential function
	subi $a1, $a1, 1 	# Bases exponenciais comecam a contar em 0
	jal exponential

	mul $t1, $t1, $v0 	# Multiplica as bases
	subi $t3, $t3, 1 	# Decrementa o tamanho da string
	add $t5, $t5, $t1 	# Soma o resultado a base
	addi $t4, $t4, 1 	# Aumenta a posicao do nosso registrador de caracter

	bne $t3, $zero, funcao_AnyToDec_loop

funcao_AnyToDec_end:
	move $v0, $t5		# Move to our end pointer

	# Restore our return pointer
	lw	$ra, 4($sp)
	addi $sp, $sp, 4

	jr	$ra
	
#****************************************** Funcoes Auxiliares ******************************************#

#-----------------------------------------------------------------------#
#	Verifica se a base passada por parametro � B, O, D ou H				#
#	Retorna $v0 = 1, se tudo estiver ok									#
#-----------------------------------------------------------------------#
verificaBase:
	# Empilha registradores da funcao
	
	li	$v0, 0		# inicia retorno como falso
	
	li	$t0, 'B'	# compara com B
	beq	$t0, $a0, verificaBaseConfirma
	
	li	$t0, 'O'	# compara com O
	beq	$t0, $a0, verificaBaseConfirma
	
	li	$t0, 'D'	# compara com D
	beq	$t0, $a0, verificaBaseConfirma
	
	li	$t0, 'H'	# compara com H
	beq	$t0, $a0, verificaBaseConfirma
	
	# Se chegou at� aqui � porque a entrada foi invalida
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
	# restore $t0 and the stack
	lw	$t0, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
	
#-----------------------------------------------------------------------#
#	Realiza o calculo do tamanho da string								#
#	Entrada $a0 = endereco da string 									#
#	Retorna $v0 = tamanho da string 									#
#-----------------------------------------------------------------------#
## int strlen(char*)
strlen:
	addi $sp, $sp, -4
	sw $t0, 4($sp)
    addi $t0, $zero, 1  #initialize count to start with 1 for first character
    j strlen.test
strlen.loop:
    addi $a0, $a0, 1    #load increment string pointer
    addi $t0, $t0, 1 	#increment count
strlen.test:
    lb $t1, 0($a0)   		#load the next character to t0
    bnez $t1, strlen.loop 	#end loop if null character is reached
    subi $t0, $t0, 2
    move $v0, $t0
    lw	$t0, 4($sp)
	addi $sp, $sp, 4
    jr $ra



# String copier function
strcopier:
	addi $sp, $sp, -12
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
    or $t0, $a0, $zero # Source
    or $t1, $a1, $zero # Destination

strcopier_loop:
    lb $t2, 0($t0)
    beq $t2, $zero, strcopier_end
    addiu $t0, $t0, 1
    sb $t2, 0($t1)
    addiu $t1, $t1, 1
    b strcopier_loop
    nop

strcopier_end:
    or $v0, $t1, $zero # Return last position on result buffer
    lw	$t0, 4($sp)
    lw	$t1, 8($sp)
    lw	$t2, 12($sp)
	addi $sp, $sp, 12
    jr $ra
    nop



