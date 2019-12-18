.data
		#message: .byte 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48
		message: .ascii "Player 1 won!"
		message2: .ascii "Press  start"
		message3: .ascii "to  Play"
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

		#Definindo coordenadas de barras e bola
		.equ YPlayer1, 0x2110
		.equ YPlayer2, 0x2100
		.equ XBola, 0x20f0
		.equ YBola, 0x20e0
		.equ EndOfFrame, 0x20d0

		#Definindo entradas do sistema
		.equ AD0, 0x20c0
		.equ AD1, 0x20b0
		.equ ADC_BUSY, 0x20a0
		.equ button, 0x2090 #Botões de start e resetGame

		.global main
		.text
main:
		addi r1, r0, 1
		call init
		addi r15, r0, 0 #Pontuação player1
		addi r16, r0, 0 #Pontuação player2
		br startMenu
go:
		call placar
		addi r10, r0, 0 #Contador de quadros, utilizado para acelerar a bola
		addi r12, r0, 1 #Taxa de atualização do Y da bola
		addi r13, r0, 1 #ângulo da bola (incremento de Y)
		addi r14, r0, 1 #flag subir ou descer da bola: 0 - subir; 1 - descer;


		addi r17, r0, 1 #Velocidade da bola
		addi r18, r0, 0 #Flag de pontuação: 0 - não houve; 1 - ponto player1; 2 - ponto player2;
		addi r19, r0, 200 # Barra 1
		addi r20, r0, 200 # Barra 2
		addi r21, r0, 315 # X bola
		addi r22, r0, 235 # Y bola
		addi r23, r0, 1 #1 bola indo para a direita

		call randomInit

		movia r3, YPlayer1
		stw r19, 0(r3)
		movia r3, YPlayer2
		stw r20, 0(r3)
		movia r3, XBola
		stw r21, 0(r3)
		movia r3, YBola
		stw r22, 0(r3)


waitFrame: 
		movia r3, button
		ldbio r2, 0(r3)
		beq r2, r1, main

		movia r3, EndOfFrame
		ldbio r2, 0(r3)
		andi r2, r2, 1
		beq r0, r2, waitFrame


waitSyncEnd:
		ldbio r2, 0(r3)
		andi r2, r2, 1
		bne r0, r2, waitSyncEnd

waitADC:
		movia r3, ADC_BUSY
		ldbio r2, 0(r3)
		bne r2, r0, waitADC

player1:
		movia r3, AD0
		ldw r2, 0(r3)
		subi r2, r2, 96
		slli r2, r2, 2
		bgt r2, r19, down1
		blt r2, r19, up1
player2:
		movia r3, AD1
		ldw r2, 0(r3)
		subi r2, r2, 96
		slli r2, r2, 2

		beq r2, r20, bolaX
		bgt r2, r20, down2
		blt r2, r20, up2
down1:
		addi r3, r0, 400
		beq r19, r3, player2
		addi r19, r19, 5
		br player2
up1:
		beq r19, r0, player2
		subi r19, r19, 5
		br player2
down2:
		addi r3, r0, 400
		beq r20, r3, bolaX
		addi r20, r20, 5
		br bolaX
up2:
		beq r20, r0, bolaX
		subi r20, r20, 5


bolaX:
		beq r23, r0, esquerda
direita:
		add r21, r21, r17
		br bolaY
esquerda:
		sub r21, r21, r17
bolaY:
		blt r11, r12, refresh
		addi r11, r0, 0
		beq r14, r0, subir
descer:
		addi r3, r0, 470
		bgt r22, r3, subir
		addi r14, r0, 1
		add r22, r22, r13
		br refresh
subir:
		blt r22, r0, descer
		addi r14, r0, 0
		sub r22, r22, r13
refresh:
		addi r11, r11, 1
		bne r18, r0, postPonto
		call verificarPonto

postPonto:
		movia r3, YPlayer1
		stw r19, 0(r3)
		movia r3, YPlayer2
		stw r20, 0(r3)
		movia r3, XBola
		stw r21, 0(r3)
		movia r3, YBola
		stw r22, 0(r3)
		addi r10, r10, 1
		call acelerador
		beq r18, r0, waitFrame
		beq r23, r1, verifyRightEnd
verifyLeftEnd:
		blt r21, r1, go
		br waitFrame
verifyRightEnd:
		addi r2, r0, 629
		bgt r21, r2, go
		br waitFrame
init:
		movia r2, init1
		custom 0, r3, r0, r2 #Limpar Busy Flag
		custom 0, r3, r0, r2 #Limpar Busy Flag
		movia r2, init2
		custom 0, r3, r0, r2
		movia r2, init3
		custom 0, r3, r0, r2
		movia r2, init4
		custom 0, r3, r0, r2
		movia r2, init5
		custom 0, r3, r0, r2
		movia r2, init6
		custom 0, r3, r0, r2
		movia r2, init7
		custom 0, r3, r0, r2
		movia r2, init8
		custom 0, r3, r0, r2
		movia r2, init9
		custom 0, r3, r0, r2
		movia r2, clear
		custom 0, r3, r0, r2
		ret # Retorna para a main

verificarPonto:
		beq r23, r0, E
D:
		addi r3, r0, 619
		bgt r21, r3, CD
		br exit
E:
		addi r3, r0, 11
		blt r21, r3, CE
		br exit

CD:
		subi r3, r20, 10
		blt r22, r3, pontoP1

		#blt r22, r20, anglRandom
		addi r3, r20, 80
		bgt r22, r3, pontoP1
		#addi r3, r20, 70
		#bgt r22, r3, anglRandom
		addi r23, r0, 0
		br calcAngulo
CE:
		subi r3, r19, 10
		blt r22, r3, pontoP2
		#blt r22, r19, anglRandom
		addi r3, r19, 80
		bgt r22, r3, pontoP2
		#addi r3, r19, 70
		#bgt r22, r3, anglRandom
		addi r23, r0, 1
		br calcAngulo
pontoP1:
		addi r18, r0, 1
		addi r2, r0, 629
		addi r15, r15, 1
		ret
pontoP2:
		addi r18, r0, 2
		addi r16, r16, 1
		ret
exit:
		ret

placar:
		movia r2, clear
		custom 0, r3, r0, r2
		movia r2, 0b10000100 #1posição 5 da primeira linha.
		custom 0, r3, r0, r2
		movia r2, 0b01010000 #P
		custom 0, r3, r1, r2
		movia r2, 0b00110001 #1
		custom 0, r3, r1, r2
		movia r2, 0b10001010 #1posição 11 da primeira linha.
		custom 0, r3, r0, r2
		movia r2, 0b01010000 #P
		custom 0, r3, r1, r2
		movia r2, 0b00110010 #2
		custom 0, r3, r1, r2
		movia r2, 0b11000100	 #posição 5 da segunda linha.
		custom 0, r3, r0, r2
		addi r2, r15, 48
		custom 0, r3, r1, r2

		movia r2, 0b11001010	 #posição 11 da segunda linha.
		custom 0, r3, r0, r2
		addi r2, r16, 48
		custom 0, r3, r1, r2

		addi r3, r0, 9
		beq r16, r3, p2Win
		beq r15, r3, p1Win
		ret

p2Win:
		movia r2, message
		addi r3, r0, 0b00110010
		stb r3, 7(r2)
		br printWin
p1Win:
		addi r3, r0, 0b00110001
		movia r2, message
		stb r3, 7(r2)
		br printWin
printWin:
		#addi r2, r0, 0b0b00110100
		#custom 0, r3, r0, r1
		addi r2, r0, 0
		custom 0, r3, r0, r1
		movia r3, home
		custom 0, r3, r0, r3
		movia r3, message
again:
		ldb r4, 0(r3)
		custom 0, r4, r1, r4
		addi r4, r0, 13
		addi r2, r2, 1
		addi r3, r3, 1
		bne r2, r4, again
endgame:
		movia r3, button
waitReset:
		ldbio r2, 0(r3)
		bne r2, r1, waitReset
		br main



acelerador:
		addi r3, r0, 360
		beq r3, r10, acelerador1
		ret
acelerador1:
		addi r17, r17, 1
		addi r13, r13, 1
		addi r10, r0, 0
		ret


calcAngulo:
		beq r23, r0, p1D
		sub r3, r22, r19
		br ifs
p1D:
		sub r3, r22, r20
ifs:
		addi r2, r0, 69
		bgt r3, r2, S8
		addi r2, r0, 59
		bgt r3, r2, S7
		addi r2, r0, 49
		bgt r3, r2, S6
		addi r2, r0, 39
		bgt r3, r2, S5
		addi r2, r0, 29
		bgt r3, r2, S4
		addi r2, r0, 19
		bgt r3, r2, S3
		addi r2, r0, 9
		bgt r3, r2, S2
		bgt r3, r0, S1
		br anglRandom
S8:
		addi r13, r0, 4
		addi r12, r0, 1
		ret
S7:
		addi r13, r0, 3
		addi r12, r0, 1
		ret
S6:
		addi r13, r0, 2
		addi r12, r0, 2
		ret
S5:
		addi r13, r0, 1
		addi r12, r0, 1
		ret
S4:
		addi r13, r0, 1
		addi r12, r0, 1
		ret
S3:
		addi r13, r0, 2
		addi r12, r0, 2
		ret
S2:
		addi r13, r0, 3
		addi r12, r0, 1
		ret
S1:
		addi r13, r0, 4
		addi r12, r0, 1
		ret


randomInit:
		custom 1, r2, r0, r0
		and r2, r2, r1
		beq r0, r2, ladoE
		br updwr
ladoE:
		and r23, r0, r0
updwr:
		custom 1, r2, r0, r0
		and r2, r2, r1
		beq r0, r2, direcaoC
		br anglRandom
direcaoC:
		and r14, r0, r0
anglRandom:
		custom 1, r2, r0, r0
		addi r3, r0, 8
		beq r3, r2, S8
		addi r3, r0, 7
		beq r3, r2, S7
		addi r3, r0, 6
		beq r3, r2, S6
		addi r3, r0, 5
		beq r3, r2, S5
		addi r3, r0, 4
		beq r3, r2, S4
		addi r3, r0, 3
		beq r3, r2, S3
		addi r3, r0, 2
		beq r3, r2, S2
		addi r3, r0, 1
		beq r3, r2, S1
		ret

startMenu:
		movia r5, message2
		addi r3, r5, 12
		addi r2, r0, 0b10000010 #Posição 3 da primeira linha
		custom 0, r2, r0, r2

message2Loop:
		ldb r2, 0(r5)
		custom 0, r2, r1, r2
		addi r5, r5, 1
		bne r3, r5, message2Loop

		movia r5, message3
		addi r3, r5, 8
		addi r2, r0, 0b11000100 #Posição 5 da segunda linha
		custom 0, r2, r0, r2
message3Loop:
		ldb r2, 0(r5)
		custom 0, r2, r1, r2
		addi r5, r5, 1
		bne r3, r5, message3Loop

		movia r2, button #Esperar botão de start
startLoop:
		ldbio r3, 0(r2)
		addi r4, r0, 2
		beq r4, r3, go
		addi r4, r0, 3
		beq r3, r4, go
		br startLoop
