.data
		vetor: .skip 10

		.equ button, 0x2050 # Endereço base dos botões
		.equ colunas, 0x2030 # Endereço base para a coluna
		.equ linhas, 0x2040 # Endereço base para as linhas
		
		.equ clear, 0x01 #Clear display -> '00000001'
		.equ home, 0b00000010 #Bota o curso na posição '00' 00000010
	
		.equ init1, 0b00111000 # 38 function set 2 line
		.equ init2, 0b00111001 # 39 extendsion mode
		.equ init3, 0b00010100 # 14 OSC frequency
		.equ init4, 0b01011110 # 5e Icon display on booster circuit on
		.equ init5, 0b01101101 # 6a follower circuit on with 010
		.equ init6, 0b01110000 # 78 Contrast set for 1000
		.equ init7, 0b00001100 # c display on cursor off
		.equ init8, 0b00000110 # 6 Entry mode L/R
		.equ init9, 0b00000001 # 1 Clear
			
			
			
		#Definindo letras
		.equ O, 0b01001111
		.equ P, 0b01010000
		.equ T, 0b01010100
		.equ I, 0b01001001
		.equ N, 0b01001110
		.equ L, 0b01001100
		.equ E, 0b01000101
		.equ D, 0b01000100

		#Definindo números
		.equ um, 0b00110001
		.equ dois, 0b00110010
		.equ tres, 0b00110011
		.equ quatro, 0b00110100
		.equ cinco, 0b00110101

		#Definindo símbolos
		.equ seta, 0b11111100
		.equ espaco, 0b10100000

		# Nomeando registradores
		# r1 -> armazenar o valor '1', valor genérico
		# r2 -> armazenar o valor '2', usado para lógica dos botões
		# r3 -> result da instrução custom
		# r4 -> aramazena o valor '4', usado para lógica dos botões
		# r5 -> estado do programa de 0 a 9 (em qual opção o usuário está)
		# r8 -> aramazena o valor '8', usado para lógica dos botões

		# r10 -> armazena a base para as colunas
		# r11 -> armazena a base para as linhas
		# r12 -> armazena a base para as button
		# r13 -> aramzena o valor de entrada dos botões
		# r14 -> utilizado para retorno de custom instruction e carregar valores
		# r15 -> flag up/down: guarda 1 quando foi feita uma operação de up ou down no menu, a fim de evitar que
		#		 muitos "up's" ou "down's" sejam realizados
		
		.global main
		.text
main:
		movia r10, colunas
		movia r11, linhas
		movia r12, button
		addi r1, r0, 1
		addi r2, r0, 2
		addi r4, r0, 4
		addi r8, r0, 8
		stb r1, 0(r10)
		call init
		call mminit
		call OP1
		
mainmenu: #Gerencia os botões do menu principal
		ldb r13, 0(r12) #Guarda a entrada dos botões em R13
		beq r1, r13, up
		beq r2, r13, down
		beq r15, r1, flagreset
		beq r4, r13, select
		br mainmenu
		
selectmenu: #Gerencia os botões do menu após selecionada uma opção
		ldb r13, 0(r12) #Guarda a entrada dos botões em R13
		beq r8, r13, main #volta para o menu principal, quando o usuário opta por voltar
		br selectmenu

up: #Realiza as mudanças necessárias quando é acionado o up
		beq r15, r1, mainmenu #Retorna ao menu inicial caso r15 não tenha sido resetado
		beq r5, r0, mainmenu #Caso esteja na primeira opção, não há possibilidade se subir
		nextpc r17
		addi r17, r17, 40
		add r31, r0, r17
		addi r14, r0, 1 
		beq r5, r14, OP1 #Caso esteja na segunda opção, muda para a primeira
		addi r14, r0, 2
		beq r5, r14, OP2 #Caso esteja na terceira opção, muda para a segunda
		addi r14, r0, 3
		beq r5, r14, OP3 #Caso esteja na quarta opção, muda para a terceira
		addi r14, r0, 4
		beq r5, r14, OP4 #Caso esteja na quinta opção, muda para a quarta
		addi r15, r0, 1
		br mainmenu 

down: #Realiza as mudanças necessárias quando é chamado o down
		beq r15, r1, mainmenu #Retorna ao menu inicial caso r15 não tenha sido resetado
		addi r14, r0, 4
		beq r5, r14, mainmenu #Caso esteja na última opção, não há possibilidade de descer
		nextpc r17
		addi r17, r17, 40
		add r31, r0, r17
		addi r14, r0, 0 
		beq r5, r14, OP2 #Caso esteja na primeira opção, muda para a segunda
		addi r14, r0, 1
		beq r5, r14, OP3 #Caso esteja na segunda opção, muda para a terceira
		addi r14, r0, 2
		beq r5, r14, OP4 #Caso esteja na terceira opção, muda para a quarta
		addi r14, r0, 3
		beq r5, r14, OP5 #Caso esteja na quarta opção, muda para a quinta
		addi r15, r0, 1
		br mainmenu #Quando na última opção (não há poddibilidade de descer) ou em qualquer outro estado, retona para o mainmenu

flagreset:
		or r15, r0, r0
		br mainmenu
		
select:
		addi r5, r5, 5 #Seta para o estado de opção selecionada correspondente
		nextpc r31
		addi r31, r31, 8
		br led
		addi r14, r0, 5
		beq r5, r14, led1
		addi r14, r0, 6
		beq r5, r14, led2
		addi r14, r0, 7
		beq r5, r14, led3
		addi r14, r0, 8
		beq r5, r14, led4
		addi r14, r0, 9
		beq r5, r14, led5
		br main #Caso ocorra algum erro interno e não esteja em um estado válido, volta ao menu inicial

led:
		movia r14, clear
		custom 0, r3, r0, r14
		
		movia r14, 0b10000110
		custom 0, r3, r0, r14 #Seta o contador do endereço da DDRAM do display para a posição 6 da DDRAM
		
		movia r14, L
		custom 0, r3, r1, r14
		
		movia r14, E
		custom 0, r3, r1, r14
		
		movia r14, D
		custom 0, r3, r1, r14
		ret
		
led1: 
		movia r14, 0b11000111 #Muda o contador de endereço de escrita do display para o endereço 8 da DDRAM
		custom 0, r3, r0, r14
		
		movia r14, um 
		custom 0, r3, r1, r14
		
		stb r0, 0(r10) #Liga a coluna das leds
		movia r14, 0b11110
		stb r14, 0(r11) #Manda nível lógico baixo (liga) apenas a led da linha 0
		br selectmenu 
		
led2:
		movia r14, 0b11000111 #Muda o contador de endereço de escrita do display para o endereço 8 da DDRAM
		custom 0, r3, r0, r14
		
		movia r14, dois 
		custom 0, r3, r1, r14
		
		stb r0, 0(r10) #Liga a coluna das leds
		movia r14, 0b11101
		stb r14, 0(r11) #Manda nível lógico baixo (liga) apenas a led da linha 1
		br selectmenu
		
led3:
		movia r14, 0b11000111 #Muda o contador de endereço de escrita do display para o endereço 8 da DDRAM
		custom 0,r3, r0, r14
		
		movia r14, tres 
		custom 0, r3, r1, r14
		stb r0, 0(r10) #Liga a coluna das leds
		movia r14, 0b11011
		stb r14, 0(r11) #Manda nível lógico baixo (liga) apenas a led da linha 2
		br selectmenu
		
led4:
		movia r14, 0b11000111 #Muda o contador de endereço de escrita do display para o endereço 8 da DDRAM
		custom 0, r3, r0, r14
		
		movia r14, quatro 
		custom 0, r3, r1, r14
		
		stb r0, 0(r10) #Liga a coluna das leds
		movia r14, 0b10111
		stb r14, 0(r11) #Manda nível lógico baixo (liga) apenas a led da linha 3
		br selectmenu
		
led5:
		movia r14, 0b11000111 #Muda o contador de endereço de escrita do display para o endereço 8 da DDRAM
		custom 0, r3, r0, r14
		
		movia r14, cinco 
		custom 0, r3, r1, r14
		
		stb r0, 0(r10) #Liga a coluna das leds
		movia r14, 0b01111
		stb r14, 0(r11) #Manda nível lógico baixo (liga) apenas a led da linha 4
		br selectmenu
		

mminit: #Escreve "OPTION" na primeira e na segunda linha (facilita a volta ao menu principal após selecionar uma opção).
		movia r14, 0b10000100
		custom 0, r3, r0, r14
		movia r14, O
		custom 0, r3, r1, r14
		movia r14, P
		custom 0, r3, r1, r14
		movia r14, T
		custom 0, r3, r1, r14
		movia r14, I
		custom 0, r3, r1, r14
		movia r14, O
		custom 0, r3, r1, r14
		movia r14, N
		custom 0, r3, r1, r14
		
		addi r14, r0, 0b11000100
		custom 0, r3, r0, r14
		movia r14, O
		custom 0, r3, r1, r14
		movia r14, P
		custom 0, r3, r1, r14
		movia r14, T
		custom 0, r3, r1, r14
		movia r14, I
		custom 0, r3, r1, r14
		movia r14, O
		custom 0, r3, r1, r14
		movia r14, N
		custom 0, r3, r1, r14
		ret
		
OP1:	movia r14, 0b10000010 #Coloca a seta na posição 2 da primeira linha.
		custom 0, r3, r0, r14	
		movia r14, seta
		custom 0, r3, r1, r14
		
		movia r14, 0b11000010 #Limpa a segunda posição da segunda linha.
		custom 0, r3, r0, r14	
		movia r14, espaco
		custom 0, r3, r1, r14
		
		movia r14, 0b10001011
		custom 0, r3, r0, r14	
		movia r14, um
		custom 0, r3, r1, r14
		
		movia r14, 0b11001011
		custom 0, r3, r0, r14	
		movia r14, dois
		custom 0, r3, r1, r14
		addi r5, r0, 0 #Seta o estado para 0
		#addi r15, r0, 1 #Neste ponto, foi feito um "up" nas opções, r15 carrega essa informação
		ret
		
OP2:	movia r14, 0b11000010
		custom 0, r3, r0, r14	
		movia r14, seta
		custom 0, r3, r1, r14
		
		movia r14, 0b10000010
		custom 0, r3, r0, r14	
		movia r14, espaco
		custom 0, r3, r1, r14
		
		movia r14, 0b10001011
		custom 0, r3, r0, r14	
		movia r14, um
		custom 0, r3, r1, r14
		
		movia r14, 0b11001011
		custom 0, r3, r0, r14	
		movia r14, dois
		custom 0, r3, r1, r14
		addi r5, r0, 1 #Seta o estado para 1
		#addi r15, r0, 1 #Neste ponto, foi feito um "up" nas opções, r15 carrega essa informação
		ret
		
OP3:	movia r14, 0b11000010
		custom 0, r3, r0, r14	
		movia r14, seta
		custom 0, r3, r1, r14
		
		movia r14, 0b10000010
		custom 0, r3, r0, r14	
		movia r14, espaco
		custom 0, r3, r1, r14
		
		movia r14, 0b10001011
		custom 0, r3, r0, r14	
		movia r14, dois
		custom 0, r3, r1, r14
		
		movia r14, 0b11001011
		custom 0, r3, r0, r14	
		movia r14, tres
		custom 0, r3, r1, r14
		addi r5, r0, 2 #Seta o estado para 2
		#addi r15, r0, 1 #Neste ponto, foi feito um "up" nas opções, r15 carrega essa informação
		ret
 
OP4:	movia r14, 0b11000010
		custom 0, r3, r0, r14	
		movia r14, seta
		custom 0, r3, r1, r14
		
		movia r14, 0b10000010
		custom 0, r3, r0, r14	
		movia r14, espaco
		custom 0, r3, r1, r14
		
		movia r14, 0b10001011
		custom 0, r3, r0, r14	
		movia r14, tres
		custom 0, r3, r1, r14
		
		movia r14, 0b11001011
		custom 0, r3, r0, r14	
		movia r14, quatro
		custom 0, r3, r1, r14
		addi r5, r0, 3 #Seta o estado para 3
		#addi r15, r0, 1 #Neste ponto, foi feito um "up" nas opções, r15 carrega essa informação
		ret
 
OP5:	movia r14, 0b11000010
		custom 0, r3, r0, r14	
		movia r14, seta
		custom 0, r3, r1, r14 
		
		movia r14, 0b10000010
		custom 0, r3, r0, r14	
		movia r14, espaco
		custom 0, r3, r1, r14
		
		movia r14, 0b10001011
		custom 0, r3, r0, r14	
		movia r14, quatro
		custom 0, r3, r1, r14
		
		movia r14, 0b11001011
		custom 0, r3, r0, r14	
		movia r14, cinco
		custom 0, r3, r1, r14
		addi r5, r0, 4 #Seta o estado para 4
		#addi r15, r0, 1 #Neste ponto, foi feito um "up" nas opções, r15 carrega essa informação
		ret

init:
		movia r14, init1
		custom 0, r3, r0, r14 #Limpar Busy Flag
		custom 0, r3, r0, r14 #
		movia r14, init2
		custom 0, r3, r0, r14
		movia r14, init3
		custom 0, r3, r0, r14
		movia r14, init4
		custom 0, r3, r0, r14
		movia r14, init5
		custom 0, r3, r0, r14
		movia r14, init6
		custom 0, r3, r0, r14
		movia r14, init7
		custom 0, r3, r0, r14
		movia r14, init8
		custom 0, r3, r0, r14
		movia r14, init9
		custom 0, r3, r0, r14
		movia r14, clear
		custom 0, r3, r0, r14

		ret # Retorna para a main