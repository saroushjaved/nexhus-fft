module fft_ram_nx32 #(
    parameter int N = 8   // number of 32-bit words
) (
    input  logic        clk,
    input  logic        rst_n,

    // One write-enable per word
    input  logic [N-1:0]  x_we,

    // Write data array
    input  logic [31:0]   x_in  [0:N-1],

    // Read data array
    output logic [31:0]   x_out [0:N-1]
);

    // ----------------------------
    // Internal Memory: N x 32-bit
    // ----------------------------
    logic [31:0] mem [0:N-1];

    // ----------------------------
    // Synchronous Write + Reset
    // ----------------------------
    integer k;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (k = 0; k < N; k++) begin
                mem[k] <= 32'd0;
            end
        end else begin
            for (k = 0; k < N; k++) begin
                if (x_we[k]) mem[k] <= x_in[k];
            end
        end
    end

    // ----------------------------
    // Combinational Read Outputs
    // ----------------------------
    genvar i;
    generate
        for (i = 0; i < N; i++) begin : GEN_READ
            assign x_out[i] = mem[i];
        end
    endgenerate

endmodule