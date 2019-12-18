module clk50to25 (rst, clk_in, clk_out);
	
	input rst;
	input clk_in;
	
	output reg clk_out;
	
	always @ (posedge clk_in or posedge rst) begin
		if (rst) begin
			clk_out <= 1'b0; 
		end else begin //uma borda a cada de subida. Um pulso = 2 bordas, logo, metade do ciclo.
			clk_out <= ~clk_out;
		end
	end

endmodule