`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 23:27:57
// Design Name: 
// Module Name: mod_red
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


module mod_red #(
    // Default parameters based on the paper's specification for Sub-unit #1
    parameter int INPUT_WIDTH  = 24, // 'M' in the paper's description (e.g., 24 for sub-unit #1)
    parameter int WORD_SIZE    = 8,  // 'w' in the paper (8 bits for q = 3329)
    parameter int QH_WIDTH     = 4,  // Width to hold qH = 13 (4 bits)
    parameter int OUTPUT_WIDTH = 16  // Output P_red width (16 bits for sub-unit #1)
)(
    input  logic                    clk,
    input  logic                    rst_n, // Active-low reset
    input  logic [INPUT_WIDTH-1:0]  T1,    // Input data
    input  logic [QH_WIDTH-1:0]     qH,    // High part of modulo (13)
    output logic [OUTPUT_WIDTH-1:0] C      // Reduced output data
);

    // ==========================================
    // STAGE 1: Combinational Logic (Pre-Pipeline)
    // ==========================================
    
    logic [WORD_SIZE-1:0]                 T2L;
    logic [WORD_SIZE-1:0]                 T2;
    logic [(WORD_SIZE + QH_WIDTH)-1:0]    mult_t;
    logic                                 carry_t;
    logic [(INPUT_WIDTH - WORD_SIZE)-1:0] T2H_t;

    // Extract the lower word (T1[7:0])
    assign T2L = T1[WORD_SIZE-1:0];
    
    // Two's complement of T2L
    assign T2 = ~T2L + 1'b1; 
    
    // DSP/Multiplier unit: qH * T2
    assign mult_t = qH * T2;
    
    // OR gate for carry generation: T2[7] OR T2L[7]
    assign carry_t = T2[WORD_SIZE-1] | T2L[WORD_SIZE-1];
    
    // Shift right by word size (equivalent to T1 >> 8)
    assign T2H_t = T1[INPUT_WIDTH-1 : WORD_SIZE];


    // ==========================================
    // STAGE 2: Pipeline Registers (DFFs)
    // ==========================================
    
    logic [(WORD_SIZE + QH_WIDTH)-1:0]    mult;
    logic                                 carry;
    logic [(INPUT_WIDTH - WORD_SIZE)-1:0] T2H;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            mult  <= '0;
            carry <= '0;
            T2H   <= '0;
        end else begin
            mult  <= mult_t;
            carry <= carry_t;
            T2H   <= T2H_t;
        end
    end


    // ==========================================
    // STAGE 3: Final Adder
    // ==========================================
    
    logic [OUTPUT_WIDTH-1:0] C_t;
    
    // Summation of the pipelined stages
    assign C_t = T2H + mult + carry;


    // ==========================================
    // STAGE 4: Output Register (Final DFF)
    // ==========================================
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            C <= '0;
        end else begin
            C <= C_t;
        end
    end

endmodule

