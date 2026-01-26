module fft_atomic_p1 (
    input  wire               clk,
    input  wire               rst_n,      // active-low reset
    input  wire               in_valid,

    // INPUTS
    input  wire signed [15:0] a_real,
    input  wire signed [15:0] a_imag,
    input  wire signed [15:0] b_real,
    input  wire signed [15:0] b_imag,
    input  wire signed [15:0] W_real,
    input  wire signed [15:0] W_imag,

    // OUTPUTS
    output wire signed [15:0] a_real_out,
    output wire signed [15:0] a_imag_out,
    output wire signed [15:0] b_real_out,
    output wire signed [15:0] b_imag_out,
    output wire               out_valid
);

    // -------------------------
    // Stage 0: combinational cmul
    // -------------------------
    wire signed [15:0] t_real_c;
    wire signed [15:0] t_imag_c;

    cmul_q15 u_cmul_q15 (
        .a_real (b_real),
        .a_imag (b_imag),
        .b_real (W_real),
        .b_imag (W_imag),
        .y_real (t_real_c),
        .y_imag (t_imag_c)
    );

    // -------------------------
    // Pipeline register (1-cycle)
    // Register t and a for alignment
    // -------------------------
    reg signed [15:0] t_real_r, t_imag_r;
    reg signed [15:0] a_real_r, a_imag_r;
    reg              v_r;

    always @(posedge clk) begin
        if (!rst_n) begin
            t_real_r <= 16'sd0;
            t_imag_r <= 16'sd0;
            a_real_r <= 16'sd0;
            a_imag_r <= 16'sd0;
            v_r      <= 1'b0;
        end else begin
            v_r <= in_valid;

            // You can optionally gate these with in_valid to reduce toggling
            t_real_r <= t_real_c;
            t_imag_r <= t_imag_c;
            a_real_r <= a_real;
            a_imag_r <= a_imag;
        end
    end

    assign out_valid = v_r;

    // -------------------------
    // Stage 1: add/sub with sat and >>>1 (combinational)
    // -------------------------
    add_sub_sat_s1_q15 u_addsub (
        .a_real (a_real_r),
        .a_imag (a_imag_r),
        .t_real (t_real_r),
        .t_imag (t_imag_r),
        .y0_real(a_real_out),
        .y0_imag(a_imag_out),
        .y1_real(b_real_out),
        .y1_imag(b_imag_out)
    );

endmodule