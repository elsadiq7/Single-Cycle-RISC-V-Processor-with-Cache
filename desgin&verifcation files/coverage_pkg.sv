package coverage_pkg;
import transaction_pkg::*;

	class RISC_coverage;

		risc_transaction R_cvg_txn = new();

		function void sample_data(risc_transaction R_tcov);
			R_cvg_txn = R_tcov;
			RISC_cg.sample();
		endfunction

		covergroup RISC_cg;
			// ----------------------------------------------------------------- Coverpoints ----------------------------------------------------------------
			// Instructions Set - Operations Covered
			opcode_cov:		coverpoint R_cvg_txn.current_instruction[6:0] iff (R_cvg_txn.RST_n) { 		// All Opcodes are exercised
				bins R_type 	= {7'h33};
				bins lw_instr	= {7'h03};
				bins I_type 	= {7'h13};
				bins S_type 	= {7'h23};
				bins B_type 	= {7'h63};
				bins J_type 	= {7'h6f};
				bins Jalr_instr	= {7'h67};
				illegal_bins invalid_types = default;		// Uncovered opcodes in design are illegal
			}

			rs1_cov:		coverpoint R_cvg_txn.current_instruction[19:15] iff (R_cvg_txn.RST_n); 		// All Addresses in regfile are read from
			rs2_cov:		coverpoint R_cvg_txn.current_instruction[24:20] iff (R_cvg_txn.RST_n);
			rd_cov:			coverpoint R_cvg_txn.current_instruction[11:7] iff (R_cvg_txn.RST_n);		// All Addresses in regfile are written into
			funct3_cov:		coverpoint R_cvg_txn.current_instruction[14:12] iff (R_cvg_txn.RST_n); 		// All Operations for a given opcode are exercised
			funct7_cov:		coverpoint R_cvg_txn.current_instruction[30] iff (R_cvg_txn.RST_n);			// To be used in cross coverage later

			// MemRead & MemWrite
			MemRead_cov:	coverpoint R_cvg_txn.MemRead iff (R_cvg_txn.RST_n); 		// Memory Control Signals are activated and deactivated
			MemWrite_cov:	coverpoint R_cvg_txn.MemWrite iff (R_cvg_txn.RST_n);

			// ReadData
			ReadData_cov:	coverpoint R_cvg_txn.ReadData_m iff (R_cvg_txn.RST_n && R_cvg_txn.MemRead) { // ReadData from memory has taken different values
				bins Upperhalf 	= {[32'h0000ffff : 32'hffffffff]}; 		// Making sure a whole word is read
				bins Lowerhalf 	= {[32'h00000000 : 32'h0000ffff]};
			}

			// Possible Operands Values -- Making sure they have taken corner values
			ReadData1_r_cov: 	coverpoint R_cvg_txn.ReadData1_r iff (R_cvg_txn.RST_n) {
				bins MAX_POS 	= {32'h7fffffff};
				bins MAX_NEG	= {32'h80000000};
				bins ALL_ZEROS	= {32'b00000000};
				bins NEG_ONE	= {32'hffffffff};
				bins POS_ONE	= {32'h00000001};
				bins others 	= default;
			}

			ReadData2_r_cov: 	coverpoint R_cvg_txn.ReadData2_r iff (R_cvg_txn.RST_n) {
				bins MAX_POS 	= {32'h7fffffff};
				bins MAX_NEG	= {32'h80000000};
				bins ALL_ZEROS	= {32'b00000000};
				bins NEG_ONE	= {32'hffffffff};
				bins POS_ONE	= {32'h00000001};
				bins others 	= default;
			}

			Immediate_cov:		coverpoint R_cvg_txn.ImmExt iff (R_cvg_txn.RST_n) {
				bins MAX_POS 	= {32'h7fffffff};
				bins MAX_NEG	= {32'h80000000};
				bins MAX_POS_B 	= {32'h000007ff};
				bins MAX_NEG_B	= {32'hfffff800};
				bins ALL_ZEROS	= {32'b00000000};
				bins NEG_ONE	= {32'hffffffff};
				bins POS_ONE	= {32'h00000001};
				bins others 	= default;
			}

			// ALU Result Values
			ALUResult_cov:	coverpoint R_cvg_txn.ALUResult iff (R_cvg_txn.RST_n);	// ALUResult has taken all values -- to be used in cross coverage

			// PC Values
			PC_cov: 		coverpoint R_cvg_txn.PC iff (R_cvg_txn.RST_n);		// All instructions in instruction memory are executed

			// --------------------------------------------------------------- Cross Coverage ---------------------------------------------------------------
			// All ReadData combinations are covered within lw instruction
			Read_Memory_crs_cov:		cross MemRead_cov, ReadData_cov iff(R_cvg_txn.current_instruction[6:0] == 7'h03) {
				bins ReadMemory_bins 	= binsof(MemRead_cov) intersect {1} && binsof(ReadData_cov);
				option.cross_auto_bin_max = 0;
			}

			// All WriteData combinations are covered within sw instruction
			Write_Memory_opcode_crs_cov:	cross MemWrite_cov, ReadData2_r_cov iff(R_cvg_txn.current_instruction[6:0] == 7'h23) {
				bins WriteMemory_bins 	= binsof(MemWrite_cov) intersect {1} && binsof(ReadData2_r_cov);
				option.cross_auto_bin_max = 0;
			}

			// ALUResult with different opcodes and operands
			ALU_opcodes_crs_cov:	cross ALUResult_cov, opcode_cov, ReadData1_r_cov, ReadData2_r_cov, Immediate_cov {
				bins ALU_R 		= binsof(ALUResult_cov) && binsof(opcode_cov.R_type) && binsof(ReadData1_r_cov) && binsof(ReadData2_r_cov); // Arithmetic Ops in Regfile
				bins ALU_I 		= binsof(ALUResult_cov) && binsof(opcode_cov.I_type) && binsof(ReadData1_r_cov) && binsof(Immediate_cov);	// Arithmetic Ops in Regfile
				bins ALU_mem 	= binsof(ALUResult_cov) intersect {[0:10'h3ff]} && binsof(opcode_cov) intersect {7'h23, 7'h03}; 			// 4KB-Memory Access
				bins ALU_jalr	= binsof(ALUResult_cov) intersect {[0:14'h3fff]} && binsof(opcode_cov.Jalr_instr);
				option.cross_auto_bin_max = 0;
			}

			// Branching Addresses for B-type
			branch_crs_cov: 		cross Immediate_cov, ALUResult_cov iff(R_cvg_txn.current_instruction[6:0] == 7'h63) {
				bins cond_branching		= (binsof(Immediate_cov.MAX_POS_B) || binsof(Immediate_cov.MAX_NEG_B)) && binsof(ALUResult_cov) intersect {1};
				illegal_bins inf_loop_b	= binsof(Immediate_cov.ALL_ZEROS) && binsof(ALUResult_cov) intersect {1};
				option.cross_auto_bin_max = 0;
			}
			
		endgroup

		function new;
			RISC_cg = new();
		endfunction

	endclass

endpackage