module RISC_top;
	parameter INSTRUCTION_MEM_DEPTH = 256;

	bit CLK;

	// Clock Generation
	initial begin
		CLK = 0;
    	forever #1 CLK = ~CLK;
  	end

  	// Loading Instruction Memory
	initial begin
		$readmemb("Instruction_mem_boot.txt", RISC_DUT.I_MEM.i_mem);
	end

  	RISC_if R_if (CLK);

  	risc_v_processor #(.INSTR_MEM_DEPTH(INSTRUCTION_MEM_DEPTH)) RISC_DUT (R_if);
  	Risc_tb #(.INSTR_MEM_DEPTH(INSTRUCTION_MEM_DEPTH)) RISC_TEST (R_if);
  	// tb_readmiss_after_hit_bug #(.INSTR_MEM_DEPTH(INSTRUCTION_MEM_DEPTH)) RISC_TEST (R_if);
  	RISC_monitor RISC_MON (R_if);


  	//`ifdef SIM
  		
  	//`endif

endmodule