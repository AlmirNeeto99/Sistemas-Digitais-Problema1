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
3. No Quartus, vá em Tools>Programmer>Currently selected hardware: USB - Blaster;
4. Então, pressione START. O Nios II softcore foi carregado na FPGA juntamente com a custom instruction desenvolvida;
5. Abrir o projeto "Codigo.ncf" para NIOS no Altera Monitor, presente na pasta "Assembly" neste repositório;
6. Ir em Actions>Load, para descarregar o Assembly já compilado no Nios via Altera Monitor;
7. Após o carregamento do Assembly, apertar 'start' para iniciar a execução do Assembly;
8. Logo após a execução, os LED's da placas apagarão e o menu do sistema criado aparecerá no display.

****

**Utilização do Sistema:**
1. key[2] -> botão 'up'
2. key[5] -> botão 'down'
3. key[8] -> botão 'select'
4. key[11] -> botão 'return'

1, 2, 3 e 4 referem-se a botões presentes na última coluna da esquerda para a direita ordenados de cima para baixo;
PS.: Informações mais detalhadas sobre a localização e demais partes físicas da placa podem ser encontradas em seu manual.

5. Pressionar o botão 'down' mudará a opção a ser selecionada para a opção imediatamente inferior, caso haja;
6. Pressionar o botão 'up' mudará a opção a ser selecionada para a opção imediatamente superior, caso haja;
7. Ao pressionar o botão 'select', exibir-se-á uma mensagem referente à opção selecionada e será acesa uma 'LED' correspondente;

Os LED's selecionados foram os cinco primeiros LED's da primeira coluna da placa e correspondem, em sequência, às cinco opções passíveis de escolha.

8. Pressionar o botão 'return' faz o display exibir o menu novamente e apagar o LED.
