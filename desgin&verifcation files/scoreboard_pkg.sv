package scoreboard_pkg;
import transaction_pkg::*;
import shared_pkg::*;

	class RISC_scoreboard;

		logic [31:0] Imm_I, Imm_B, Imm_J, Imm_S;
	    logic [31:0] ReadData_m_ref, ALUResult_ref, PCNext_ref;
	    bit MemWrite_ref, MemRead_ref, Stall_ref;

	    logic [31:0] reg_file_ref [0:31];
	    logic [31:0] datamem_ref [0:1023];

	    logic [3:0] valid_tag_in_cache [32] = '{default:0};

	    bit [2:0] stall_delay;

		task check_data(risc_transaction R_txn);

			reference_model(R_txn, Stall_ref, MemWrite_ref, MemRead_ref, ReadData_m_ref, ALUResult_ref, PCNext_ref);

			#1;

			if(R_txn.MemWrite !== MemWrite_ref) begin
				$display("ERROR: time(%0t) \t\t-- Output -MemWrite- equals %0b, but should equal %0b. \t\t\t[instruction: 0x%0h]", $time(), R_txn.MemWrite, MemWrite_ref, R_txn.current_instruction);
				e_count_MemWr++;
			end
			else c_count_MemWr++;

			if(R_txn.MemRead !== MemRead_ref) begin
				$display("ERROR: time(%0t) \t\t-- Output -MemRead- equals %0b, but should equal %0b. \t\t\t[instruction: 0x%0h]", $time(), R_txn.MemRead, MemRead_ref, R_txn.current_instruction);
				e_count_MemRd++;
			end
			else c_count_MemRd++;

			if(R_txn.ALUResult !== ALUResult_ref) begin
				$display("ERROR: time(%0t) \t\t-- Output -ALUResult- equals 0x%0h, but should equal 0x%0h. \t\t\t[instruction: 0x%0h]", $time(), R_txn.ALUResult, ALUResult_ref, R_txn.current_instruction);
				e_count_ALURes++;
			end
			else c_count_ALURes++;

			if(R_txn.RST_n) begin
				if(R_txn.PCNext !== PCNext_ref) begin
					$display("ERROR: time(%0t) \t\t-- Output -PCNext- equals 0x%0h, but should equal 0x%0h. \t\t\t[instruction: 0x%0h]", $time(), R_txn.PCNext, PCNext_ref, R_txn.current_instruction);
					e_count_PCNext++;
				end
				else c_count_PCNext++;
			end

			#1;

			if(!R_txn.RST_n) begin
				if(R_txn.Stall !== 1'b0) begin
					$display("ERROR: time(%0t) \t\t-- Output -Stall- equals %0b, but should equal %0b. \t\t\t[instruction: 0x%0h]", $time(), R_txn.Stall, 1'b0, R_txn.current_instruction);
					e_count_Stall++;
				end
				else c_count_Stall++;
			end
			else begin
				if(R_txn.Stall !== Stall_ref) begin
					$display("ERROR: time(%0t) \t\t-- Output -Stall- equals %0b, but should equal %0b. \t\t\t[instruction: 0x%0h]", $time(), R_txn.Stall, Stall_ref, R_txn.current_instruction);
					e_count_Stall++;
				end
				else c_count_Stall++;
			end

			if(!Stall_ref & MemRead_ref) begin
				if(R_txn.ReadData_m !== ReadData_m_ref) begin
					$display("ERROR: time(%0t) \t\t-- Output -ReadData_m- equals 0x%0h, but should equal 0x%0h. \t\t\t[instruction: 0x%0h]", $time(), R_txn.ReadData_m, ReadData_m_ref, R_txn.current_instruction);
					e_count_RD_m++;
				end
				else c_count_RD_m++;
			end

		endtask

		task reference_model(risc_transaction R_txn, output bit Stall_ref, MemWrite_ref, MemRead_ref, logic [31:0] ReadData_m_ref, ALUResult_ref, PCNext_ref);
			
			reg_file_ref[5'h0] = 32'b0;

			if(!R_txn.RST_n) begin
				for(int i=0; i<32; i++) begin
					reg_file_ref[i] = 32'b0;
				end
			end


			Imm_I = {{20{R_txn.current_instruction[31]}}, R_txn.current_instruction[31:20]};
			Imm_S = {{20{R_txn.current_instruction[31]}}, R_txn.current_instruction[31:25], R_txn.current_instruction[11:7]};
			Imm_B = {{20{R_txn.current_instruction[31]}}, R_txn.current_instruction[7], R_txn.current_instruction[30:25], R_txn.current_instruction[11:8], 1'b0};
			Imm_J = {{12{R_txn.current_instruction[31]}}, R_txn.current_instruction[19:12], R_txn.current_instruction[20], R_txn.current_instruction[30:21], 1'b0};

	        case(R_txn.current_instruction[6:0]) // Opcode
	            7'h33: /*------------------------------------------------------------------------------ R-type
	            -*/ begin
	                    case(R_txn.current_instruction[14:12]) // funct3
	                        3'b000: /*------------------------------------------------------------------------------ Add/Sub
	                        -*/ begin
	                                if(R_txn.current_instruction[30]) // funct7 - sub
	                                    ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] - reg_file_ref[R_txn.current_instruction[24:20]];
	                                else // add
	                                    ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] + reg_file_ref[R_txn.current_instruction[24:20]];
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b001: /*------------------------------------------------------------------------------ SLL
	                        -*/ begin
	                                ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] << reg_file_ref[R_txn.current_instruction[24:20]];
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b010: /*------------------------------------------------------------------------------ SLT
	                        -*/ begin
	                                ALUResult_ref = ($signed(reg_file_ref[R_txn.current_instruction[19:15]]) < $signed(reg_file_ref[R_txn.current_instruction[24:20]])) ? 32'b1 : 32'b0;
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b011: /*------------------------------------------------------------------------------ SLTU
	                        -*/ begin
	                                ALUResult_ref = ($unsigned(reg_file_ref[R_txn.current_instruction[19:15]]) < $unsigned(reg_file_ref[R_txn.current_instruction[24:20]])) ? 32'b1 : 32'b0;
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b100: /*------------------------------------------------------------------------------ XOR
	                        -*/ begin
	                                ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] ^ reg_file_ref[R_txn.current_instruction[24:20]];
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b101: /*------------------------------------------------------------------------------ SRL / SRA
	                        -*/ begin
	                                if(R_txn.current_instruction[30]) // funct7 - SRA
	                                    ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] >>> reg_file_ref[R_txn.current_instruction[24:20]];
	                                else // SRL
	                                    ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] >> reg_file_ref[R_txn.current_instruction[24:20]];
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b110: /*------------------------------------------------------------------------------ OR
	                        -*/ begin
	                                ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] | reg_file_ref[R_txn.current_instruction[24:20]];
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b111: /*------------------------------------------------------------------------------ AND
	                        -*/ begin
	                                ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] & reg_file_ref[R_txn.current_instruction[24:20]];
	                            end
	                        /*------------------------------------------------------------------------------*/
	                    endcase
	                    // Data Memory Signals
	                    MemWrite_ref = 0; MemRead_ref = 0;

	                    // Writing ALUResult in rd
	                    if(R_txn.RST_n && !(R_txn.current_instruction[11:7] == 5'h0))
	                        reg_file_ref[R_txn.current_instruction[11:7]] = ALUResult_ref;
	                    else
	                        reg_file_ref[R_txn.current_instruction[11:7]] = 32'b0;

	                    // PC Signal
	                    PCNext_ref = (!(R_txn.RST_n) || (R_txn.PC == 32'h3ffc)) ? 32'b0 : R_txn.PC + 4;
	                end
	            /*------------------------------------------------------------------------------*/
	            7'h63: /*------------------------------------------------------------------------------ Branch
	            -*/ begin
	            		case(R_txn.current_instruction[14:12]) // funct3
	                        3'b000: /*------------------------------------------------------------------------------ beq
	                        -*/ begin
	                                // ALU Signal
	                    			ALUResult_ref = (reg_file_ref[R_txn.current_instruction[19:15]] == reg_file_ref[R_txn.current_instruction[24:20]]) ? 1 : 0;

	                    			// PCNext
	                    			PCNext_ref = (!(R_txn.RST_n) || (R_txn.PC == 32'h3ffc)) ? 32'b0 : ALUResult_ref ? R_txn.PC + Imm_B : R_txn.PC + 4;
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b001: /*------------------------------------------------------------------------------ bne
	                        -*/ begin
	                                // ALU Signal
	                    			ALUResult_ref = (reg_file_ref[R_txn.current_instruction[19:15]] != reg_file_ref[R_txn.current_instruction[24:20]]) ? 1 : 0;

	                    			// PCNext
	                    			PCNext_ref = (!(R_txn.RST_n) || (R_txn.PC == 32'h3ffc)) ? 32'b0 : ALUResult_ref ? R_txn.PC + Imm_B : R_txn.PC + 4;
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b100: /*------------------------------------------------------------------------------ blt
	                        -*/ begin
	                                // ALU Signal
	                    			ALUResult_ref = ($signed(reg_file_ref[R_txn.current_instruction[19:15]]) < $signed(reg_file_ref[R_txn.current_instruction[24:20]])) ? 1 : 0;

	                    			// PCNext
	                    			PCNext_ref = (!(R_txn.RST_n) || (R_txn.PC == 32'h3ffc)) ? 32'b0 : ALUResult_ref ? R_txn.PC + Imm_B : R_txn.PC + 4;
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b101: /*------------------------------------------------------------------------------ bge
	                        -*/ begin
	                                // ALU Signal
	                    			ALUResult_ref = ($signed(reg_file_ref[R_txn.current_instruction[19:15]]) >= $signed(reg_file_ref[R_txn.current_instruction[24:20]])) ? 1 : 0;

	                    			// PCNext
	                    			PCNext_ref = (!(R_txn.RST_n) || (R_txn.PC == 32'h3ffc)) ? 32'b0 : ALUResult_ref ? R_txn.PC + Imm_B : R_txn.PC + 4;
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b110: /*------------------------------------------------------------------------------ bltu
	                        -*/ begin
	                                // ALU Signal
	                    			ALUResult_ref = ($unsigned(reg_file_ref[R_txn.current_instruction[19:15]]) < $unsigned(reg_file_ref[R_txn.current_instruction[24:20]])) ? 1 : 0;

	                    			// PCNext
	                    			PCNext_ref = (!(R_txn.RST_n) || (R_txn.PC == 32'h3ffc)) ? 32'b0 : ALUResult_ref ? R_txn.PC + Imm_B : R_txn.PC + 4;
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b111: /*------------------------------------------------------------------------------ bgeu
	                        -*/ begin
	                                // ALU Signal
	                    			ALUResult_ref = ($unsigned(reg_file_ref[R_txn.current_instruction[19:15]]) >= $unsigned(reg_file_ref[R_txn.current_instruction[24:20]])) ? 1 : 0;

	                    			// PCNext
	                    			PCNext_ref = (!(R_txn.RST_n) || (R_txn.PC == 32'h3ffc)) ? 32'b0 : ALUResult_ref ? R_txn.PC + Imm_B : R_txn.PC + 4;
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        default: /*------------------------------------------------------------------------------
	                        -*/ begin
	                        		ALUResult_ref = 0;
	                        		PCNext_ref = (!(R_txn.RST_n) || (R_txn.PC == 32'h3ffc)) ? 32'b0 : R_txn.PC + 4;
	                        	end
	                        /*------------------------------------------------------------------------------*/
	                    endcase
	                    
	                    // Data Memory Signals
	                    MemWrite_ref = 0; MemRead_ref = 0;
	                end
	            /*------------------------------------------------------------------------------*/
	            7'h13: /*------------------------------------------------------------------------------ I-type
	            -*/ begin
	                    case(R_txn.current_instruction[14:12]) // funct3
	                        3'b000: /*------------------------------------------------------------------------------ Addi
	                        -*/ begin
	                                ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] + Imm_I;
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b001: /*------------------------------------------------------------------------------ SLLi
	                        -*/ begin
	                                ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] << Imm_I[4:0];
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b010: /*------------------------------------------------------------------------------ SLTi
	                        -*/ begin
	                                ALUResult_ref = ($signed(reg_file_ref[R_txn.current_instruction[19:15]]) < $signed(Imm_I)) ? 32'b1 : 32'b0;
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b011: /*------------------------------------------------------------------------------ SLTiU
	                        -*/ begin
	                                ALUResult_ref = ($unsigned(reg_file_ref[R_txn.current_instruction[19:15]]) < $unsigned(Imm_I)) ? 32'b1 : 32'b0;
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b100: /*------------------------------------------------------------------------------ XOR
	                        -*/ begin
	                                ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] ^ Imm_I;
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b101: /*------------------------------------------------------------------------------ SRLi / SRAi
	                        -*/ begin
	                                if(R_txn.current_instruction[30]) // Imm[10] - SRAi
	                                    ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] >>> Imm_I[4:0];
	                                else // SRLi
	                                    ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] >> Imm_I[4:0];
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b110: /*------------------------------------------------------------------------------ ORi
	                        -*/ begin
	                                ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] | Imm_I;
	                            end
	                        /*------------------------------------------------------------------------------*/
	                        3'b111: /*------------------------------------------------------------------------------ ANDi
	                        -*/ begin
	                                ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] & Imm_I;
	                            end
	                        /*------------------------------------------------------------------------------*/
	                    endcase
	                    // Data Memory Signals
	                    MemWrite_ref = 0; MemRead_ref = 0;

	                    // Writing ALUResult in rd
	                    if(R_txn.RST_n && !(R_txn.current_instruction[11:7] == 5'h0))
	                        reg_file_ref[R_txn.current_instruction[11:7]] = ALUResult_ref;
	                    else
	                        reg_file_ref[R_txn.current_instruction[11:7]] = 32'b0;

	                    // PC Signal
	                    PCNext_ref = (!(R_txn.RST_n) || (R_txn.PC == 32'h3ffc)) ? 32'b0 : R_txn.PC + 4;
	                end
	            /*------------------------------------------------------------------------------*/
	            7'h6f: /*------------------------------------------------------------------------------ jal
	            -*/ begin
	                    PCNext_ref = (!(R_txn.RST_n) || (R_txn.PC == 32'h3ffc)) ? 32'b0 : R_txn.PC + Imm_J;

	                    if(R_txn.RST_n && !(R_txn.current_instruction[11:7] == 5'h0))
	                        reg_file_ref[R_txn.current_instruction[11:7]] = R_txn.PC + 4;
	                    else
	                        reg_file_ref[R_txn.current_instruction[11:7]] = 32'b0;

	                    // Data Memory Signals
	                    MemWrite_ref = 0; MemRead_ref = 0;

	                    // ALU Signal
	                    ALUResult_ref = 0;
	                end
	            /*------------------------------------------------------------------------------*/
	            7'h67: /*------------------------------------------------------------------------------ jalr
	            -*/ begin
	            		// ALU Signal
	                    ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] + Imm_I;

	                    PCNext_ref = (!(R_txn.RST_n) || (R_txn.PC == 32'h3ffc)) ? 32'b0 : ALUResult_ref;

	                    if(R_txn.RST_n && !(R_txn.current_instruction[11:7] == 5'h0))
	                        reg_file_ref[R_txn.current_instruction[11:7]] = R_txn.PC + 4;
	                    else
	                        reg_file_ref[R_txn.current_instruction[11:7]] = 32'b0;

	                    // Data Memory Signals
	                    MemWrite_ref = 0; MemRead_ref = 0;
	                end
	            /*------------------------------------------------------------------------------*/
	            7'h03: /*------------------------------------------------------------------------------ lw
	            -*/ begin
	                    ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] + Imm_I;
	                    MemRead_ref = 1'b1;
	                    MemWrite_ref = 1'b0;

	                    PCNext_ref = (!(R_txn.RST_n) || (R_txn.PC == 32'h3ffc)) ? 32'b0 : R_txn.PC + 4;
	                    
	                    // Read Miss
	                    if(ALUResult_ref === 32'bx || !((valid_tag_in_cache[ALUResult_ref[6:2]][2:0] === ALUResult_ref[9:7]) && valid_tag_in_cache[ALUResult_ref[6:2]][3]) ) begin
	                    	if(stall_delay == 4) begin // After 4 Cycles in Read Miss
	                    		// Deassert Stall
		                    	Stall_ref = 1'b0;
		                    	// Update Valid and Tag for the target block
		                    	valid_tag_in_cache[ALUResult_ref[6:2]][3] = 1'b1;
	                    		valid_tag_in_cache[ALUResult_ref[6:2]][2:0] = ALUResult_ref[9:7];

	                    		// Read Data
	                    		ReadData_m_ref = datamem_ref[ALUResult_ref[9:0]];

	                    		// Write Data into rd
	                    		if(R_txn.RST_n && !(R_txn.current_instruction[11:7] == 5'h0))
			                        reg_file_ref[R_txn.current_instruction[11:7]] = ReadData_m_ref;
			                    else
			                        reg_file_ref[R_txn.current_instruction[11:7]] = 32'b0;

	                    		// Restart delay counter
	                    		stall_delay = 0;
	                    	end
		                   	else begin // Assert Stall for 4 Cycles in Read Miss
		                   		Stall_ref = 1'b1;
		                   		// Increment Stall Counter
	                    		stall_delay++;
		                   	end
	                    end
	                    else begin // Read Hit
	                    	// Read Data
	                    	ReadData_m_ref = datamem_ref[ALUResult_ref[9:0]];

	                    	// Write Data into rd
	                    	if(R_txn.RST_n && !(R_txn.current_instruction[11:7] == 5'h0))
		                        reg_file_ref[R_txn.current_instruction[11:7]] = ReadData_m_ref;
		                    else
		                        reg_file_ref[R_txn.current_instruction[11:7]] = 32'b0;

	                    	// No Stall
	                    	Stall_ref = 1'b0;
	                    end
	                end
	            /*------------------------------------------------------------------------------*/
	            7'h23: /*------------------------------------------------------------------------------ sw
	            -*/ begin
	                    MemWrite_ref = 1'b1;
	                    MemRead_ref = 1'b0;
	                    ALUResult_ref = reg_file_ref[R_txn.current_instruction[19:15]] + Imm_S;

	                    PCNext_ref = (!(R_txn.RST_n) || (R_txn.PC == 32'h3ffc)) ? 32'b0 : R_txn.PC + 4;

	                    // Write Hit / Miss
	                    if(stall_delay == 4) begin // After 4 Cycles in Write Hit / Miss
	                    	// Deassert Stall
	                    	Stall_ref = 1'b0;

	                    	// Write Data
	                    	datamem_ref[ALUResult_ref[9:0]] = reg_file_ref[R_txn.current_instruction[24:20]];

	                    	// Restart delay counter
	                    	stall_delay = 0;
	                    end
	                   	else begin // Assert Stall for 4 Cycles in Write Hit / Miss
	                   		Stall_ref = 1'b1;

	                   		// Increment Stall Counter
                    		stall_delay++;
	                   	end
	                end
	            /*------------------------------------------------------------------------------*/
	            default: /*------------------------------------------------------------------------------
	            -*/ PCNext_ref = (!(R_txn.RST_n) || (R_txn.PC == 32'h3ffc)) ? 32'b0 : R_txn.PC + 4;
	            /*------------------------------------------------------------------------------*/
	        endcase

		endtask

	endclass
	
endpackage