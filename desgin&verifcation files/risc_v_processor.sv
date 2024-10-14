module risc_v_processor (RISC_if.DUT rd);

	// Parameters

	parameter INSTR_MEM_DEPTH = 256;



	//////////////////////// Internal Wires ////////////////////////

	// Control Unit Signals

	wire MemWrite, MemRead, ALUSrc, RegWrite, RegWrite_f;

	wire [1:0] PCSrc, ResultSrc;

	wire [1:0] ImmSrc;

	wire [3:0] ALUControl;



	// Intruction Fetch

	wire [31:0] PC , PCPlus4, PCTarget, Instr;

	reg [31:0] PCNext;



	// Instruction Decode

	wire [6:0] op;

	wire [2:0] funct3;

	wire funct7;

	wire [4:0] A1_r, A2_r, A3_r;

	wire [24:0] Imm;

	wire [31:0] ImmExt, ReadData1_r, ReadData2_r;



	// Instruction Execute

	wire [31:0] SrcB, ALUResult;

	wire Branch_Sig;



	// Memory/WriteBack

	wire [31:0] ReadData_m;

	reg [31:0] Result_wb;

	wire Stall;


	//////////////////////// Instruction Fetch ////////////////////////

	// Mux (PCSrc)

	always @(*) begin

		case (PCSrc)

			2'b00: /*------------------------------------------------------------------------------

			-*/ PCNext = PCPlus4;

			/*------------------------------------------------------------------------------*/

			2'b01: /*------------------------------------------------------------------------------

			-*/ PCNext = PCTarget;

			/*------------------------------------------------------------------------------*/

			2'b10: /*------------------------------------------------------------------------------

			-*/ PCNext = ALUResult;

			/*------------------------------------------------------------------------------*/

			default : 

				PCNext = PC + 4 ;

		endcase

	end



	// PC Module Instantiation

	PC PC0 (.clk(rd.clk), .RST_n(rd.RST_n), .EN(~Stall), .PCNext(PCNext), .PC(PC));



	// PC Adder

	assign PCPlus4 = PC + 32'h4;



	// Instruction Memory Instantiation

	instruction_memory #(.DEPTH(INSTR_MEM_DEPTH)) I_MEM (.A(PC[$clog2(INSTR_MEM_DEPTH)+1:0]),.RD(Instr));



	//////////////////////// Instruction Decode ////////////////////////

	// Instruction Decoder: Extracting bit-fields from instructions

	instruction_decoder I_DEC (.instr(Instr), .op(op), .funct3(funct3),

							   .funct7(funct7), .A1(A1_r), .A2(A2_r),

							   .A3(A3_r), .Imm(Imm));



	// Control Unit Instantiation

	Control_Unit CU (.op(op), .funct3(funct3), .funct7(funct7), .branch_signal(Branch_Sig),

					 .PCSrc(PCSrc), .ResultSrc(ResultSrc), .MemWrite(MemWrite), .MemRead(MemRead),

					 .ALUControl(ALUControl), .ALUSrc(ALUSrc), .ImmSrc(ImmSrc),

					 .RegWrite(RegWrite), .i_type(i_type));



	assign RegWrite_f = (!Stall) ? RegWrite : 1'b0;



	// Register File Instantiation

	reg_file #(.reg_file_depth(32)) RegFile (.clk(rd.clk), .rst_n(rd.RST_n), .we3(RegWrite_f),

						   					 .a1(A1_r), .a2(A2_r), .a3(A3_r), .wd3(Result_wb),

						   					 .rd1(ReadData1_r), .rd2(ReadData2_r));



	// Sign Extention for Immediate Values

	extend ImmExtend (.instr(Imm), .ImmSrc(ImmSrc), .ImmExt(ImmExt));



	// Mux (ALUSrc)

	assign SrcB = (ALUSrc) ? ImmExt : ReadData2_r;



	//////////////////////// Instruction Execute ////////////////////////

	// ALU Instantiation

	ALU ALU0 (.i_type(i_type), .op(op), .SrcA(ReadData1_r), .SrcB(SrcB), .ALUControl(ALUControl),

			  .ALUResult(ALUResult), .branch_signal(Branch_Sig));



	// PCTarget (Jump/Branch Instructions)

	assign PCTarget = PC + ImmExt;



	//////////////////////// Memory / WriteBack ////////////////////////



	// Data Memory System Integration Goes Here ...

	cache_top MemSystem (.clk(rd.clk), .rst_n(rd.RST_n), .mem_read(MemRead), .mem_write(MemWrite),

						 .word_address(ALUResult[9:0]), .data_in(ReadData2_r), .stall(Stall), .data_out(ReadData_m));

	// Data Memory Instantiation

	// data_memory Data_Mem (.clk(rd.clk), .we(rd.MemWrite), .a(rd.ALUResult), .wd(rd.ReadData2_r), .rd(rd.ReadData_m));



	// Mux (ResultSrc)

	always @(*) begin

		case (ResultSrc)

			2'b00: /*------------------------------------------------------------------------------

			-*/ Result_wb = ALUResult;

			/*------------------------------------------------------------------------------*/

			2'b01: /*------------------------------------------------------------------------------

			-*/ Result_wb = ReadData_m;

			/*------------------------------------------------------------------------------*/

			2'b10: /*------------------------------------------------------------------------------

			-*/ Result_wb = PCPlus4;

			/*------------------------------------------------------------------------------*/

			default : Result_wb = 32'b0;

		endcase

	end

	



	// ////////////////////////////// Outputs /////////////////////////////

	assign rd.current_instruction = Instr;

	assign rd.PC_out = PC[$clog2(INSTR_MEM_DEPTH)+1:0];

	assign rd.PCNext_out = PCNext[$clog2(INSTR_MEM_DEPTH)+1:0];

	assign rd.MemWrite_out = MemWrite;

	assign rd.MemRead_out = MemRead;
	
	assign rd.ALUResult_out = ALUResult;
	
	assign rd.ReadData_m_out = ReadData_m;
	
	assign rd.Stall_out = Stall;
	
	assign rd.ReadData1_r_out = ReadData1_r;
	
	assign rd.ReadData2_r_out = ReadData2_r;
	
	assign rd.ImmExt_out = ImmExt;



endmodule
