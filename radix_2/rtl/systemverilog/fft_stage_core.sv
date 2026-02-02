module fft_stage_core #(
    parameter int N = 16  // number of complex points in this stage group (must be even)
) (
    input  logic               clk,
    input  logic               rst_n,
    input  logic               start,
    input  logic [3:0]         stage,

    // Complex samples: [31:16]=real, [15:0]=imag
    input  logic [31:0]        x_out [0:N-1],
    output logic [31:0]        x_in  [0:N-1],

    // One write-enable per sample output
    output logic [N-1:0]       x_we,

    // Twiddles per butterfly (N/2 twiddles for N samples)
    input  logic signed [31:0] tw_out [0:(N/2)-1]
);


    localparam int N_BFLY = N/2;

    logic v [0:N_BFLY-1];

    genvar i;
    generate
        for (i = 0; i < N_BFLY; i++) begin : GEN_BFLY

            fft_atomic_p1 bfly (
                .clk       (clk),
                .rst_n     (rst_n),
                .in_valid  (start),

                // Pair inputs (2*i) and (2*i+1)
                .a_real    (x_out[2*i][31:16]),
                .a_imag    (x_out[2*i][15:0]),
                .b_real    (x_out[2*i+1][31:16]),
                .b_imag    (x_out[2*i+1][15:0]),

                // Twiddle for this butterfly
                .W_real    (tw_out[i][31:16]),
                .W_imag    (tw_out[i][15:0]),

                // Pair outputs (2*i) and (2*i+1)
                .a_real_out(x_in[2*i][31:16]),
                .a_imag_out(x_in[2*i][15:0]),
                .b_real_out(x_in[2*i+1][31:16]),
                .b_imag_out(x_in[2*i+1][15:0]),

                .out_valid (v[i])
            );

            // Two write-enables per butterfly output
            assign x_we[2*i]   = v[i];
            assign x_we[2*i+1] = v[i];

        end
    endgenerate

endmodule