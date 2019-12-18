//VGA DRIVER
// Crystal & Havallon
// 02/12/2017
module vgaDriver(clock_50MHz, rst, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B, y1, y2, xb, yb, endFrame);
	
	input clock_50MHz;
	input rst;
	input [9:0] y1;
	input [9:0] y2;
	input [9:0] xb; //Posição da bola.
	input [9:0] yb;
	
	output VGA_HS; //Sinais de sync vertical e horizontal a serem transmitidos.
	output VGA_VS;
	output endFrame; //Indica que a área visivel acabou de terminar
	output [3:0] VGA_R; //Sinais RGB a serem transmitidos.
	output [3:0] VGA_G;
	output [3:0] VGA_B;
	
	wire [9:0] x; //Carregará informação da posição horizontal do pixel.
	wire [9:0] y; //Carregará informação da posição vertical do pixel.
	wire en; //Carregará a posição de pixel válido (pixel na área visível).
	
	wire rr; //Carregam o sinal correspondente a cor. 
	wire gg; //Para simplificar, foram utilizadas cores de máximo e mínimo rgb.
	wire bb; 
	
	wire frame_pulse; //Carrega a informação do vsync ao controlador rgb e à saída para VGA.
	
	wire clk25; //Sinal de clock dividido, ideal para a resolução de 640x480
	
	assign VGA_VS = frame_pulse; //Sinal de Sync vertical proveniente do controlador.
	assign VGA_R = {rr,rr,rr,rr}; //Cores geradas com máximos e/ou mínimos rgb.
	assign VGA_G = {gg,gg,gg,gg};
	assign VGA_B = {bb,bb,bb,bb};
	
	clk50to25 clk50to25 ( //Instância de divisor de clock.
		.rst(rst),
		.clk_in(clock_50MHz),
		.clk_out(clk25)
	);
	
	vgaSync vgaSync( //Instância de Controlador de Sincronismo.
		.clk(clk25),
		.rst(rst),
		.hsync(VGA_HS),
		.vsync(frame_pulse),
		.hpos(x),
		.vpos(y),
		.pxl_en(en),
		.endFrameIn(endFrame)
	);
	
	vgaPxlGen vgaPxlGen ( //Controlador RGB
		.clk(clk25),
		.frame_pulse(~frame_pulse),
		.rst(rst),
		.pxl_en(en),
		.x(x),
		.y(y),
		.r(rr),
		.g(gg),
		.b(bb),
		.y1(y1),
		.y2(y2),
		.xb(xb),
		.yb(yb)
	);
	
endmodule