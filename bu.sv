module bu #(
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
    assign temp     = add_temp - Q;
    assign add_mod  = temp[12] ? add_temp[11:0] : temp[11:0];
 
    // Bottom Path (Sub) - unsigned trick: add Q back if it went negative
    logic [12:0] raw_sub;
    assign raw_sub  = {1'b0, in0} - {1'b0, in1};
    assign temp_sub = raw_sub[11:0] + Q;
    assign sub_mod  = raw_sub[12] ? temp_sub : raw_sub[11:0];
 
    // ==========================================
    // 2. The Multiplier (Bottom Path "X & DFF")
    // ==========================================
    mod_multiplier_Booth #(
        .Q  (Q),
        .MU (12'd3327)   // -Q^-1 mod 4096, precomputed for Q = 3329
    ) mult_inst (
        .clk    (clk),
        .rst_n  (rst_n),
        .A      (sub_mod),
        .B      (in_mult),
        .C_out  (out_O)
    );
 
    // ==========================================
    // 3. The Delay Pipeline (Top Path "DFFs")
    // ==========================================
    // mod_multiplier_Booth's latency A,B -> C_out is now 4 cycles
    // (Booth_r4 is single-cycle: 3*L + 1 = 3*1 + 1 = 4), so the top
    // path only needs 3 shift registers + the output register = 4.
    (* shreg_extract = "no" *)
    logic [11:0] e_pipe [0:2];
 
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            for (int i = 0; i < 3; i++) begin
                e_pipe[i] <= '0;
            end
            out_E <= '0;
        end else begin
            e_pipe[0] <= add_mod;
            e_pipe[1] <= e_pipe[0];
            e_pipe[2] <= e_pipe[1];
            out_E     <= e_pipe[2];
        end
    end
 
endmodule
