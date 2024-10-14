
module Control_Unit(op,funct3,funct7,branch_signal,PCSrc,ResultSrc,MemWrite,MemRead,ALUControl,ALUSrc,ImmSrc,RegWrite,i_type);

// inputs
input [6:0] op;

input [2:0] funct3;
input  funct7;
input branch_signal;
//outputs 
output [1:0] PCSrc;
output [1:0] ResultSrc;
output MemWrite, MemRead;
output  [3:0] ALUControl;
output ALUSrc;
output [1:0] ImmSrc;
output  RegWrite;
output i_type;

 ALU_Decoder ALU_Decoder(.op(op),.funct3(funct3),.funct7(funct7),.ALUControl(ALUControl));
  Main_Decoder Main_Decoder(.op(op),.branch_signal(branch_signal),.PCSrc(PCSrc),.ResultSrc(ResultSrc),
                           .MemWrite(MemWrite),.MemRead(MemRead),.ALUSrc(ALUSrc),.ImmSrc(ImmSrc),.RegWrite(RegWrite),.i_type(i_type));




endmodule
