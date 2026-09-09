`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 23:20:42
// Design Name: 
// Module Name: bu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module bu #(                               //gs_butterfly 
    parameter logic [11:0] Q = 12'd3329
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [11:0] in0,     // Data BRAM #0
    input  logic [11:0] in1,     // Data BRAM #1
    input  logic [11:0] in_mult, // TW BRAM (w^i)
    output logic [11:0] out_E,   // Top Path Output
    output logic [11:0] out_O    // Bottom Path Output
);

    // ==========================================
    // 1. Modular Add & Sub (Combinational Stage)
    // ==========================================
    logic [12:0] add_temp;
    logic [11:0] add_mod;
    logic [11:0] sub_mod;
    logic [12:0] temp;
    logic [11:0] temp_sub;
    // Top Path (Add)
    assign add_temp = in0 + in1;
    assign temp = add_temp -Q;
    assign add_mod  = temp[12] ? add_temp[11:0] : temp[11:0];

    // Bottom Path (Sub)
    // Unsigned trick: Add Q if in1 > in0 to prevent negative numbers
    logic [12:0] raw_sub;
    
    // 2. Pad to 13 bits and subtract
    assign raw_sub = {1'b0, in0} - {1'b0, in1};
    assign temp_sub = raw_sub[11:0] + Q;
    assign sub_mod = raw_sub[12] ? temp_sub : raw_sub[11:0];
//    assign sub_mod  = (in0 < in1) ? ((in0 + Q) - in1) : (in0 - in1);


    // ==========================================
    // 2. The Multiplier (Bottom Path "X & DFF")
    // ==========================================
    // We instantiate your 6-cycle pipelined Montgomery Multiplier here.
    // This perfectly covers the "X" and the output "DFF" shown in the diagram.
    mod_multiplier mult_inst (
        .clk   (clk),
        .rst_n (rst_n),
        .A     (sub_mod),
        .B     (in_mult),
        .C_out (out_O)
    );
    
    // ==========================================
    // 3. The Delay Pipeline (Top Path "DFFs")
    // ==========================================
    // Because the multiplier takes exactly 6 cycles, the top path 'E' 
    // must also be delayed by 6 cycles so 'E' and 'O' arrive at the 
    // next Processing Element stage at the exact same time.
    (* shreg_extract = "no" *)
    logic [11:0] e_pipe [0:5];
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            for (int i = 0; i < 5; i++) begin
                e_pipe[i] <= '0;
            end
            out_E <='0;
        end else begin
            // Shift data down the pipeline
            e_pipe[0] <= add_mod;
            e_pipe[1] <= e_pipe[0];
            e_pipe[2] <= e_pipe[1];
            e_pipe[3] <= e_pipe[2];
            e_pipe[4] <= e_pipe[3];
            out_E <= e_pipe[4];
            
        end
    end

//    // Assign the end of the pipeline to the final output
//    assign out_E = e_pipe[5];

endmodule
