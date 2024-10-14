module instruction_memory # (
    parameter DEPTH = 256
) (
    input [$clog2(DEPTH)+1:0] A,
    output reg [31:0] RD
);
    reg [31:0] i_mem [0:DEPTH-1];

    // Combinational block for reading memory
    always @(*) begin
        RD = i_mem[A[$clog2(DEPTH)+1:2]];
    end

endmodule










// module instruction_memory # (
// 	parameter DEPTH = 256
// ) (
// 	input clk, rst_n, Set_instr,
// 	input [31:0] input_instruction,
// 	input [$clog2(DEPTH)+1:0] A,
// 	output [31:0] RD
// );
// 	reg [31:0] i_mem [0:DEPTH-1];
// 	reg [$clog2(DEPTH)-1:0] instruction_count;

// 	/*
// 	initial begin
// 		$readmemh("instruction_mem.txt", i_mem);
// 	end
// 	*/
// always @(posedge clk or negedge rst_n) begin
// 		if(~rst_n)
// 			instruction_count <= 0;
// 		else begin
// 			if(Set_instr) begin
// 				i_mem[instruction_count] <= input_instruction;
// 				if(instruction_count == DEPTH)
// 					instruction_count <= 0;
// 				else
// 					instruction_count <= instruction_count + 1;
// 			end
// 		end
// 	end

// 	/*
// 		PC is incremented by 4 each step to point at the beginning of a specific instruction
// 		To read instructions line by line from the text file
// 		Address: 0 > line 0
// 		Address: 4 > line 1
// 		Address: 8 > line 2
// 		Address: C > line 3
// 		This is translated to shifting the address by 2, or discarding the last 2 bits.
// 		Address: 8 (0000 1000) > Shift by 2 > line (0000 0010)
// 		Address: C (0000 1100) > Shift by 2 > line (0000 0011)
// 	*/
// 	assign RD = i_mem[A[$clog2(DEPTH)+1:2]];
// endmodule
