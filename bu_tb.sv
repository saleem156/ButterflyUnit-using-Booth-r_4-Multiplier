`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 23:25:49
// Design Name: 
// Module Name: bu_tb
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




module bu_tb;

    // ==========================================
    // Parameters
    // ==========================================
    parameter int Q       = 3329;
    parameter int R_INV   = 169;  // R^-1 mod Q 
    parameter int LATENCY = 6;    // Butterfly pipeline depth
    parameter int R       = 2285; // R = 2^(w*L)

    // ==========================================
    // Signals
    // ==========================================
    logic        clk;
    logic        rst_n;
    logic [11:0] in0;
    logic [11:0] in1;
    logic [11:0] in_mult;
    logic [11:0] out_E;
    logic [11:0] out_O;

    // Software variables for the console reference table
    integer expected_E;
    integer temp_sub;
    integer expected_O;

    // ==========================================
    // DUT Instantiation
    // ==========================================
    bu #(
        .Q(12'd3329) 
    ) DUT (
        .clk     (clk),
        .rst_n   (rst_n),
        .in0     (in0),
        .in1     (in1),
        .in_mult (in_mult),
        .out_E   (out_E),
        .out_O   (out_O)
    );

    // ==========================================
    // Clock Generation (100 MHz)
    // ==========================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // ==========================================
    // Stimulus and Reference Generation
    // ==========================================
    initial begin
        // 1. Initialize & Hold Reset for 100ns
        in0     = 12'd0;
        in1     = 12'd0;
        in_mult = 12'd0;
        rst_n   = 0;
        #100;
        
        // Sync to clock edge and release reset safely
        @(posedge clk);
        #7; // SAFE INJECTION WINDOW
        rst_n = 1;

        $display("=========================================================================");
        $display("                 GENTLEMAN-SANDE BUTTERFLY REFERENCE TABLE               ");
        $display(" * Expect to see these results on out_E and out_O exactly 6 cycles later.");
        $display("=========================================================================");
        $display(" Time |  in0 |  in1 | Twiddle | Expected E (Top) | Expected O (Bottom) ");
        $display("-------------------------------------------------------------------------");

        // ---------------------------------------------------------
        // Feed the Kyber Index Cases
        // ---------------------------------------------------------

        // Case 1
        @(negedge clk); 
        in0 = 12'd2317; in1 = 12'd1913; 
        in_mult = (12'd1 * R) % Q; 
        
        expected_E = (in0 + in1) % Q;
        temp_sub   = (in0 < in1) ? ((in0 + Q) - in1) : (in0 - in1);
        expected_O = (temp_sub * 1) % Q; 
        $display("%5t | %4d | %4d | %7d | %16d | %19d", $time, in0, in1, in_mult, expected_E, expected_O);

        // Case 2
        @(negedge clk); 
        in0 = 12'd2351; in1 = 12'd384; 
        in_mult = (12'd17 * R) % Q; 
        
        expected_E = (in0 + in1) % Q;
        temp_sub   = (in0 < in1) ? ((in0 + Q) - in1) : (in0 - in1);
        expected_O = (temp_sub * 17) % Q; 
        $display("%5t | %4d | %4d | %7d | %16d | %19d", $time, in0, in1, in_mult, expected_E, expected_O);

        // Case 3
        @(negedge clk); 
        in0 = 12'd901; in1 = 12'd2735; 
        in_mult = (12'd1 * R) % Q; 
        
        expected_E = (in0 + in1) % Q;
        temp_sub   = (in0 < in1) ? ((in0 + Q) - in1) : (in0 - in1);
        expected_O = (temp_sub * 1) % Q; 
        $display("%5t | %4d | %4d | %7d | %16d | %19d", $time, in0, in1, in_mult, expected_E, expected_O);

        // Case 4
        @(negedge clk);    
        in0 = 12'd404; in1 = 12'd149; 
        in_mult = (12'd1 * R) % Q; 
        
        expected_E = (in0 + in1) % Q;
        temp_sub   = (in0 < in1) ? ((in0 + Q) - in1) : (in0 - in1);
        expected_O = (temp_sub * 1) % Q; 
        $display("%5t | %4d | %4d | %7d | %16d | %19d", $time, in0, in1, in_mult, expected_E, expected_O);

        // ---------------------------------------------------------
        // Flush the pipeline
        // ---------------------------------------------------------
        @(negedge clk); ; 
        in0 = '0; 
        in1 = '0;
        in_mult = '0;
        $display("-------------------------------------------------------------------------");
        $display(" Inputs stopped. Waiting 6 cycles for the pipeline to drain...           ");

        repeat(LATENCY + 2) @(posedge clk);

        $display("=========================================================================");
        $display(" Testbench Finished. ");
        $finish;
    end

endmodule

