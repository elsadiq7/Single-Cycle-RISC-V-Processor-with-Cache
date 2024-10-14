module ALU_Decoder(op,funct3,funct7,ALUControl);
     // inputs
    input [6:0] op;
    input [2:0] funct3;
    input  funct7;
    // outputs
    output reg [3:0] ALUControl;
    
    
always @(*) begin
         case(op)
             // I-type op 3  lw    rd, imm(rs1)
             7'b0000011: begin
                   ALUControl=4'b0000;  // lw
             end
             
             // I-type op 19
             7'b0010011: begin
                   case(funct3) 
                     3'b000:ALUControl=4'b0000; //addi  
                     3'b001:ALUControl=4'b0101; //slli  shift left logical immediate
                     3'b010:ALUControl=4'b1000; //slti    set less than immediate
                     3'b011:ALUControl=4'b1001; //sltiu   set less than immediate unsigned
                     3'b100:ALUControl=4'b0100;//xori
                     3'b101:  begin 
                              if(funct7)
                                   ALUControl= 4'b0111; //srai   shift right arithmetic imm.
                              else 
                                    ALUControl= 4'b0110;//slai   shift right logical immediate
                              end
                     3'b110:ALUControl=4'b0011;//ori
                     3'b111:ALUControl=4'b0010;//andi
                     default: ALUControl=4'bxxxx;
                     endcase
             end
 
             // S-type op 35 sw
             7'b0100011: begin
                    ALUControl=4'b0000; //sw 
             end
 
             // R-type
             7'b0110011: begin
                  case(funct3) 
                               3'b000: begin 
                                    if(funct7) ALUControl=4'b0001; // sub
                                       else  ALUControl=4'b0000;  //add
                                       end
                               3'b001:ALUControl= 4'b0101; // sll  shift left logical
                               3'b010:ALUControl=4'b1000;//slt     set less than
                               3'b011:ALUControl=4'b1001;//sltu    set less than unsigned
                               3'b100:ALUControl= 4'b0100;//xor
                               3'b101:  begin 
                                        if(funct7)
                                             ALUControl= 4'b0111; //sra  shift right arithmetic
                                        else
                                              ALUControl= 4'b0110;//srl  shift right logical
                                        end
                               3'b110:ALUControl=4'b0011;//or
                               3'b111:ALUControl=4'b0010;//and
                               default: ALUControl=4'bxxxx;
                               endcase    

             end
 
             // B-type
             7'b1100011: begin
                     case(funct3) 
                                       3'b000: ALUControl=4'b1111;  // branch if =
                                       3'b001:ALUControl= 4'b1100;  // branch if ≠
                                       3'b100:ALUControl=4'b1000;   //branch if <
                                       3'b101: ALUControl= 4'b1101; //branch if ≥ 
                                       3'b110:ALUControl= 4'b1001;  //branch if < unsigned 
                                       3'b111:ALUControl=4'b1110;  //branch if ≥ unsigned
                                       default: ALUControl=4'bxxxx;
                                       endcase    
 
             end
 
             // JAL
             7'b1101111: begin
                      ALUControl=4'b0001;
             end

             // JALr
            7'b1100111: begin
                        ALUControl=4'b0000;
            end
 
             default: 
                     ALUControl=4'bxxxx;
             
         endcase
         end
endmodule
