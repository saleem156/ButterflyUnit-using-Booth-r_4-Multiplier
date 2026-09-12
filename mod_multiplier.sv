
module mod_multiplier_Booth #(
    parameter logic [11:0] Q  = 12'd3329,
    parameter logic [11:0] MU = 12'd3327
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [11:0] A,
    input  logic [11:0] B,
    output logic [11:0] C_out
);
 
    // ------------------------------------------------------------
    // KM1: p = A*B  ->  MH (high 12b) / ML (low 12b)   -- latency L=1
    // ------------------------------------------------------------
    logic [11:0] mh, ml;
    Booth_r4 BM1 (
        .clk   (clk),
        .rst_n (rst_n),
        .a     (A),
        .b     (B),
        .h     (mh),
        .l     (ml)
    );
 
    logic ml_nonzero;
    assign ml_nonzero = |ml;
 
    // FIX: delay chain depth must be D = 2*L = 2 (was 4, sized for the
    // old 2-cycle Booth_r4). With the new single-cycle Booth_r4 (L=1),
    // the KM1->KM2->KM3 reduction path takes 3*L = 3 cycles, and the
    // direct mh path takes L + D cycles -- these only line up at the
    // adder when D = 2.
    logic [11:0] mh1, mh2;
    logic        ml1, ml2;
 
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            mh1 <= '0; mh2 <= '0;
            ml1 <= 1'b0; ml2 <= 1'b0;
        end else begin
            mh1 <= mh;         mh2 <= mh1;
            ml1 <= ml_nonzero; ml2 <= ml1;
        end
    end
 
    // MU is a compile-time constant -- it never changes cycle to
    // cycle, so no delay register is needed to "synchronize" it.
    // ------------------------------------------------------------
    // KM2: m = ML * MU  -> only the low 12 bits ("mul") are needed
    // ------------------------------------------------------------
    logic [11:0] muh, mul;
    Booth_r4 BM2 (
        .clk   (clk),
        .rst_n (rst_n),
        .a     (ml),
        .b     (MU),
        .h     (muh),   // unused
        .l     (mul)
    );
 
    // Q is likewise a compile-time constant -- feed it directly.
    // ------------------------------------------------------------
    // KM3: (m*Q) -> only the high 12 bits, (mp)_H = "mqh", are needed
    // ------------------------------------------------------------
    logic [11:0] mqh, mql;
    Booth_r4 BM3 (
        .clk   (clk),
        .rst_n (rst_n),
        .a     (mul),
        .b     (Q),
        .h     (mqh),
        .l     (mql)    // unused
    );
 
    // ------------------------------------------------------------
    // MA: z = MH + (mp)_H (+1 if ML != 0), then conditional -Q.
    // ------------------------------------------------------------
    logic [12:0] z_sum;
    logic [12:0] z_red;
    assign z_sum = {1'b0, mh2} + {1'b0, mqh} + {12'd0, ml2};
    assign z_red = z_sum - {1'b0, Q};
 
    always_ff @(posedge clk) begin
        if (!rst_n) C_out <= '0;
        else        C_out <= z_red[12] ? z_sum[11:0] : z_red[11:0];
    end
 
endmodule
 

 
