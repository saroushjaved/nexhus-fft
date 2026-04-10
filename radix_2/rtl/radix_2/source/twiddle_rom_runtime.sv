`timescale 1ns / 1ps

module twiddle_rom_runtime #(
    parameter int NMAX = 2048
)(
    input  logic                         clk,
    input  logic [$clog2(NMAX/2)-1:0]   tw_addr,
    input  logic                         inverse,
    output logic signed [31:0]          tw_data
);

    localparam int DEPTH = NMAX / 2;

    (* rom_style = "block" *) logic signed [31:0] rom [0:DEPTH-1];

    function automatic logic signed [15:0] conj_imag(
        input logic signed [15:0] x
    );
        begin
            if (x == -16'sd32768)
                conj_imag = 16'sd32767;
            else
                conj_imag = -x;
        end
    endfunction

    initial begin
        $readmemh("twiddle2048.mem", rom);
    end

    always_ff @(posedge clk) begin
        if (inverse)
            tw_data <= {rom[tw_addr][31:16], conj_imag(rom[tw_addr][15:0])};
        else
            tw_data <= rom[tw_addr];
    end

endmodule
