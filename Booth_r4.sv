`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.09.2026 09:50:45
// Design Name: 
// Module Name: Booth_r4
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


module Booth_r4 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [11:0] a,
    input  logic [11:0] b,
    output logic [23:0] p
);

    // ------------------------------------------------------------
    // Radix-4 Booth recoding
    //
    // {2'b00, a, 1'b0}
    //
    //        a[11:0]
    //       +--------+
    // q = 00| multiplier |0
    //       +--------+
    //
    // 7 overlapping groups of 3 bits are required.
    // ------------------------------------------------------------

    logic [14:0] q;

    // Seven Booth partial products
    logic signed [23:0] res [0:6];

    // Final combinational sum
    logic signed [23:0] sum;

    integer i;

    // Append zero to LSB and two zeros to MSB
    assign q = {2'b00, a, 1'b0};

    // ------------------------------------------------------------
    // Radix-4 Booth partial-product generation and accumulation
    // ------------------------------------------------------------

    always_comb begin

        // Important: initialize sum before accumulation
        sum = 24'sd0;

        // Generate seven partial products
        for (i = 0; i < 7; i = i + 1) begin

            case ({q[2*i+2], q[2*i+1], q[2*i]})

                // ------------------------------------------------
                // 001 or 010 -> +1 × b
                // ------------------------------------------------
                3'b001,
                3'b010: begin
                    res[i] =
                        $signed({12'b0, b}) <<< (2*i);
                end

                // ------------------------------------------------
                // 011 -> +2 × b
                // ------------------------------------------------
                3'b011: begin
                    res[i] =
                        $signed({12'b0, b}) <<< (2*i + 1);
                end

                // ------------------------------------------------
                // 100 -> -2 × b
                // ------------------------------------------------
                3'b100: begin
                    res[i] =
                        -($signed({12'b0, b}) <<< (2*i + 1));
                end

                // ------------------------------------------------
                // 101 or 110 -> -1 × b
                // ------------------------------------------------
                3'b101,
                3'b110: begin
                    res[i] =
                        -($signed({12'b0, b}) <<< (2*i));
                end

                // ------------------------------------------------
                // 000 or 111 -> 0
                // ------------------------------------------------
                3'b000,
                3'b111: begin
                    res[i] = 24'sd0;
                end

                default: begin
                    res[i] = 24'sd0;
                end

            endcase

            // Accumulate partial products
            sum = sum + res[i];

        end

    end

    // ------------------------------------------------------------
    // Output register
    // ------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            p <= 24'd0;
        end
        else begin
            p <= sum;
        end

    end

endmodule
