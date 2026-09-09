`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 23:26:43
// Design Name: 
// Module Name: mod_multiplier
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


// ==========================================
// 1. Full NTT Multiplier Wrapper
// ==========================================
module mod_multiplier (
    input  logic        clk,
    input  logic        rst_n, // Synced to active-low
    input  logic [11:0] A,
    input  logic [11:0] B,
    output logic [11:0] C_out
);

    // DSP-based Integer Multiplier
    logic [23:0] P_reg;
    // ==========================================
    // 1. DSP-based Integer Multiplier
    // ==========================================
    
    // Notice: negedge rst_n is removed from here!
    Booth_r4 bm1(.clk(clk), .rst_n(rst_n), .a(A), .b(B), .p(P_reg));
   
//    always @(posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            P_reg <= 0;
//        end else begin
//            // Explicitly requesting DSP synthesis
////           
////             (* use_dsp = "yes" *) 
//P_reg <= A * B; // works even without it
//        end
//    end

//assign P_reg = A * B;

    // Montgomery Modular Reduction Top
    montgomery_reduction #(
        .Q(3329),
        .QH(13),
        .WORD_SIZE(8)
    ) reduction_unit (
        .clk   (clk),
        .rst_n (rst_n),
        .P_in  (P_reg),     
        .C_out (C_out)      
    );

endmodule
