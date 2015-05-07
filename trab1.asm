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
	
	# Lê número digitado pelo usuário
	li	$v0, 5
	syscall
	move	$s2, $v0			# armazena o numero em s2
	
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
	jal	funcao_BinToOct
	j	imprimeResultado
BinToDec:
	jal	funcao_BinToDec
	j	imprimeResultado
BinToHex:
	jal	funcao_BinToHex
	j	imprimeResultado
# Octal
OctToBin:
	jal	funcao_OctToBin
	j	imprimeResultado
OctToDec:
	jal	funcao_OctToBin
	move	$a0, $v0
	jal	funcao_BinToDec
	j	imprimeResultado
OctToHex:
	jal	funcao_OctToBin
	move	$a0, $v0
	jal	funcao_BinToHex
	j	imprimeResultado
# Decimal	
DecToBin:
	jal	funcao_DecToBin
	j	imprimeResultado
DecToOct:
	jal	funcao_DecToBin
	move	$a0, $v0
	jal	funcao_BinToOct
	j	imprimeResultado
DecToHex:
	jal	funcao_DecToBin
	move	$a0, $v0
	jal	funcao_BinToHex
	j	imprimeResultado
# Hexadecimal
HexToBin:
	jal	funcao_HexToBin
	j	imprimeResultado
HexToOct:
	jal	funcao_HexToBin
	move	$a0, $v0
	jal	funcao_BinToOct
	j	imprimeResultado
HexToDec:
	jal	funcao_HexToBin
	move	$a0, $v0
	jal	funcao_BinToDec
	j	imprimeResultado


#****************************************** Funções de Conversão ******************************************#

	# TODO

funcao_BinToOct:

	jr	$ra
	
funcao_BinToDec:

	jr	$ra
	
funcao_BinToHex:

	jr	$ra

funcao_OctToBin:

	jr	$ra

funcao_DecToBin:

	jr	$ra
	
funcao_HexToBin:

	jr	$ra
	
#****************************************** Funções Auxiliares ******************************************#

#-----------------------------------------------------------------------#
#	Verifica se a base passada por parametro é B, O, D ou H		#
#	Retorna $v0 = 1, se tudo estiver ok				#
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
	
	
	














