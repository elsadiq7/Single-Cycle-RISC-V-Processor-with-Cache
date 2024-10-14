module Risc_tb (RISC_if.TEST rf) ;
	import transaction_pkg ::*;
	import shared_pkg::*;

	// parameter
	parameter INSTR_MEM_DEPTH = 20;

	risc_transaction obj = new (INSTR_MEM_DEPTH) ; 

	initial begin
		//Activate reset
		rf.RST_n = 1'b0;
		load_instr_mem (obj);
		repeat (5) @(negedge rf.clk);

		//De-activate reset 
		rf.RST_n = 1'b1;
		repeat (10) @(negedge rf.clk);
/*
		for(int i=0; i<INSTR_MEM_DEPTH; i++) begin
			assert(obj.randomize());
			rf.RST_n = obj.RST_n;
			@(negedge rf.clk);
			//if(!rf.RST_n) i = 0;	// So that all instructions get executed
		end
*/
		repeat(INSTR_MEM_DEPTH) @(negedge rf.clk);
		
		test_finished = 1;
	end

	task load_instr_mem (risc_transaction obj);
		logic [31:0] instr ;
		integer file ;

		file = $fopen("Instruction_mem_boot.txt","w") ;
		
		//activate reset and keep it until the instructions are randomized and loaded

		if(file) begin

			repeat(INSTR_MEM_DEPTH / 4 )  begin
				obj.immediate_more() ;
				assert(obj.randomize()) ;
				instr = obj.instruction() ;
				$fwrite(file,"%b \n",instr);
			end

			repeat(INSTR_MEM_DEPTH / 4 )  begin
				obj.write_more() ;
				assert(obj.randomize()) ;
				instr = obj.instruction() ;
				$fwrite(file,"%b \n",instr);
			end

			repeat(INSTR_MEM_DEPTH / 4 )  begin
				obj.read_more() ;
				assert(obj.randomize()) ;
				instr = obj.instruction() ;
				$fwrite(file,"%b \n",instr);
			end

			repeat(INSTR_MEM_DEPTH / 4 )  begin
				obj.normal() ;
				assert(obj.randomize()) ;
				instr = obj.instruction() ;
				$fwrite(file,"%b \n",instr);
			end
		end

	endtask

endmodule