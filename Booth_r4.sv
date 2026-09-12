 
module Booth_r4 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [11:0] a,
    input  logic [11:0] b,
    output logic [23:0] h,
    output logic [23:0] l
);
 
    logic [14:0] q;
    logic signed [23:0] res [0:6];
    logic signed [23:0] sum;
    integer i;
 
    assign q = {2'b00, a, 1'b0};
 
    always_comb begin
        sum = 24'sd0;
        for (i = 0; i < 7; i = i + 1) begin
            case ({q[2*i+2], q[2*i+1], q[2*i]})
                3'b001,
                3'b010: res[i] = $signed({12'b0, b}) <<< (2*i);
                3'b011:  res[i] = $signed({12'b0, b}) <<< (2*i + 1);
                3'b100:  res[i] = -($signed({12'b0, b}) <<< (2*i + 1));
                3'b101,
                3'b110: res[i] = -($signed({12'b0, b}) <<< (2*i));
                3'b000,
                3'b111: res[i] = 24'sd0;
                default: res[i] = 24'sd0;
            endcase
            sum = sum + res[i];
        end
    end
 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h <= 12'd0;
            l <= 12'd0;
        end else begin
            h <= sum[23:12];
            l <= sum[11:0];
        end
    end
 
endmodule
