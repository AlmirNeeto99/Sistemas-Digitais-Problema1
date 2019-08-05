.set noat
.data
		.equ button, 0x2070 # Endereço base dos botões
		.equ colunas, 0x2050 # Endereço base para a coluna
		.equ linhas, 0x2060 # Endereço base para as linhas
		.equ uart, 0x2090 # Endereço base para a uart

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

		#Definindo letras usadas no display
		.equ O, 0b01001111
		.equ P, 0b01010000
		.equ T, 0b01010100
		.equ I, 0b01001001
		.equ N, 0b01001110
		.equ L, 0b01001100
		.equ E, 0b01000101
		.equ D, 0b01000100

		#Definindo números usados nos display
		.equ um, 0b00110001
		.equ dois, 0b00110010
		.equ tres, 0b00110011
		.equ quatro, 0b00110100
		.equ cinco, 0b00110101

		#Definindo símbolos
		.equ seta, 0b11111100
		.equ espaco, 0b10100000
		.equ carriage, 13
		.equ line, 10

		connectMqtt: .byte 0b00010000,15,0, 4,0b01001101,0b01010001,0b01010100,0b01010100,4,0b00000010,1,0,0,3,80,48,51, 10 #17
		publishMqtt: .byte 0b00110000,14,0,7,83,68,84,111,112,105,99,76,69,68,32,49,10 #16

		atCommand: .ascii "AT\n"
		resetCommand: .ascii "AT+RST\n"
		autoConnect: .ascii "AT+CWAUTOCONN=0\n"
		modeCommand: .ascii "AT+CWMODE=1\n"
		connectCommand: .ascii "AT+CWJAP_CUR=\"WLessLEDS\",\"HelloWorldMP31\"\n"
		multiConnection: .ascii "AT+CIPMUX=0\n"
		startCommand: .ascii "AT+CIPSTART=\"TCP\",\"192.168.1.101\",1889\n"
		connectMqttCommand: .ascii "AT+CIPSENDEX=17\n"
		publishCommand: .ascii "AT+CIPSENDEX=16\n"
		echoOff: .ascii "ATE0\n"

		# Nomeando registradores
		# r1 -> armazenar o valor '1', valor genérico
		# r2 -> armazenar o valor '2', usado para lógica dos botões
		# r3 -> result da instrução custom
		# r4 -> aramazena o valor '4', usado para lógica dos botões
		# r5 -> estado do programa de 0 a 9 (em qual opção o usuário está)
		# r6 -> armazena endereço de retorno
		# r7 -> armazena instrução de retorno
		# r8 -> armazena o valor '8', usado para lógica dos botões
		# r9 -> controle de loop (NÃO USAR DEVIDO A CHAMADAS RECURSIVAS)
		# r10 -> armazena a base para as colunas
		# r11 -> armazena a base para as linhas
		# r12 -> armazena a base para as button
		# r13 -> armazena o valor de entrada dos botões
		# r14 -> utilizado para retorno de custom instruction e carregar valores
		# r15 -> flag up/down: guarda 1 quando foi feita uma operação de up ou down no menu, a fim de evitar que
		#		 muitos "up's" ou "down's" sejam realizados
		# r16 -> Usado para armazenar a base das strings dos comandos
		# r17 -> Usado para ler um único character de r16
		# r18 -> Usado para ler o registrador de controle da uart
		# r19 -> Usado para receber o bit que indica caracter válido da uart
		# r20 -> base da uart
		# r21 -> controle de Loop

		.global setup
		.text
sendAt: # AT
	movia r16, atCommand
	mov r7, ra
	br sendCommandToUart

sendRST: # AT+RST Reseta módulo
	movia r16, resetCommand
	mov r7, ra
	br sendCommandToUart

sendEcho: #ATE0 Desliga o echo da ESP.
	movia r16, echoOff
	mov r7, ra
	br sendCommandToUart

sendAuto: # AT+CWAUTOCONN=0 Desliga a auto conexão
	movia r16, autoConnect
	mov r7, ra
	br sendCommandToUart

changeMode: # AT+CWMODE=1 Seta o modo como station
	movia r16, modeCommand
	mov r7, ra
	br sendCommandToUart

connectToWifi: # AT+CWJAP_CUR=ssid,pw Conecta na rede 'ssid' com senha 'pw'
	movia r16, connectCommand
	mov r7, ra
	br sendCommandToUart

sendMultiConnection: # AT+CIPMUX=0 Single connection
	movia r16, multiConnection
	mov r7, ra
	br sendCommandToUart

startTcp: # AT+CIPSTART inicia uma comunicação TCP com o broker
	movia r16, startCommand
	mov r7, ra
	br sendCommandToUart

cipSendToConnect: # AT+CIPSENDEX=17 informa ao esp que 17 bytes de dados serão enviados
	movia r16, connectMqttCommand
	mov r7, ra
	br sendCommandToUart

cipSendToPublish: # AT+CIPSENDEX=16 informa ao esp que 16 bytes de dados serão enviados
	movia r16, publishCommand
	mov r7, ra
	br sendCommandToUart

mqttConnect: # Envia os dados de conexão para o broker
	movia r16, connectMqtt
	mov r7, ra
	br sendMqttPacket

mqttPublish: # Envia um pacote de publish para o broker
	movia r16, publishMqtt
	mov r7, ra
	br sendMqttPacket

sendMqttPacket: # Envia um byte de cada vez para o broker
	ldb r17, 0(r16)
	stbio r17, 0(r20)
	call timeBetweenCharacters
	addi r16, r16, 1
	ldb r9, 0(r16)
	bne r9, r10, sendMqttPacket # Caso o próximo character não seja um '\n' executa o loop.
	call readFromUart
	mov ra, r7
	ret

sendCommandToUart: # Envia um caracter de cada vez para a UART... Até que o '\n' seja encontrado
	ldb r17, 0(r16)
	stbio r17, 0(r20)
	call timeBetweenCharacters
	addi r16, r16, 1
	ldb r9, 0(r16)
	bne r9, r10, sendCommandToUart # Caso o próximo character não seja um '\n' executa o loop.
	br endString

endString: # Coloca o '\r' e '\n' no fim dos comandos AT
	movia r17, carriage
	stbio r17, 0(r20)
	movia r17, line
	stbio r17, 0(r20)
	call readFromUart
	mov ra, r7
	ret

setup:
		movia r10, colunas
		movia r11, linhas
		movia r12, button
		addi r1, r0, 1
		addi r2, r0, 2
		addi r4, r0, 4
		addi r8, r0, 8
		stb r1, 0(r10)
		movia r20, uart
		call init
		addi r5, r0, 32000
		addi r10, r0, 10 # Coloca o decimal que representa um '\n', para comparar com o fim da string de comando.
		call sendAt
		call sendRST
		call sendEcho
		call sendAuto
		call changeMode
		call connectToWifi
		call sendMultiConnection
		call startTcp
		call cipSendToConnect
		call mqttConnect
main:
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
		addi r10, r0, 10
		call startTcp
		call cipSendToPublish
		movia r16, publishMqtt
		addi r17, r0, 49
		stb r17, 15(r16)
		call mqttPublish
		movia r10, colunas

		stb r0, 0(r10) #Liga a coluna das leds
		movia r14, 0b11110
		stb r14, 0(r11) #Manda nível lógico baixo (liga) apenas a led da linha 0

		br selectmenu

led2:
		movia r14, 0b11000111 #Muda o contador de endereço de escrita do display para o endereço 48 da DDRAM
		custom 0, r3, r0, r14

		movia r14, dois
		custom 0, r3, r1, r14
		addi r10, r0, 10
		call startTcp
		call cipSendToPublish
		movia r16, publishMqtt
		addi r17, r0, 50
		stb r17, 15(r16)
		call mqttPublish

		movia r10, colunas
		stb r0, 0(r10) # Liga a coluna das leds
		movia r14, 0b11101
		stb r14, 0(r11) # Manda nível lógico baixo (liga) apenas a led da linha 1

		br selectmenu
led3:
		movia r14, 0b11000111 # Muda o contador de endereço de escrita do display para o endereço 8 da DDRAM
		custom 0,r3, r0, r14

		movia r14, tres
		custom 0, r3, r1, r14
		addi r10, r0, 10
		call startTcp
		call cipSendToPublish
		movia r16, publishMqtt
		addi r17, r0, 51
		stb r17, 15(r16)
		call mqttPublish

		movia r10, colunas
		stb r0, 0(r10) #Liga a coluna das leds
		movia r14, 0b11011
		stb r14, 0(r11) #Manda nível lógico baixo (liga) apenas a led da linha 2

		br selectmenu

led4:
		movia r14, 0b11000111 #Muda o contador de endereço de escrita do display para o endereço 8 da DDRAM
		custom 0, r3, r0, r14

		movia r14, quatro
		custom 0, r3, r1, r14
		addi r10, r0, 10
		call startTcp
		call cipSendToPublish
		movia r16, publishMqtt
		addi r17, r0, 52
		stb r17, 15(r16)
		call mqttPublish

		movia r10, colunas
		stb r0, 0(r10) #Liga a coluna das leds
		movia r14, 0b10111
		stb r14, 0(r11) #Manda nível lógico baixo (liga) apenas a led da linha 3

		br selectmenu

led5:
		movia r14, 0b11000111 #Muda o contador de endereço de escrita do display para o endereço 8 da DDRAM
		custom 0, r3, r0, r14

		movia r14, cinco
		custom 0, r3, r1, r14
		addi r10, r0, 10
		call startTcp
		call cipSendToPublish
		movia r16, publishMqtt
		addi r17, r0, 53
		stb r17, 15(r16)
		call mqttPublish

		movia r10, colunas
		stb r0, 0(r10) #Liga a coluna das leds
		movia r14, 0b01111
		stb r14, 0(r11) #Manda nível lógico baixo (liga) apenas a led da linha 4

		br selectmenu

mminit: #Escreve "OPTION" na primeira e na segunda linha (facilita a volta ao menu principal após selecionar uma opção).
		movia r14, clear
		custom 0, r3, r0, r14
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

readFromUart:
		mov r24, ra
		br oneSecond # 1 Segundo de espera para execução do comando AT no esp

oneSecondReturn:
		mov r23, r0
		movia r14, clear # Vai ser removido
		custom 0, r3, r0, r14 # Vai ser removido
		movia r14, 0b11000000 # Vai ser removido
		custom 0, r3, r0, r14 # Vai ser removido

clearUart: # Limpa a uart após envio de comandos
		call timeBetweenCharacters
		ldwio r18, 0(r20)
		andi r19, r18, 0x8000 #r18 <- Bit 15 indica character válido recebido.
		bne r19, r0, uartFlag
		addi r23, r23, 1
		bne r23, r5, clearUart

limpo: # Retorna a execução para onde o 'readFromUart' foi chamado
		mov ra, r24
		ret

uartFlag: # printa o retorno da esp na tela, será removido posteriormente
		mov r23, r0
		br clearUart

oneSecond: #Loop de 1S = 50 000 000 * 20nS ~> 50 mil instruções.
		addi r22, r0, 500
externLoop:
		addi r21, r0, 24996
		subi r22, r22, 1
		bne r22, r0, innerLoop
		br oneSecondReturn
innerLoop:
		subi r21, r21, 1
		bne r21, r0, innerLoop
		br externLoop
timeBetweenCharacters: #BaudRate de 115200 -> aproximadamente 8,7*10^-6 S entre characteres. Para ClockTime=2nS, delay ~ 435Clocks ~ 435instruções.
		addi r22, r0, 218
reduza:
		subi r22, r22, 1
		bne r22, r0, reduza
		ret
