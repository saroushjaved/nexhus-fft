module twiddle_rom #(
    parameter int N      = 8,                 // number of twiddles
    parameter int NREAD  = 4,                 // parallel read ports
    parameter string MEMFILE = "twiddle8.mem"
) (
    input  logic [$clog2(N)-1:0]      waddr [0:NREAD-1],
    output logic signed [31:0]        wout  [0:NREAD-1]
);

    // ROM storage: {real[15:0], imag[15:0]} in Q1.15
    logic signed [31:0] rom [0:N-1];

    // Load ROM
    initial begin
        $readmemh(MEMFILE, rom);
    end

    // Combinational read ports
    genvar i;
    generate
        for (i = 0; i < NREAD; i++) begin : GEN_RD
            assign wout[i] = rom[waddr[i]];
        end
    endgenerate

endmodule