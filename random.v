module random(
  clk,
  clk_en,
  reset,
  start,
  dataA,
  dataB,
  done,
  result,
);

input clk, reset, clk_en, start;
input [31:0] dataA, dataB;

output reg done;
output reg[31:0] result;

integer count = 0;
always @(posedge clk)
  begin
  	count = count + 1;
  	if(reset)
  		count = 0;
    if(count == 9)
        count = 0;
    else
    begin
	    if(clk_en)
	    	begin
		      result <= count;		      
		      done <= 1'b1;
	    end
    end
  end
endmodule
