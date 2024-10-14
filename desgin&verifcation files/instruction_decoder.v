module instruction_decoder (
	input [31:0] instr,
	output [6:0] op,
	output [2:0] funct3,
	output funct7,
	output [4:0] A1, A2, A3,
	output [24:0] Imm
);

	assign op = instr[6:0];
	assign funct3 = instr[14:12];
	assign funct7 = instr[30];
	assign A1 = instr[19:15];
	assign A2 = instr[24:20];
	assign A3 = instr[11:7];
	assign Imm = instr[31:7];

endmodule