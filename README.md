# Sistemas-Digitais-Problema1
Este é o repositório para o produto do Primeiro Problema do MI - Sistemas Digitais.

**Sistemas utilizados:**
* NIOS 2
* Quartus 13.1 Web Edition
* Altera Monitor 13.0 
* Placa FPGA Mércurio IV com Cyclone IV (EP4CE30F23C7)

****

**Execução do Sistema:**
1. Abrir o projeto 'problema1.qpf' no Quartus 13.1;
2. Conectar a placa FPGA no computador via USB no modo de configuração 'prog FPGA'; (OBS: não usar a porta USB 3.0 do computador).
3. No Quartus, vá em Tools>Programmer>Currently selected hardware: USB: Blaster;
4. Então, pressione START. Nosso processador foi carregado na FPGA;
5. Abrir o projeto do NIOS no Altera Monitor, presente neste repositório;
6. Compilar e carregar o Assembly via Altera Monitor;
7. Após o carregamento do Assembly, apertar 'start' para iniciar a execução do Assembly na placa;
8. Logo após a execução, os LED's da placas apagarão e aparecerão no display o menu.

****

**Utilização do Sistema:**
1. key[2] -> botão 'up'
2. key[5] -> botão 'down'
3. key[8] -> botão 'select'
4. key[11] -> botão 'return'

Os botões estão na última coluna da esquerda para a direita, em ordem, de cima para baixo;
PS.: Informações mais detalhadas sobre a física da placa podem ser encontradas em seu datasheet.

5. Pressionar o botão 'down' faz a setinha vai mudar de opção, sentido 'baixo';
6. Pressionar o botão 'up' faz a setinha vai mudar de opção, sentido 'cima';
7. Ao pressionar o botão 'select' o menu mudará para outra tela, com a mensagem 'LED' e o número da opção selecionada logo abaixo e um led acenderá na placa;

Os LED's selecionados foram os cinco primeiros LED's da primeira coluna da placa.

8. Pressionar o botão 'return' faz o display exibir o menu novamente e apagar o LED.
