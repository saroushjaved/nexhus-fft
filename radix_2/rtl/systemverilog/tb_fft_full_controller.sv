`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2026 11:11:03 PM
// Design Name: 
// Module Name: tb_fft_full_controller
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


module tb_fft_full_controller(

    );
endmodule
`timescale 1ns/1ps

module tb_fft_full_controller;

    localparam integer N           = 16;
    localparam integer CORE_CYCLES  = 2;

    logic                   clk;
    logic                   rst_n;
    logic                   start;
    logic [N*32-1:0]        fft_data_in;
    logic [N*32-1:0]        fft_data_out;
    logic                   done;

    // DUT: TOP wrapper that sequences stages internally
    // (Make sure the module name matches what you called it.)
    fft_top #(
        .N(N),
        .CORE_CYCLES(CORE_CYCLES),
        .TW_FILE("twiddle16.mem")   // or whatever your ROM file is named
    ) dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .start       (start),
        .fft_data_in (fft_data_in),
        .fft_data_out(fft_data_out),
        .done        (done)
    );

    // clock: 100 MHz
    always #5 clk = ~clk;

    integer i;
    logic signed [15:0] re, im;

    initial begin
        clk = 0;
        rst_n = 0;
        start = 0;
        fft_data_in = 0;

        // reset
        #20;
        rst_n = 1;

        // pack input data (Q1.15)  (UNCHANGED)
        fft_data_in = {
            16'h2000, 16'hF000,  // x[0]
            16'hF000, 16'h2000,  // x[1]
            16'h4000, 16'h0800,  // x[2]
            16'h1000, 16'hF800,  // x[3]
            16'hE000, 16'h1000,  // x[4]
            16'h0800, 16'hE000,  // x[5]
            16'h0400, 16'h0C00,  // x[6]
            16'hF800, 16'hF000,  // x[7]

            16'h3000, 16'h1000,  // x[8]
            16'hD000, 16'hF000,  // x[9]
            16'h1800, 16'h0400,  // x[10]
            16'hF400, 16'h0800,  // x[11]
            16'h0C00, 16'hE800,  // x[12]
            16'hEC00, 16'h1800,  // x[13]
            16'h0200, 16'hFE00,  // x[14]
            16'hFE00, 16'h0200   // x[15]
        };

        // start pulse (1 clock)  (UNCHANGED)
        #10;
        start = 1;
        #10;
        start = 0;

        // wait for completion of FULL FFT
        wait (done);
        #20

        $display("\nFFT OUTPUTS (FULL CYCLE):");
        for (i = 0; i < N; i = i + 1) begin
            re = fft_data_out[(N-1-i)*32 + 31 -: 16];
            im = fft_data_out[(N-1-i)*32 + 15 -: 16];
            $display("Y[%0d] = %0d + j%0d", i, re, im);
        end

        $display("Done.");
        $finish;
    end

endmodule
