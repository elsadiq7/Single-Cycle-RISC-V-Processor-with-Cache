module  Main_Decoder(op,branch_signal,PCSrc,ResultSrc,MemWrite,MemRead,ALUSrc,ImmSrc,RegWrite,i_type);

   // inputs
    input [6:0] op;
    input branch_signal;
    //outputs 
    output reg [1:0] PCSrc, ResultSrc;
    output reg MemWrite, MemRead;
    output reg  ALUSrc;
    output reg [1:0] ImmSrc;
    output reg RegWrite;
    output reg  i_type; //signal to control for alu shift due to immdetia shift by only 5 bits 
    // internal
    reg branch, jal, jalr;

always @(*) begin
        case(op)
            // I-type op 3  lw    rd, imm(rs1)
            7'b0000011: begin
                branch = 1'b0;
                ResultSrc = 2'b01;
                MemWrite = 1'b0;
                MemRead = 1'b1;
                ALUSrc = 1'b1;
                ImmSrc = 2'b00;
                RegWrite = 1'b1;
                jal = 1'b0;
                jalr = 1'b0;
                i_type=1'b0;
            end
            
            // I-type op 19
            7'b0010011: begin
                branch = 1'b0;
                ResultSrc = 2'b00;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                ALUSrc = 1'b1;
                ImmSrc = 2'b00;
                RegWrite = 1'b1;
                jal = 1'b0;
                jalr = 1'b0;
                i_type=1'b1; 
            end

            // S-type op 35 sw
            7'b0100011: begin
                branch = 1'b0;
                ResultSrc = 2'b0;
                MemWrite = 1'b1;
                MemRead = 1'b0;
                ALUSrc = 1'b1;
                ImmSrc = 2'b01;
                RegWrite = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                i_type=1'b0;

            end

            // R-type
            7'b0110011: begin
                branch = 1'b0;
                ResultSrc = 2'b00;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                ALUSrc = 1'b0;
                ImmSrc = 2'b00;
                RegWrite = 1'b1;
                jal = 1'b0;
                jalr = 1'b0;
                i_type=1'b0;

            end

            // B-type
            7'b1100011: begin
                branch = 1'b1;
                ResultSrc = 2'b00;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                ALUSrc = 1'b0;
                ImmSrc = 2'b10;
                RegWrite = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                i_type=1'b0;
               
            end

            // JAL
            7'b1101111: begin
                branch = 1'b0;
                ResultSrc = 2'b10;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                ALUSrc = 1'b0;
                ImmSrc = 2'b11;
                RegWrite = 1'b1;
                jal = 1'b1;
                jalr = 1'b0;
                i_type=1'b0;

            end

            // JALr
            7'b1100111: begin
                branch = 1'b0;
                ResultSrc = 2'b10;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                ALUSrc = 1'b1;
                ImmSrc = 2'b00;
                RegWrite = 1'b1;
                jal = 1'b0;
                jalr = 1'b1;
                i_type=1'b0;

            end

            default: begin
                branch = 1'bx;
                ResultSrc = 1'bx;
                MemWrite = 1'bx;
                MemRead = 1'bx;
                ALUSrc = 1'bx;
                ImmSrc = 2'bxx;
                RegWrite = 1'bx;
                jal = 1'bx;
                jalr = 1'bx;
                i_type=1'bx;

            end
        endcase

        // Calculate PCSrc based on branch and branch_signal flag
        PCSrc = ((branch & branch_signal) | jal) ? 2'b01 : jalr ? 2'b10 : 2'b00;
    end

endmodule

