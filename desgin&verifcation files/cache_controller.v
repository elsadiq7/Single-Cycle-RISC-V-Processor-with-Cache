module cache_controller( tag, index, memread, memwrite, clk, rst_n, ready,read, read_mem, write_mem, stall, update, refill) ;  
 
 //-------------Ports Decleration------------------ 
    input wire [2 : 0] tag ; 
    input wire [4 : 0] index ; 
    input wire memread; 
    input wire memwrite; 
    input wire clk;
    input wire rst_n ; 
    input wire ready; 
    output reg read_mem; 
    output reg write_mem;
    output reg stall;
    output reg read ; 
    output reg update; 
    output reg refill;

    
    reg [3:0] lookup_table [31:0] ; //32 slots 4 bits each Valid + 3Tag bits

 //------------------ Internal Wires Declaration ------------------- 
    wire hit ;
    wire [3:0] slot ;

    assign slot = lookup_table[index] ;  
    assign hit = (slot [2:0] == tag) ? slot[3] : 1'b0 ;

// FSM Template
    reg [1:0] current_state, next_state;

// State definitions
    localparam IDLE = 2'b00 ;
    localparam READ_HIT = 2'b01 ;
    localparam READ_MISS = 2'b10 ;
    localparam WRITE = 2'b11 ;
  
   integer i;

// State transition logic
    always @( negedge  clk or negedge rst_n) begin 
        if (~rst_n) begin
            current_state <= IDLE ;
            for (i = 0; i < 32; i = i + 1) begin
                lookup_table[i] <= 4'b0000;
            end
        end 
        else begin
            current_state <= next_state;
        end
    end

// Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                // Define transitions here
                if(memwrite) begin
                    next_state = WRITE ;
                end     
                else if (memread) begin
                    if (hit) 
                        next_state = READ_HIT ;
                    else 
                       next_state = READ_MISS ; 
                end    
                else
                    next_state = IDLE ;               
            end   
            READ_HIT: begin
                // Define transitions here
                if(memwrite) begin
                    next_state = WRITE ;
                end     
                else if (memread) begin
                    if (hit) 
                        next_state = READ_HIT ;
                    else 
                       next_state = READ_MISS ; 
                end    
                else
                    next_state = IDLE ; 
            end
            READ_MISS : begin
                if (ready) 
                    next_state = READ_HIT ;
                else 
                    next_state = READ_MISS ;
            end
            WRITE: begin
                if (ready)
                    next_state = IDLE ;
                else 
                    next_state = WRITE ;
            end

            default: next_state = IDLE;
        endcase
    end

//Control Signals logic and table configuration
    always @(*) begin
        case (current_state)
            IDLE: begin
                stall = 0 ;
                read = 0 ;
                read_mem =0;
                write_mem = 0;
                refill =0 ;
                update = 0; 
            end
            READ_HIT: begin
                stall = 0 ;
                read = 1 ;
                read_mem =0;
                write_mem = 0;
                refill =0 ;
                update = 0;
            end
            READ_MISS : begin
                stall = 1 ;
                read = 0 ;
                read_mem = 1;
                write_mem = 0;
                update = 0 ;
                //Updating after a Read Miss case 
                if (ready) begin
                    refill = 1 ;
                    lookup_table[index] <={1'b1,tag} ;
                end
                else begin
                    refill = 0 ;
                    lookup_table[index] <= lookup_table[index];
                end
            end
            WRITE: begin
                stall = 1 ;
                read = 0 ;
                read_mem =0;
                write_mem = 1;
                refill =0 ;
               if (hit) begin  
                    update = 1; 
               end
               else begin
                   update =0;
               end
            end    
            default: begin 
                stall = 0 ;
                read = 0 ;
                read_mem =0;
                write_mem = 0;
                refill =0 ;
                update = 0; 
            end    
        endcase
    end
endmodule
