`timescale 1ns/1ps

module tb_fft_stage_core_controller;

    localparam integer N          = 8;
    localparam integer CORE_CYCLES = 2;

    reg                     clk;
    reg                     rst_n;
    reg                     start;
    reg  [3:0]              stage;
    reg  [N*32-1:0]         fft_data_in;
    wire                    done;

    // ASSUMED output - rename if needed
    wire [N*32-1:0]         fft_data_out;

    // DUT
    fft_stage_core_controller #(
        .N(N),
        .CORE_CYCLES(CORE_CYCLES)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .stage(stage),
        .fft_data_in(fft_data_in),
        .fft_data_out(fft_data_out),
        .done(done)
    );

    // clock: 100 MHz
    always #5 clk = ~clk;

    integer i;
    reg signed [15:0] re, im;

    initial begin
        clk = 0;
        rst_n = 0;
        start = 0;
        stage = 0;
        fft_data_in = 0;

        // reset
        #20;
        rst_n = 1;

        // pack input data (Q1.15)
       fft_data_in = {
        16'h2000, 16'hF000,  // x[0]  +0.25    - j0.125
        16'hF000, 16'h2000,  // x[1]  -0.125   + j0.25
        16'h4000, 16'h0800,  // x[2]  +0.5     + j0.0625
        16'h1000, 16'hF800,  // x[3]  +0.125   - j0.0625
        16'hE000, 16'h1000,  // x[4]  -0.25    + j0.125
        16'h0800, 16'hE000,  // x[5]  +0.0625  - j0.25
        16'h0400, 16'h0C00,  // x[6]  +0.03125 + j0.09375
        16'hF800, 16'hF000   // x[7]  -0.0625  - j0.125
    };

        // select stage (0..2 for N=8)
        stage = 0;

        // start pulse
        #10;
        start = 1;
        #10;
        start = 0;

        // wait for completion
        wait (done);

        $display("\nFFT OUTPUTS:");
        for (i = 0; i < N; i = i + 1) begin
            re = fft_data_out[32*(N-i)-1 -: 16];
            im = fft_data_out[32*(N-i)-17 -: 16];
            $display("Y[%0d] = %d + j%d", i, re, im);
        end

        $display("Done.");
        //#20;
        $finish;
    end

endmodule