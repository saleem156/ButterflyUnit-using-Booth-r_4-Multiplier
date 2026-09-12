module bu_tb;

    parameter int Q       = 3329;
    parameter int R       = 4096; 
    parameter int R_INV   = 2704; 
    parameter int LATENCY = 4;  

    logic        clk;
    logic        rst_n;
    logic [11:0] in0;
    logic [11:0] in1;
    logic [11:0] in_mult;
    logic [11:0] out_E;
    logic [11:0] out_O;

    integer expected_E;
    integer temp_sub;
    integer expected_O;

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

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task automatic check_later(input int eE, input int eO, input string tag);
        fork
            begin
                repeat (LATENCY) @(posedge clk);
                #1; // let NBAs settle before sampling out_E/out_O

                if (out_E === eE[11:0] && out_O === eO[11:0]) begin
                    $display("   [%s] PASS  @%0t : out_E=%0d out_O=%0d",
                              tag, $time, out_E, out_O);
                end
                else begin
                    $display("   [%s] FAIL  @%0t : got(out_E=%0d, out_O=%0d)  exp(E=%0d, O=%0d)",
                              tag, $time, out_E, out_O, eE, eO);
                end
            end
        join_none
    endtask

    // Stimulus and Reference Generation
    initial begin

        // 1. Initialize & Hold Reset for 100ns
        in0     = 12'd0;
        in1     = 12'd0;
        in_mult = 12'd0;
        rst_n   = 0;
        #100;

        // Sync to clock edge and release reset safely
        @(posedge clk);
        #7;
        rst_n = 1;

        $display(" GENTLEMAN-SANDE BUTTERFLY REFERENCE TABLE ");
        $display(" * Expect to see these results on out_E and out_O exactly %0d cycles later.", LATENCY);
        $display(" Time |  in0 |  in1 | Twiddle | Expected E (Top) | Expected O (Bottom) ");

        // =========================
        // Case 1
        // =========================
        @(negedge clk);
        in0 = 12'd2317;
        in1 = 12'd1913;
        in_mult = (12'd1 * R) % Q;

        expected_E = (in0 + in1) % Q;
        temp_sub   = (in0 < in1) ? ((in0 + Q) - in1) : (in0 - in1);
        expected_O = (temp_sub * 1) % Q;

        $display("%5t | %4d | %4d | %7d | %16d | %19d",
                 $time, in0, in1, in_mult, expected_E, expected_O);

        check_later(expected_E, expected_O, "Case1");

        // =========================
        // Case 2
        // =========================
        @(negedge clk);
        in0 = 12'd2351;
        in1 = 12'd384;
        in_mult = (12'd17 * R) % Q;

        expected_E = (in0 + in1) % Q;
        temp_sub   = (in0 < in1) ? ((in0 + Q) - in1) : (in0 - in1);
        expected_O = (temp_sub * 17) % Q;

        $display("%5t | %4d | %4d | %7d | %16d | %19d",
                 $time, in0, in1, in_mult, expected_E, expected_O);

        check_later(expected_E, expected_O, "Case2");

        // =========================
        // Case 3
        // =========================
        @(negedge clk);
        in0 = 12'd901;
        in1 = 12'd2735;
        in_mult = (12'd1 * R) % Q;

        expected_E = (in0 + in1) % Q;
        temp_sub   = (in0 < in1) ? ((in0 + Q) - in1) : (in0 - in1);
        expected_O = (temp_sub * 1) % Q;

        $display("%5t | %4d | %4d | %7d | %16d | %19d",
                 $time, in0, in1, in_mult, expected_E, expected_O);

        check_later(expected_E, expected_O, "Case3");

        // =========================
        // Case 4
        // =========================
        @(negedge clk);
        in0 = 12'd404;
        in1 = 12'd149;
        in_mult = (12'd1 * R) % Q;

        expected_E = (in0 + in1) % Q;
        temp_sub   = (in0 < in1) ? ((in0 + Q) - in1) : (in0 - in1);
        expected_O = (temp_sub * 1) % Q;

        $display("%5t | %4d | %4d | %7d | %16d | %19d",
                 $time, in0, in1, in_mult, expected_E, expected_O);

        check_later(expected_E, expected_O, "Case4");

        // =========================
        // Flush the pipeline
        // =========================
        @(negedge clk);
        in0     = '0;
        in1     = '0;
        in_mult = '0;

        $display(" Inputs stopped. Waiting %0d cycles for the pipeline to drain...",
                 LATENCY);

        repeat(LATENCY + 2) @(posedge clk);

        $display(" Testbench Finished");
        $finish;

    end

endmodule
