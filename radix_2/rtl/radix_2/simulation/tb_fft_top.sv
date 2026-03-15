`timescale 1ns/1ps

module tb_new_fft_top_16;

    localparam int N  = 16;
    localparam int AW = $clog2(N);

    logic                 clk;
    logic                 rst_n;
    logic                 start;
    logic                 done;
    logic                 busy;

    logic                 ext_we;
    logic [AW-1:0]        ext_waddr;
    logic [31:0]          ext_wdata;
    logic [AW-1:0]        ext_raddr;
    logic [31:0]          ext_rdata;

    integer i;
    logic signed [15:0] re, im;
    logic [31:0] tmp_word;
    logic [AW-1:0] rd_idx;
    logic [AW-1:0] wr_idx;

    // ------------------------------------------------------------
    // DUT: new BRAM-based fft_top
    // ------------------------------------------------------------
    fft_top #(
        .N(N)
    ) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (start),
        .done     (done),
        .busy     (busy),

        .ext_we   (ext_we),
        .ext_waddr(ext_waddr),
        .ext_wdata(ext_wdata),
        .ext_raddr(ext_raddr),
        .ext_rdata(ext_rdata)
    );

    // clock
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

    task automatic load_test_vector_reversed;
    begin
        // Reverse BRAM addresses so the new BRAM model matches
        // the old giant-bus logical ordering.
        for (i = 0; i < N; i = i + 1) begin
            wr_idx = N-1-i;
            write_sample(wr_idx, {16'(i), 16'(-i)});
        end
    end
    endtask

    task automatic dump_memory_raw(input string tag);
    begin
        $display("---- %s ----", tag);
        for (i = 0; i < N; i = i + 1) begin
            rd_idx = i;
            read_sample(rd_idx, tmp_word);
            re = tmp_word[31:16];
            im = tmp_word[15:0];
            $display("MEM[%0d] = %0d + j%0d", i, re, im);
        end
    end
    endtask

    initial begin
        clk       = 1'b0;
        rst_n     = 1'b0;
        start     = 1'b0;
        ext_we    = 1'b0;
        ext_waddr = '0;
        ext_wdata = '0;
        ext_raddr = '0;

        repeat (4) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        load_test_vector_reversed();

        dump_memory_raw("NEW RAW MEMORY BEFORE FULL FFT");

        @(posedge clk);
        start <= 1'b1;

        @(posedge clk);
        start <= 1'b0;

        wait(done);
        #20;

        $display("\nNEW FULL FFT OUTPUTS (RAW MEMORY VIEW):");
        dump_memory_raw("NEW RAW MEMORY AFTER FULL FFT");

        $display("Done.");
        $finish;
    end

endmodule