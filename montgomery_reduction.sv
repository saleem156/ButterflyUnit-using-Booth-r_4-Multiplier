`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 23:27:17
// Design Name: 
// Module Name: montgomery_reduction
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
// 2. Montgomery Modular Reduction Top
// ==========================================
module montgomery_reduction #(
    parameter int Q         = 3329,
    parameter int QH        = 13,
    parameter int WORD_SIZE = 8
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [23:0] P_in,  
    output logic [11:0] C_out  
);

    // Intermediate pipeline wires
    logic [15:0] P_red1;
    logic [13:0] P_red2;
    
    // Sub-module requires qH as an input port, not a parameter
    logic [3:0]  qH_val;
    assign qH_val = QH[3:0];

    // Modular reduction sub unit #1 (24-bit -> 16-bit)
    mod_red #(
        .INPUT_WIDTH(24),
        .OUTPUT_WIDTH(16),
        .WORD_SIZE(WORD_SIZE),
        .QH_WIDTH(4)
    ) sub_unit_1 (
        .clk   (clk),
        .rst_n (rst_n),
        .T1    (P_in),
        .qH    (qH_val),
        .C     (P_red1)
    );
    
    // Modular reduction sub unit #2 (16-bit -> 14-bit)
    mod_red #(               //modular substraction
        .INPUT_WIDTH(16),
        .OUTPUT_WIDTH(14),
        .WORD_SIZE(WORD_SIZE),
        .QH_WIDTH(4)
    ) sub_unit_2 (
        .clk   (clk),
        .rst_n (rst_n),
        .T1    (P_red1),       // Fixed port name 
        .qH    (qH_val),       // Added missing connection
        .C     (P_red2)
    );

    // Final Subtractor and MUX Stage
    logic [11:0] final_res;
    logic [13:0] T4; 

    assign T4 = P_red2 - Q; 
    assign final_res = (P_red2 < Q) ? P_red2[11:0] : T4[11:0];

    // Final Output Register (DFF)
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            C_out <= '0;
        end else begin
            C_out <= final_res;
        end
    end

endmodule
