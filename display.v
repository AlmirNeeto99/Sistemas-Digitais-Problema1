
module display(
  clk,
  clk_en,
  reset,
  dataA,
  dataB,
  iniciar,
  done,
  result,
  rs,
  rw,
  enable,
  data
  );
  //Declarando entradas
  input clk, clk_en, reset, iniciar;
  input [31:0] dataA, dataB;
  //Declarando saídas
  output reg [7:0] data;
  output reg rs, enable, done;
  output reg [31:0] result;
  output rw;
  //Declarando variáveis auxiliares
  reg [15:0] contador;
  reg [1:0] estadoAtual; //Guarda o estado atual do circuito (parado, ocupado, acabou)

  assign rw = 1'b0; //Seta a função sempre de escrita (não será necessário ler do display)

  always @(posedge clk) //Executa o loop sempre que acontece uma borda de subida
  //20ns = 1 clk
  begin
    if(reset) //Se reset == 1 limpa todos os dados.
      begin
          estadoAtual <= 2'b00; // Define o estado como livre/ocioso
          contador <= 16'd0; //Zera o contador
          result <= 32'd0;
          data <= 8'b0; //Limpa o registrador de saida
          rs <= 1'b0;
          enable <= 1'b1;
      end
    else
      begin
        if(clk_en)
          begin //Inicio do 'if' (clk_en)
            if(estadoAtual == 2'b00) //Ocioso
              begin
                done <= 1'b0; // Operação ainda não foi finalizada
                enable <= 1'b1; //Seta o enable
                if(iniciar == 1'b1)
                  begin
                    estadoAtual <= 2'b01; //Ocupado
                    rs <= dataA[0]; //Verifica se é comando ou dado
                    data <= dataB[7:0]; // Copia os dados da entrada para o registrador de saída
                    contador <= 16'd0; //Zera o contador
                  end //Fim do 'if' (iniciar == 1'b1)
              end //Fim do 'if' (estadoAtual)
              else if (estadoAtual == 2'b01)
                begin //Inicio do 'if' OCUPADO
                  if(contador < 16'd1316)
                    begin //Inicio 'if' que verifica contador
                      contador <= contador + 16'd1; //Incrementa o contador em 1;
                    end //Fim do 'if' que verifica contador
                  else
                    begin //Inicio do else
                      estadoAtual <= 2'b11; //Já aguardou o tempo necessário
                      contador <= 16'd0; //Zera contador
                      enable <= 1'b0; //Altera o sinal do enable para permitir a passagem dos dados.
                    end //Fim do else
                end //Fim do 'if' OCUPADO
              else if (estadoAtual == 2'b11)
                begin //Inicio do 'if' FINAL
                  if(contador < 16'd54001)
                    begin //Inicio 'if' que verifica contador
                      contador <= contador + 16'd1; //Incrementa o contador em 1;
                    end //Fim do 'if' que verifica contador
                  else
                    begin //Inicio do else
                      estadoAtual <= 2'b00; //Altera o estado para ocioso.
                      done <= 1'b1; //Informa ao nios que a instrução terminou
                      result <= 32'd38; //Se for 1 'escreveu'
                      contador <= 16'd0; //Zera contador
                    end //Fim do else
                end //Fim do 'if' FINAL
          end //Fim do 'if' (clk_en)
      end
    end
  endmodule
