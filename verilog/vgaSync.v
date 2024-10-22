module vgaSync(clk, rst, hsync, vsync, hpos, vpos, pxl_en, endFrameIn);

	input clk;
	input rst;
	output reg endFrameIn;
	output reg hsync; //Sinais para o vga.
	output reg vsync; 
	
	output reg [9:0] hpos; //Posição horizontal do pixel.
	output reg [9:0] vpos; //Posição vertical do pixel.
	
	output reg pxl_en; //Sinal de pixel válido.
	
	localparam hva = 640; //horizontal ativo.
	localparam hfp = 16;
	localparam hsp = 96;
	localparam hbp = 48;
	
	localparam vva = 480; //vertical ativo.
	localparam vfp = 11;
	localparam vsp = 2;
	localparam vbp = 31;
	
	// Pecorrendo a tela, pixel por pixel.
	always @ (posedge clk or posedge rst) begin
		if (rst) begin //reseta sinais de posição.
			hpos   <= 10'd0;
			vpos   <= 10'd0;
		end else begin
			if (hpos < (hva + hfp + hsp + hbp)) begin //caso o tempo da linha não tenha acabado
				hpos <= hpos + 10'd1; //Incrementa posição horizontal.
			end else begin
				hpos <= 10'd0; //reseta a posição *de* linha para 0, pois a anterior já foi percorrida.
				if (vpos < (vva + vfp + vsp + vbp)) begin //Caso não tenham acabado as posições verticais.
					
					if ( vpos > 470 && vpos < 481) begin
						endFrameIn <= 1'd1;
					end
					else begin
						endFrameIn <= 1'd0;
					end
				
				
					vpos <= vpos + 10'd1; //Pula para a próxima posição vertical (próxima linha).
				end else begin
					vpos <= 10'd0; //volta para a primeira linha (posição 0 vertical), caso tenha acabado o tempo de sync vertical (fim da última linha).
				end
			end
		end
	end
	
	// Gerando a sincronia horizontal e vertical
	always @ (posedge clk or posedge rst) begin
		if (rst) begin //reseta sinais de sincronia.
			hsync  <= 1'b0;
			vsync  <= 1'b0;
		end else begin
			if ((hpos > (hva + hfp)) && (hpos <(hva + hfp +hsp))) begin //Caso esteja em pulso de sync horizontal.
				hsync <= 1'b0;
			end else begin
				hsync <= 1'b1; //Caso não esteja em pulso de sync horizontal.
			end
			
			if ((vpos > (vva + vfp)) && (vpos < (vva + vfp +vsp))) begin //Caso esteja em pulso de sync vertical, definindo ciclo de novo quadro.
				vsync <= 1'b0; //Caso não esteja em pulso de sync vertical.
			end else begin
				vsync <= 1'b1;
			end
		end
	end
	
	// Definindo a área visivel
	always @ (posedge clk or posedge rst) begin
		if (rst) begin //reseta o sinal de pixel válido.
			pxl_en <= 1'b0;
		end else begin
			if (hpos > hva || vpos > vva) begin //Caso não esteja em área válida de vídeo.
				pxl_en <= 1'b0;
			end else begin //Caso esteja em área válida de vídeo.
				pxl_en <= 1'b1;
			end
		end
	end
	
endmodule