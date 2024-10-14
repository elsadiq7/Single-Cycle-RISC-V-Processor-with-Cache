module PC (
	input clk, RST_n, EN,
	input [31:0] PCNext,
	output reg [31:0] PC
);

	always @(posedge clk or negedge RST_n) begin
		if(~RST_n)
			PC <= 32'b0;
		else
			if(EN)
				PC <= PCNext;
	end
	
endmodule
