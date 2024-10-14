module reg_file (clk, rst_n, a1, a2, a3, wd3, we3, rd1, rd2);

    //-----------------Parameter Declaration -----------------------------
    parameter reg_file_depth = 32; // This register file has 32 slots or registers
    localparam add_width = $clog2(reg_file_depth); // The bits needed to address registers in the file
    localparam data_width = 32; // The data in this RiscV is 32 bits wide

    //---------------------Input Ports Declaration------------------------ 
    input wire clk, rst_n, we3;
    input wire [add_width-1:0] a1, a2, a3; 
    input wire [data_width-1:0] wd3;

    //---------------------Output Ports Declaration -----------------------
    output wire [data_width-1:0] rd1, rd2;

    //-----------------Reg File Declaration ------------------------------
    reg [data_width-1:0] file [reg_file_depth-1:0];

    integer i;

    always @(posedge clk or negedge rst_n) begin 
        if (~rst_n) begin
            for (i = 0; i < reg_file_depth; i = i + 1) begin
                file[i] <= 32'b0;
            end
        end else begin
            if (we3 && a3 != 5'd0) begin 
                file[a3] <= wd3;
            end
            else 
                file[a3] <= file[a3];
            file[0] <= 32'b0; // Tie first register X0 to constant zero stuck at zero error

        end

    end

    assign rd1 = file[a1];
    assign rd2 = file[a2];

endmodule

