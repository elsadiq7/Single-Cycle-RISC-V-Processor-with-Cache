module ALU(i_type,op, SrcA,SrcB,ALUControl,ALUResult,branch_signal);
// paramaters 
parameter size=32;
// in outs
input i_type;
input [size-1:0] SrcA,SrcB;
input [3:0] ALUControl;
input [6:0] op;
output reg [size-1:0] ALUResult;
output reg branch_signal;
//comp circuit


// Combinational circuit
always @(*) begin
        case (ALUControl)
            4'b0000: begin
                ALUResult = SrcA + SrcB; // add
                branch_signal = (ALUResult == 32'b0);
            end
            4'b0001: begin
                ALUResult = SrcA - SrcB; // sub
                branch_signal = (ALUResult == 32'b0);
            end
            4'b0010: begin
                ALUResult = SrcA & SrcB; // and
                branch_signal = (ALUResult == 32'b0);
            end
            4'b0011: begin
                ALUResult = SrcA | SrcB; // or
                branch_signal = (ALUResult == 32'b0);
            end
            4'b0100: begin
                ALUResult = SrcA ^ SrcB; // xor
                branch_signal = (ALUResult == 32'b0);
            end
            4'b0101: begin
                if(i_type)  ALUResult = SrcA << SrcB[4:0]; // shift left
                else         ALUResult = SrcA << SrcB; // shift left
                branch_signal = (ALUResult == 32'b0);
            end
            4'b0110: begin
                if(i_type) ALUResult = SrcA >> SrcB[4:0]; // logical shift right
                else       ALUResult = SrcA >> SrcB;
                branch_signal = (ALUResult == 32'b0);
            end
            4'b0111: begin
                 if(i_type) ALUResult = SrcA >>> SrcB[4:0]; // // arithmetic shift right
                else       ALUResult = SrcA >>> SrcB;
                branch_signal = (ALUResult == 32'b0);
            end
            4'b1000: begin
                ALUResult = $signed(SrcA) < $signed(SrcB); // signed less than
                branch_signal = (op == 7'b1100011 && ALUResult == 32'd1) ? 1 : 0; // branch
            end
            4'b1001: begin
                ALUResult = SrcA < SrcB; // unsigned less than
                branch_signal = (op == 7'b1100011 && ALUResult == 32'd1) ? 1 : 0; // branch
            end
            4'b1010: begin
                ALUResult = $signed(SrcA) > $signed(SrcB); // signed greater than
                branch_signal = (op == 7'b1100011 && ALUResult == 32'd1) ? 1 : 0; // branch
            end
            4'b1100: begin
                ALUResult = (SrcA != SrcB); // unsigned not equal
                branch_signal = (op == 7'b1100011 && ALUResult == 32'd1) ? 1 : 0; // branch
            end
            4'b1101: begin
                ALUResult = $signed(SrcA) >= $signed(SrcB); // signed greater or equal
                branch_signal = (op == 7'b1100011 && ALUResult == 32'd1) ? 1 : 0; // branch
            end
            4'b1110: begin
                ALUResult = SrcA >= SrcB; // unsigned greater or equal
                branch_signal = (op == 7'b1100011 && ALUResult == 32'd1) ? 1 : 0; // branch
            end
            4'b1111: begin
                ALUResult = (SrcA == SrcB); // equal
                branch_signal = (op == 7'b1100011 && ALUResult == 32'd1) ? 1 : 0; // branch
            end
            default: begin
                ALUResult = 0;
                branch_signal=0;
            end
        endcase
    end
endmodule
