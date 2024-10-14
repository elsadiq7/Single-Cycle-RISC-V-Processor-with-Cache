module cache_top (clk,rst_n,mem_read,mem_write,word_address,data_in,stall,data_out) ;
	
	input wire clk ,rst_n,mem_read,mem_write ;
	input wire [9:0] word_address ;
	input wire [31:0] data_in ;
	output wire stall ;
	output wire [31:0] data_out ;

	wire ready , read ,read_mem, write_mem, update ,refill;
	wire [2:0] tag ;
	wire [4:0] index ;
	wire [1:0] offset ;
	wire [127:0] main_mem_block ;

	assign tag  = word_address [9:7] ;
	assign index = word_address [6:2] ;
	assign offset = word_address [1:0] ;

	cache_controller controller ( .tag(tag), .index(index), .memread(mem_read), .memwrite(mem_write),
							.clk(clk) , .rst_n(rst_n), .ready(ready) , .read(read), .read_mem(read_mem), .write_mem(write_mem),
							.stall(stall), .update(update), .refill(refill) ) ;

	cache_memory  cache_mem (.clk(clk),.rst_n(rst_n),.refill_c(refill), .update_c(update), .read_c(read), .index(index),
						.offset(offset), .DataBlock_m(main_mem_block),.wdata(data_in),.rdata(data_out));	
	
	Main_Memory main_mem ( .clk(clk) ,.rst(rst_n), .read_mem(read_mem), .address(word_address), .write_mem(write_mem),
							.data_in(data_in), .ready(ready), .block_data(main_mem_block) ) ;

endmodule 	