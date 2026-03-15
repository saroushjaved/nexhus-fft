`timescale 1ns/1ps

module twiddle_rom #(
    parameter int N = 16
)(
    input  logic [$clog2(N)-1:0] tw_addr,
    output logic signed [31:0]   tw_data
);

    // ROM storage: {real[15:0], imag[15:0]} in Q1.15
    logic signed [31:0] rom [0:N-1];

    initial begin
        $readmemh("twiddle1024.mem", rom);
    end

    // Single combinational read port
    assign tw_data = rom[tw_addr];

endmodule