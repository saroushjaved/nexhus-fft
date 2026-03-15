`timescale 1ns/1ps

module tb_fft_stage_core_controller;

    localparam int N  = 16;
    localparam int AW = $clog2(N);

    logic                 clk;
    logic                 rst_n;
    logic                 start;
    logic [3:0]           stage;
    logic                 done;
    logic                 busy;

    logic                 ext_we;
    logic [AW-1:0]        ext_waddr;
    logic [31:0]          ext_wdata;
    logic [AW-1:0]        ext_raddr;
    logic [31:0]          ext_rdata;

    integer i;
    logic signed [15:0] re, im;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------
    fft_stage_core_controller #(
        .N(N)
    ) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (start),
        .stage    (stage),
        .done     (done),
        .busy     (busy),

        .ext_we   (ext_we),
        .ext_waddr(ext_waddr),
        .ext_wdata(ext_wdata),
        .ext_raddr(ext_raddr),
        .ext_rdata(ext_rdata)
    );

    // ------------------------------------------------------------
    // Clock
    // ------------------------------------------------------------
    always #5 clk = ~clk;

    // ------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------
    task automatic write_sample(
        input logic [AW-1:0] addr,
        input logic [31:0]   data
    );
    begin
        @(posedge clk);
        ext_we    <= 1'b1;
        ext_waddr <= addr;
        ext_wdata <= data;

        @(posedge clk);
        ext_we    <= 1'b0;
        ext_waddr <= '0;
        ext_wdata <= '0;
    end
    endtask

    task automatic read_sample(
        input  logic [AW-1:0] addr,
        output logic [31:0]   data
    );
    begin
        ext_raddr <= addr;
        #1;
        data = ext_rdata;
    end
    endtask

    task automatic load_test_vector;
    begin
        // sample i = {real=i, imag=-i}
        for (i = 0; i < N; i = i + 1) begin
            write_sample(i[AW-1:0], {16'(i), 16'(-i)});
        end
    end
    endtask

    task automatic dump_memory(input string tag);
        logic [31:0] tmp;
    begin
        $display("---- %s ----", tag);
        for (i = 0; i < N; i = i + 1) begin
            read_sample(i[AW-1:0], tmp);
            re = tmp[31:16];
            im = tmp[15:0];
            $display("MEM[%0d] = %0d + j%0d", i, re, im);
        end
    end
    endtask

    task automatic run_stage(input logic [3:0] stg);
    begin
        stage = stg;

        @(posedge clk);
        start <= 1'b1;

        @(posedge clk);
        start <= 1'b0;

        wait (done == 1'b1);
        @(posedge clk);

        $display("Controller stage %0d completed at time %0t", stg, $time);
    end
    endtask

    // ------------------------------------------------------------
    // Optional monitor
    // ------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst_n) begin
            if (start)
                $display("[%0t] start asserted, stage=%0d", $time, stage);
            if (done)
                $display("[%0t] done asserted, stage=%0d", $time, stage);
        end
    end

    // ------------------------------------------------------------
    // Stimulus
    // ------------------------------------------------------------
    initial begin
        clk      = 1'b0;
        rst_n    = 1'b0;
        start    = 1'b0;
        stage    = '0;
        ext_we   = 1'b0;
        ext_waddr= '0;
        ext_wdata= '0;
        ext_raddr= '0;

        repeat (4) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        // Stage 0
        load_test_vector();
        dump_memory("INPUT BEFORE STAGE 0");
        run_stage(4'd0);
        dump_memory("OUTPUT AFTER STAGE 0");

        // Stage 1
        load_test_vector();
        repeat (2) @(posedge clk);
        dump_memory("INPUT BEFORE STAGE 1");
        run_stage(4'd1);
        dump_memory("OUTPUT AFTER STAGE 1");

        // Stage 2
        load_test_vector();
        repeat (2) @(posedge clk);
        dump_memory("INPUT BEFORE STAGE 2");
        run_stage(4'd2);
        dump_memory("OUTPUT AFTER STAGE 2");

        // Stage 3
        load_test_vector();
        repeat (2) @(posedge clk);
        dump_memory("INPUT BEFORE STAGE 3");
        run_stage(4'd3);
        dump_memory("OUTPUT AFTER STAGE 3");

        $display("TB completed.");
        $finish;
    end

endmodule