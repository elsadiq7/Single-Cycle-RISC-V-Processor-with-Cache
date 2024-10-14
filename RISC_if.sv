interface RISC_if (
	input logic clk
);
	import transaction_pkg ::*;

	// Input & Output Signals of Design
	logic RST_n;
	logic [31:0] current_instruction, PC_out, PCNext_out;
	logic [31:0] ReadData1_r_out, ReadData2_r_out, ImmExt_out;
	logic MemWrite_out, MemRead_out, Stall_out;
	logic [31:0] ReadData_m_out, ALUResult_out;

	// Creating Object from transaction package -- for initializing instruction memory
	risc_transaction obj = new();

	modport TEST (output RST_n,
					input clk, current_instruction, PC_out, PCNext_out, ReadData1_r_out, ReadData2_r_out, ImmExt_out, MemWrite_out, MemRead_out, ReadData_m_out, ALUResult_out, Stall_out);

	modport DUT (output current_instruction, PC_out, PCNext_out, ReadData1_r_out, ReadData2_r_out, ImmExt_out, MemWrite_out, MemRead_out, ReadData_m_out, ALUResult_out, Stall_out,
					input clk, RST_n);

	modport MON (input clk, RST_n, current_instruction, PC_out, PCNext_out, ReadData1_r_out, ReadData2_r_out, ImmExt_out, MemWrite_out, MemRead_out, ReadData_m_out, ALUResult_out, Stall_out);

endinterface