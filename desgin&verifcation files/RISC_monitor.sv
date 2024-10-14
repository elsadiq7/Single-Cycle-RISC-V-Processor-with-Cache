import transaction_pkg::*;
import coverage_pkg::*;
import scoreboard_pkg::*;
import shared_pkg::*;


module RISC_monitor(RISC_if.MON rm);
	risc_transaction R_txn   = new();
	RISC_coverage 	 R_cov   = new();
	RISC_scoreboard  R_score = new();

	risc_transaction R_tcov  = new();

	initial begin
		forever begin
			fork
				//Transaction for Checker
				begin
					@(posedge rm.clk);
					//Inputs to DUT
					R_txn.RST_n			= rm.RST_n;

					// Combinational Outputs of DUT
					R_txn.Stall 				= rm.Stall_out;
					R_txn.ReadData_m 			= rm.ReadData_m_out;	// In case of Read Hit

					@(negedge rm.clk);
					// Resampling RST signal to capture changes within the period
					R_txn.RST_n			= rm.RST_n;

					// Sequential Outputs of DUT
					R_txn.current_instruction 	= rm.current_instruction;
					R_txn.PC					= rm.PC_out;
					R_txn.PCNext				= rm.PCNext_out;
					R_txn.ReadData1_r 			= rm.ReadData1_r_out;
					R_txn.ReadData2_r 			= rm.ReadData2_r_out;
					R_txn.ReadData_m 			= rm.ReadData_m_out;	// In case of Read Miss
					R_txn.ALUResult				= rm.ALUResult_out;
					R_txn.MemWrite				= rm.MemWrite_out;
					R_txn.MemRead				= rm.MemRead_out;
					R_txn.ImmExt				= rm.ImmExt_out;
					R_txn.Stall					= rm.Stall_out;

					R_score.check_data(R_txn);

					if(shared_pkg::test_finished) begin
						@(posedge rm.clk);
						$display("---------------------------------------------------------------------");
						$display("--------------- Correct Count and Error Count Summary ---------------");
						$display("---------------------------------------------------------------------");
						$display("ALUResult:        Correct Count: %0d \t---\t Error Count: %0d", shared_pkg::c_count_ALURes, 	shared_pkg::e_count_ALURes);
				        $display("MemRead:          Correct Count: %0d \t---\t Error Count: %0d", shared_pkg::c_count_MemRd, 	shared_pkg::e_count_MemRd);
				        $display("ReadData_m:       Correct Count: %0d \t---\t Error Count: %0d", shared_pkg::c_count_RD_m, 	shared_pkg::e_count_RD_m);
				        $display("MemWrite:         Correct Count: %0d \t---\t Error Count: %0d", shared_pkg::c_count_MemWr, 	shared_pkg::e_count_MemWr);
				        $display("PCNext:           Correct Count: %0d \t---\t Error Count: %0d", shared_pkg::c_count_PCNext, 	shared_pkg::e_count_PCNext);
				        $display("Stall:           	Correct Count: %0d \t---\t Error Count: %0d", shared_pkg::c_count_Stall, 	shared_pkg::e_count_Stall);
						$display("---------------------------------------------------------------------");

						@(negedge rm.clk); $stop;
					end
				end
				//Transaction for Covergroup
				begin
					@(posedge rm.clk);
					//Inputs to DUT
					R_tcov.RST_n			= rm.RST_n;

					// Combinational Outputs of DUT
					R_tcov.Stall 				= rm.Stall_out;
					R_txn.ReadData_m 			= rm.ReadData_m_out;	// In case of Read Hit

					@(negedge rm.clk);
					// Resampling RST signal to capture changes within the period
					R_tcov.RST_n			= rm.RST_n;
					
					// Sequential Outputs of DUT
					R_tcov.current_instruction 	= rm.current_instruction;
					R_tcov.PC					= rm.PC_out;
					R_tcov.PCNext				= rm.PCNext_out;
					R_txn.ReadData1_r 			= rm.ReadData1_r_out;
					R_tcov.ReadData2_r 			= rm.ReadData2_r_out;
					R_tcov.ReadData_m 			= rm.ReadData_m_out;	// In case of Read Miss
					R_tcov.ALUResult			= rm.ALUResult_out;
					R_tcov.MemWrite				= rm.MemWrite_out;
					R_tcov.MemRead				= rm.MemRead_out;
					R_tcov.ImmExt				= rm.ImmExt_out;

					R_cov.sample_data(R_tcov);
				end
				// Drive Rate
				begin
					@(negedge rm.clk);
				end
			join_any
		end
	end
endmodule