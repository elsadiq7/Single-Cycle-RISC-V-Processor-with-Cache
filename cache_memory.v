module cache_memory #(
	/*
	parameter MEM_SIZE = 4096,
	parameter CACHE_SIZE = 512,
	parameter BLOCK_SIZE = 16
	*/
) ( input clk,
    input rst_n,
	input refill_c, update_c, read_c,			// Inputs from Cache Controller
	input [4:0] index,							// Number of Blocks = 512/16 = 32 Blocks
	input [1:0] offset,							// Number of Words/Block = 4 Words
	input [127:0] DataBlock_m,					// From Data Memory : 16 bytes
	input [31:0] wdata,
	output reg [31:0] rdata
);

	/////////////////////////////////////////////// Defining Local Parameters ///////////////////////////////////////////////
	/*
	localparam NUM_BLOCKS_MAPPED = MEM_SIZE/CACHE_SIZE;
	localparam NUM_BLOCKS_CACHE = CACHE_SIZE/BLOCK_SIZE;
	*/
	///////////////////////////////////////////// Defining Internal Wires/Regs /////////////////////////////////////////////
    integer i;
	reg [31:0] cache [0:127];		// 32 bits/word, 32 blocks * 4 words/block : Depth = 128

	////////////////////////////////////////////////////// Main Logic //////////////////////////////////////////////////////
	always @(*) begin
		// Reading from Cache ----- Read Hit/Read Miss
		if(read_c | refill_c)
			rdata = cache[{index, offset}];
		else
			rdata = 0;
	end

	always @(negedge clk) begin
		// Receiving Data Block ----- Read Miss

		if(refill_c) begin
			cache[{index, 2'b00}] <= DataBlock_m[127:96];
			cache[{index, 2'b01}] <= DataBlock_m[95:64];
			cache[{index, 2'b10}] <= DataBlock_m[63:32];
			cache[{index, 2'b11}] <= DataBlock_m[31:0];
		end

		// Updating Cache Content ----- Write Hit
		if(update_c)
			cache[{index, offset}] <= wdata;
	end

endmodule