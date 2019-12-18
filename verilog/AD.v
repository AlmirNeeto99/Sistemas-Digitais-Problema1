//CONVERSOR ADC MAX 1379 SPI 
// Havallon
// 03/12/17
//Revisao
//Fabio
//14/12/17
module AD(
	RESET_n, 
	CLOCK_50MHz, 
	ADC_OUT, 
	ADC_CNVST, 
	ADC_CS_N, 
	ADC_REFSEL, 
	ADC_SCLK, 
	ADC_SD, 
	ADC_UB,
	ADC_SEL,
	BUSY,
	DATA_AD0,
	DATA_AD1,
	);
	
	input RESET_n;
	input CLOCK_50MHz;
	input [1:0]ADC_OUT;
	output reg ADC_CNVST;//1 = sem conversao, 0 = inicia uma conversao
	output ADC_CS_N;//chip enable
	output ADC_REFSEL;
	output reg ADC_SCLK;
	output ADC_SD;
	output ADC_UB;
	output ADC_SEL;
	output reg BUSY;
	output reg [7:0] DATA_AD0;
	output reg [7:0] DATA_AD1;

	assign ADC_CS_N   = 1'b0;//habilita o modulo
	assign ADC_REFSEL = 1'b1;//define a tensao de referencial como externa
	//configura o modulo como dual e disponibiliza os dados dos conversores ao mesmo tempo na saida
	assign ADC_SD     = 1'b0;
	assign ADC_UB     = 1'b0;
	assign ADC_SEL    = 1'b0;
	
	reg [1:0] counter;
	reg [2:0] latencia;
	reg [19:0] timing;
	reg [11:0] data0;
	reg [11:0] data1;
	reg [3:0]i; 
	
	//Gerando o pulso de SCLK de 8.333MHz - periodo 120.004800192ms
	always @ (posedge CLOCK_50MHz) 
	begin
		if (!RESET_n) begin
			ADC_SCLK    <= 1'b0;
			counter 		<= 2'd0;
		end 
		else 
		begin
			if (counter == 2'd3) 
			begin
				ADC_SCLK <= ~ADC_SCLK;
				counter	<= 2'd0;
			end
			else 
			begin
				counter <= counter + 2'd1;
			end
		end
	end
	
	always @ (posedge ADC_SCLK) 
	begin
		if (!RESET_n) 
		begin
			ADC_CNVST 	<= 1'b1;
			BUSY 		<= 1'b0;
			data0     	<= 12'd0;
			data1     	<= 12'd0;
			latencia  	<= 3'd0;
			timing    	<= 5'd0;
			i         	<= 4'd12;
		end 
		else 
		begin//inicia a conversao imediatamente depois do reset
			if (ADC_CNVST) 
			begin
				ADC_CNVST 	<= 1'b0;
				BUSY		<= 1'b1;;
				timing    	<= 5'd0;
				latencia  	<= 3'd0;
				i         	<= 4'd12;
			end
			else 
			begin//apos o 
				if (latencia == 3'd3) //verificando o 5 pulso para iniciar a leitura
				begin
					if(i>3'd0)
					begin
						data0[i- 1'b1] <= ADC_OUT[0];
						data1[i- 1'b1] <= ADC_OUT[1];
						i <= i - 1'b1;
					end
					else
					begin
						DATA_AD0 	<= data0[11:4];
						DATA_AD1 	<= data1[11:4];
						latencia 	<= 3'd0;
						ADC_CNVST 	<= 1'b1;
						BUSY 			<= 1'b0;
					end
				end 
				else 
				begin
					latencia <= latencia + 1'd1;
				end
			end
		end
	end
endmodule