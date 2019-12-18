module vgaPxlGen (clk, frame_pulse, rst, pxl_en, x, y, r, g, b, y1, y2, xb, yb);

	input clk;
	input rst;
	input pxl_en;
	input frame_pulse;
	input [9:0]  x;
	input [9:0]  y;
	
	input [9:0] y1;

	input [9:0] y2;
	
	input [9:0] xb; 
	input [9:0] yb;
	
	output reg r;
	output reg g;
	output reg b;
	
	reg [9:0] p1Y;
	
	reg [9:0] p2Y;
	
	reg [9:0] bX; //registrador posição bola.
	reg [9:0] bY;
	
	
	always @ (posedge clk or posedge rst) begin
		if (rst) begin	//reseta registradores.
			p1Y <= 10'd0;
			p2Y <= 10'd0;
			bX  <= 10'd0;
			bY  <= 10'd0;
		end else begin	//inicia os registradores de posição.
			if (frame_pulse) begin
				p1Y <= y1;
				p2Y <= y2;
				bX  <= xb;
				bY  <= yb;
			end
		end
	end
	
	// Deixando a tela vermelha
	always @ (posedge clk or posedge rst) begin
		if (rst) begin	//reseta saídas rgb.
			r     <= 1'b1;
			g     <= 1'b0;
			b     <= 1'b1;
		end else begin
			if (pxl_en) begin //video ativo
				if(x >= 0 && x < 10 && y >= p1Y && y < p1Y + 80)begin //barra 1 pintada de branco.
					r <= 1'b1;
					g <= 1'b1;
					b <= 1'b1;
				end else if (x >= 630 && x < 640 && y >= p2Y && y < p2Y + 80) begin //barra2 pintada de branco.
					r <= 1'b1;
					g <= 1'b1;
					b <= 1'b1;
				end else if (x >= bX && x < bX+10 && y >= bY && y < bY + 10) begin //quadrado (bola) pintado de branco.
					r <= 1'b1;
					g <= 1'b1;
					b <= 1'b1;
				//end else if (y < 8 || y > 471) begin
				//	r <= 1'b1;
				//	b <= 1'b1;
				//	g <= 1'b1;
				end else begin	//fundo pintado de preto.
					r <= 1'b0;
					b <= 1'b1;
					g <= 1'b0;
				end
			end else begin //fora do vídeo ativo.
				r <= 1'b0;
				g <= 1'b1;
				b <= 1'b0;
			end
		end
	end
	
endmodule