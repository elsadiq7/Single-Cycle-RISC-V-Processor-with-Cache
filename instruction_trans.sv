package transaction_pkg ;
	class risc_transaction ;

		rand bit RST_n;
		rand logic [6:0] opcode ;
		rand logic [4:0] rd ;
		rand logic [2:0] funct3 ;
		rand logic [4:0] rs1 ;
		rand logic [4:0] rs2 ;
		rand logic [6:0] funct7 ;
		rand logic signed [11:0] immediate_I ; //12 signed bits for I & S-type
		rand logic signed [12:0] immediate_B ; //13 signed bits for B-type
		rand logic signed [20:0] immediate_J ; //21 signed bits for J-type

		rand logic [31:0] load_add ; 

		logic [31:0] current_instruction, PC, PCNext ;
    	logic [31:0] ImmExt, ReadData1_r, ReadData2_r, ReadData_m, ALUResult;
    	bit MemWrite, MemRead, Stall;
    	
		logic [11:0] immediate_values [5] = '{12'ha5a ,12'h5a5 ,12'hfff , 12'h000 ,12'hcad };

		// logic [31:0] instr,extend,operand;

		integer PC_now , depth ;

		logic [31:0] used_address[] ;

		bit [31:0] reg_file_emu [31:0] ; 

		logic [31:0] Main_mem_emu [1023:0] ;

		function new (depth = 4096);

			$readmemh("Main_memory_boot.txt",this.Main_mem_emu) ;
			
			this.PC_now =0 ;

			this.depth = depth ;

			this.used_address = new [0] ; 

		endfunction

		
		function void pre_randomize();

		endfunction

		function void post_randomize();
			
			PC_now = PC_now + 4 ;

			case(opcode)
			//updating the emulated register file
			
				7'h33: begin // R_type
					case(funct3) 
						3'h0 : begin
							if (funct7 == 7'h00) 
								reg_file_emu[rd] = reg_file_emu[rs1] + reg_file_emu[rs2] ; //add
							else if (funct7 == 7'h20)
								reg_file_emu[rd] = reg_file_emu[rs1] - reg_file_emu[rs2] ; //subtract
						end
						
						3'h1 : begin
							reg_file_emu[rd] = reg_file_emu[rs1] << reg_file_emu[rs2] ; //SLL
						end
							
						3'h2 : begin
							if (reg_file_emu[rs1] < reg_file_emu[rs2]) //Slt
								reg_file_emu[rd] = 1 ;
							else 
								reg_file_emu[rd] = 0 ;	 
						end	

						3'h3 : begin
							if (reg_file_emu[rs1] < reg_file_emu[rs2]) //Sltu
								reg_file_emu[rd] = 1 ;
							else 
								reg_file_emu[rd] = 0 ;	 
						end

						3'h4 : begin
							reg_file_emu[rd] = reg_file_emu[rs1] ^ reg_file_emu[rs2] ; //xor
						end
							
						3'h5 : begin

							if (funct7 == 7'h00) 
								reg_file_emu[rd] = reg_file_emu[rs1] >> reg_file_emu[rs2] ; // SRL
							else if (funct7 == 7'h20)

								reg_file_emu[rd] =  reg_file_emu[rs1] >>> reg_file_emu[rs2]   ; // SRA 
						end

						3'h6 : begin 
							reg_file_emu[rd] = reg_file_emu[rs1] | reg_file_emu[rs2] ; // OR
						end	

						3'h7 : begin
							reg_file_emu[rd] = reg_file_emu[rs1] & reg_file_emu[rs2] ; // AND
						end
					endcase 	
				end

				7'h13: begin // I_type
            		case(funct3)

		                3'h0: begin
		                	reg_file_emu[rd] = reg_file_emu[rs1] + immediate_I; // ADDI
		                end
		                	
		                3'h1: begin
		                	reg_file_emu[rd] = reg_file_emu[rs1] << immediate_I[4:0]; // SLLI
		                end	

		                3'h2: begin
							if (reg_file_emu[rs1] < immediate_I) 
								reg_file_emu[rd] = 1 ;
							else 
								reg_file_emu[rd] = 0 ;
						end
						

		                3'h3: begin
							if ($unsigned(reg_file_emu[rs1]) < $unsigned(immediate_I)) 
								reg_file_emu[rd] = 1 ;
							else 
								reg_file_emu[rd] = 0 ;
						end
						

		                3'h4: begin
		                	reg_file_emu[rd] = reg_file_emu[rs1] ^ immediate_I; // XORI
		                end	

		                3'h5: begin
			                if (immediate_I[10]) // Check if imm[10] is 1 for SRAI
			                    reg_file_emu[rd] = reg_file_emu[rs1] >>> immediate_I[4:0]; // SRAI
			                else
			                    reg_file_emu[rd] = reg_file_emu[rs1] >> immediate_I[4:0]; // SRLI
			            end

		                3'h6: begin 
		                	reg_file_emu[rd] = reg_file_emu[rs1] | immediate_I; // ORI
		                end 
		                	
		                3'h7: begin 
		                	reg_file_emu[rd] = reg_file_emu[rs1] & immediate_I; // ANDI
		                end

                	endcase 
                end 
                	
				7'h03: begin // I_type --> Load
					reg_file_emu[rd] = Main_mem_emu [reg_file_emu[rs1] + immediate_I ]  ;
				end

				7'h23: begin // S_type --> Store
	                Main_mem_emu[reg_file_emu[rs1] + immediate_I] = reg_file_emu[rs2]; // update MainMemory
	                used_address = new [ used_address.size() + 1 ] (used_address) ; //expand array by one place only   
	                used_address[used_address.size() - 1 ] = (reg_file_emu[rs1] + immediate_I) ; // Save address in address used
	                
           		end

				// 7'h63 begin //B_type --> Branch

				// end

				7'h6f: begin	//J_type --> Jump and link
					reg_file_emu[rd] = PC_now + 4 ;
				end

				7'h67: begin // J_type --> Jump and link register
					reg_file_emu[rd] = PC_now + 4 ;
				end

			endcase

		endfunction 

		constraint rst_c {
			RST_n dist { 0 := 5 , 1 := 95 } ;
		}

		constraint opcode_c {
			if( used_address.size() != 0 ){
				opcode dist { 7'h33 := 100 , 7'h13 := 100 , 7'h03:= 10 , 7'h23:= 10 , 7'h63:= 5 ,7'h67 := 5 } ;
			}
			else{  //Does not load unless it has stored at least once 
				opcode dist { 7'h33 := 100 , 7'h13 := 100 , 7'h03:= 0 , 7'h23:= 10 , 7'h63:= 5 ,7'h67 := 5 } ;				
			}
		}

		constraint opcode_immediate_more {
			if( used_address.size() != 0 ){
				opcode dist { 7'h33 := 50 , 7'h13 := 200 , 7'h03:= 10 , 7'h23:= 10 , 7'h63:= 5 ,7'h67 := 5 } ;			
			}
			else { //Does not load unless it has stored at least once 
				opcode dist { 7'h33 := 50 , 7'h13 := 200 , 7'h03:= 0 , 7'h23:= 10 , 7'h63:= 5 ,7'h67 := 5 } ;			
			}
		}	

		constraint opcode_write_more {
			if( used_address.size() != 0 ){
				opcode dist { 7'h33 := 50 , 7'h13 := 50 , 7'h03:= 10 , 7'h23:= 30 , 7'h63:= 5 ,7'h67 := 5 } ;			
			}
			else{  //Does not load unless it has stored at least once 
				opcode dist { 7'h33 := 50 , 7'h13 := 50 , 7'h03:= 0 , 7'h23:= 30 , 7'h63:= 5 ,7'h67 := 5 } ;			
			}
		}	

		constraint opcode_read_more {
			if( used_address.size() != 0 ){
				opcode dist { 7'h33 := 50 , 7'h13 := 50 , 7'h03:= 30 , 7'h23:= 10 , 7'h63:= 5 ,7'h67 := 5 } ;			
			}
			else{  //Does not load unless it has stored at least once 
				opcode dist { 7'h33 := 100 , 7'h13 := 100 , 7'h03:= 0 , 7'h23:= 10 , 7'h63:= 5 ,7'h67 := 5 } ;			
			}
		}	

		constraint rd_c {
			rd != 0 ; // Destination is never X0 
			if( used_address.size() != 0 ){
				load_add inside {used_address} ; // Loading address 
			}
		}

		constraint funct_3 {

    		solve opcode before funct3;

		    if (opcode == 7'h33) { // R_type
		        funct3 dist {0:= 40, 1:=10, 2:= 10, 3:= 5, 4:= 15, 5:= 40, 6:= 15, 7:= 15};
		    }

		    else if (opcode == 7'h13) { // I_type
		        funct3 dist {0:= 20, 1:=5, 2:= 5, 3:= 5, 4:= 20, 5:= 5, 6:= 20, 7:= 20};
		    } 
		    else if (opcode == 7'h03) { // I_type --> Load
		        funct3 == 3'h2; // Only Load Word 
		    } 
		    else if (opcode == 7'h23) { // S_type --> Store
		        funct3 == 3'h2; // Only Store Word
		    }
		    else if (opcode == 7'h63) { // B_type --> Branch
		        funct3 dist {0:= 20, 1:=20, 4:= 15, 5:= 15, 6:= 15, 7:= 15};
		    }
		    else if (opcode == 7'h67) { // J_type --> Jump and link register
		        funct3 == 0;
		    }			
		}

		constraint f7 {
			if(opcode == 7'h33)  {
		
				if (funct3 == 3'h0 || funct3 == 3'h5)
					funct7 inside {7'h20 , 7'h00};
				else
					funct7 == 7'h00 ;
			}				
		}

		
		constraint immediates {

			solve load_add before immediate_I ;
			solve rs1 before immediate_I ; 

		    if (opcode == 7'h13) {
		        immediate_I inside {immediate_values}; 
		    }
		    else if (opcode == 7'h03) { 
		        immediate_I  inside {load_add - reg_file_emu[rs1] };
		    } 
		    else if (opcode == 7'h23) {
		        immediate_I + reg_file_emu[rs1] > 0; 
		    } 
		    else if (opcode == 7'h63) {
		        immediate_B inside {[0 - PC_now : PC_now - 4]}; 
		    }
		    else if (opcode == 7'h6f) {
		        immediate_J inside {[0 - PC_now : PC_now - 4]}; 
		    }
		    else if (opcode == 7'h67) {
		        immediate_I inside {[0 : PC_now - reg_file_emu[rs1] - 4]}; 
		    }
			
		}
				
		function void immediate_more() ;

			this.opcode_c.constraint_mode (0);
			this.opcode_read_more.constraint_mode (0) ;
			this.opcode_write_more.constraint_mode(0) ;
			this.opcode_immediate_more.constraint_mode(1);

		endfunction 

		function void read_more() ;

			this.opcode_c.constraint_mode (0);
			this.opcode_read_more.constraint_mode (1) ;
			this.opcode_write_more.constraint_mode(0) ;
			this.opcode_immediate_more.constraint_mode(0);

		endfunction

		function void write_more() ;

			this.opcode_c.constraint_mode (0);
			this.opcode_read_more.constraint_mode (0) ;
			this.opcode_write_more.constraint_mode(1) ;
			this.opcode_immediate_more.constraint_mode(0);

		endfunction

		function void normal() ;

			this.opcode_c.constraint_mode (1);
			this.opcode_read_more.constraint_mode (0) ;
			this.opcode_write_more.constraint_mode(0) ;
			this.opcode_immediate_more.constraint_mode(0);

		endfunction

		function logic [31:0] instruction ();

			// $display("immediate = %h ",immediate_I );  
			
			case(opcode)

				7'h33: begin // R_type
					instruction = {funct7,rs2,rs1,funct3,rd,opcode}	;
				end

				7'h13: begin // I_type
            		 instruction = {immediate_I[11:0] , rs1 , funct3, rd,opcode} ;
                end 
                	
				7'h03: begin // I_type --> Load
					 instruction = {immediate_I [11:0] , rs1 , funct3, rd,opcode} ;
				end

				7'h23: begin // S_type --> Store
	                instruction = {immediate_I [11:5] , rs2 , rs1 , funct3, immediate_I[4:0] ,opcode}  ;
           		end

				7'h63: begin //B_type --> Branch
					 instruction = { { immediate_B[12],immediate_B [10:5] } , rs2 , rs1 ,funct3 ,{immediate_B[4:1],immediate_B[11] },opcode } ;
				end

				7'h6f: begin	//J_type --> Jump and link
					 instruction = { {immediate_J[20], immediate_J[10:1], immediate_J[11], immediate_J[19:12]} ,rd,opcode} ;
				end

				7'h67: begin // J_type --> Jump and link register
            		 instruction = {immediate_I , rs1 , funct3, rd,opcode} ;
				end

			endcase

		endfunction 	

	endclass	
endpackage 