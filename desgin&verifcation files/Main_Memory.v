module Main_Memory ( clk,rst,read_mem,address,write_mem,data_in,ready,block_data) ;

////parameters
parameter address_size=10;
parameter word_size=32;
parameter block_size=128;
localparam mem_depth=2**address_size;

//// input ports
input wire clk;
input wire rst;
input wire read_mem;
input wire   [address_size-1:0]  address;
input wire write_mem;
input wire   [word_size-1:0]  data_in;

//// output ports 
output reg ready;
output reg   [block_size-1:0]  block_data;


//// internal_wires
reg [2-1:0]  counter_value_read,counter_value_write;
reg continue_read,continue_write;


/// memory
reg [word_size-1:0]  ram [0:mem_depth-1];

// // loop variables
integer i;

// comb logic
always @(*) begin
    //////////Enter your logic here//////////
    continue_read=(counter_value_read>= 1); //used to continuse read  delay ready for four cycle
    continue_write=(counter_value_write>= 1); //used to continuse write delay ready for four cycle
    // counter for read and counter and counter for write to avoid blocking reading and just only write by continue 

end


//seq logic
always @(posedge clk or negedge rst) begin
    if (~rst) begin
        counter_value_read<=2'b00;  
        counter_value_write<=2'b00;
        ready<=1'b0;
        block_data<=128'd0;
    end   

    else if (write_mem||continue_write)begin
 
        counter_value_read<=2'b00;  
        counter_value_write<=counter_value_write+1;
        ram[address]<=data_in;
        ready<=(counter_value_write==2'b11);
    end

    else if (continue_read||read_mem)begin 
       block_data <= {ram[{address[address_size-1:2], 2'b00}],
                      ram[{address[address_size-1:2], 2'b01}],
                      ram[{address[address_size-1:2], 2'b10}],
                      ram[{address[address_size-1:2], 2'b11}]};
        counter_value_read<=counter_value_read+1;  
        counter_value_write<=2'b00;        
        ready<=(counter_value_read==2'b11);
    end
    else begin
           ready<=1'b0;
           counter_value_read<=2'b00;  
           counter_value_write<=2'b00;
        end   
        
 end
        
endmodule