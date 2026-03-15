`timescale 1ns/1ps

module tb_fft_stage_core;

    localparam int N     = 16;
    localparam int AW    = $clog2(N);
    localparam int TW_AW = $clog2(N/2);

    logic clk;
    logic rst_n;
    logic start;
    logic [3:0] stage;
    logic done;
    logic busy;

    // DUT sample RAM ports
    logic [AW-1:0]    rd_addr_a;
    logic [AW-1:0]    rd_addr_b;
    logic [31:0]      rd_data_a;
    logic [31:0]      rd_data_b;

    logic             wr_en_a;
    logic             wr_en_b;
    logic [AW-1:0]    wr_addr_a;
    logic [AW-1:0]    wr_addr_b;
    logic [31:0]      wr_data_a;
    logic [31:0]      wr_data_b;

    logic [TW_AW-1:0] tw_addr;
    logic [31:0]      tw_data;

    // Simple behavioral memories
    logic [31:0] sample_mem [0:N-1];
    logic [31:0] tw_mem     [0:(N/2)-1];

    integer i;

    fft_stage_core #(
        .N(N)
    ) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (start),
        .stage    (stage),
        .done     (done),
        .busy     (busy),

        .rd_addr_a(rd_addr_a),
        .rd_addr_b(rd_addr_b),
        .rd_data_a(rd_data_a),
        .rd_data_b(rd_data_b),

        .wr_en_a  (wr_en_a),
        .wr_en_b  (wr_en_b),
        .wr_addr_a(wr_addr_a),
        .wr_addr_b(wr_addr_b),
        .wr_data_a(wr_data_a),
        .wr_data_b(wr_data_b),

        .tw_addr  (tw_addr),
        .tw_data  (tw_data)
    );

    // Clock
    always #5 clk = ~clk;

    // Async-read RAM/ROM models
    assign rd_data_a = sample_mem[rd_addr_a];
    assign rd_data_b = sample_mem[rd_addr_b];
    assign tw_data   = tw_mem[tw_addr];

    // Writeback model
    always_ff @(posedge clk) begin
        if (wr_en_a) sample_mem[wr_addr_a] <= wr_data_a;
        if (wr_en_b) sample_mem[wr_addr_b] <= wr_data_b;
    end

    task automatic init_sample_mem;
    begin
        for (i = 0; i < N; i = i + 1) begin
            sample_mem[i] = {16'(i), 16'(-i)};
        end
    end
    endtask

    task automatic init_twiddles;
    begin
        for (i = 0; i < N/2; i = i + 1) begin
            tw_mem[i] = 32'h7FFF0000;
        end
    end
    endtask

    task automatic dump_sample_mem(input string tag);
    begin
        $display("---- %s ----", tag);
        for (i = 0; i < N; i = i + 1) begin
            $display("mem[%0d] = %0d + j%0d",
                     i,
                     $signed(sample_mem[i][31:16]),
                     $signed(sample_mem[i][15:0]));
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

        wait(done == 1'b1);
        @(posedge clk);

        $display("Stage %0d completed at time %0t", stg, $time);
    end
    endtask

    // Address trace monitor
    always_ff @(posedge clk) begin
        if (rst_n && busy) begin
            $display("[%0t] state-active  stage=%0d rd_a=%0d rd_b=%0d tw=%0d wr_a=%0d wr_b=%0d we_a=%0b we_b=%0b",
                     $time, stage,
                     rd_addr_a, rd_addr_b, tw_addr,
                     wr_addr_a, wr_addr_b,
                     wr_en_a, wr_en_b);
        end
    end

    initial begin
        clk   = 1'b0;
        rst_n = 1'b0;
        start = 1'b0;
        stage = '0;

        init_sample_mem();
        init_twiddles();

        repeat (4) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        dump_sample_mem("Initial Memory");

        run_stage(4'd0);
        dump_sample_mem("After Stage 0");

        init_sample_mem();
        repeat (2) @(posedge clk);
        run_stage(4'd1);
        dump_sample_mem("After Stage 1");

        init_sample_mem();
        repeat (2) @(posedge clk);
        run_stage(4'd2);
        dump_sample_mem("After Stage 2");

        init_sample_mem();
        repeat (2) @(posedge clk);
        run_stage(4'd3);
        dump_sample_mem("After Stage 3");

        $display("TB completed.");
        $finish;
    end

endmodule