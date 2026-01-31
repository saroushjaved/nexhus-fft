module fft_stage_core(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               start,
    input  wire [3:0]         stage,   // 0..5 for N=64 (DIT)

    input  wire [31:0] x_out_0,  input wire [31:0] x_out_1,
    input  wire [31:0] x_out_2,  input wire [31:0] x_out_3,
    input  wire [31:0] x_out_4,  input wire [31:0] x_out_5,
    input  wire [31:0] x_out_6,  input wire [31:0] x_out_7,
    
    output wire [31:0] x_in_0,  output wire [31:0] x_in_1,
    output wire [31:0] x_in_2,  output wire [31:0] x_in_3,
    output wire [31:0] x_in_4,  output wire [31:0] x_in_5,
    output wire [31:0] x_in_6,  output wire [31:0] x_in_7,
   
    output wire [7:0] x_we,

    input  wire signed [31:0] tw_out_0,  input wire signed [31:0] tw_out_1,
    input  wire signed [31:0] tw_out_2,  input wire signed [31:0] tw_out_3
);

    // one valid per butterfly
    wire v0, v1, v2, v3;
// ----------------------------
// Butterfly 0: (0,1) with tw0
// ----------------------------
fft_atomic_p1 bfly0 (
    .clk       (clk),
    .rst_n     (rst_n),
    .in_valid  (start),

    .a_real    (x_out_0[31:16]),
    .a_imag    (x_out_0[15:0]),
    .b_real    (x_out_1[31:16]),
    .b_imag    (x_out_1[15:0]),

    .W_real    (tw_out_0[31:16]),
    .W_imag    (tw_out_0[15:0]),

    .a_real_out(x_in_0[31:16]),
    .a_imag_out(x_in_0[15:0]),
    .b_real_out(x_in_1[31:16]),
    .b_imag_out(x_in_1[15:0]),

    .out_valid (v0)
);

// ----------------------------
// Butterfly 1: (2,3) with tw1
// ----------------------------
fft_atomic_p1 bfly1 (
    .clk       (clk),
    .rst_n     (rst_n),
    .in_valid  (start),

    .a_real    (x_out_2[31:16]),
    .a_imag    (x_out_2[15:0]),
    .b_real    (x_out_3[31:16]),
    .b_imag    (x_out_3[15:0]),

    .W_real    (tw_out_1[31:16]),
    .W_imag    (tw_out_1[15:0]),

    .a_real_out(x_in_2[31:16]),
    .a_imag_out(x_in_2[15:0]),
    .b_real_out(x_in_3[31:16]),
    .b_imag_out(x_in_3[15:0]),

    .out_valid (v1)
);

// ----------------------------
// Butterfly 2: (4,5) with tw2
// ----------------------------
fft_atomic_p1 bfly2 (
    .clk       (clk),
    .rst_n     (rst_n),
    .in_valid  (start),

    .a_real    (x_out_4[31:16]),
    .a_imag    (x_out_4[15:0]),
    .b_real    (x_out_5[31:16]),
    .b_imag    (x_out_5[15:0]),

    .W_real    (tw_out_2[31:16]),
    .W_imag    (tw_out_2[15:0]),

    .a_real_out(x_in_4[31:16]),
    .a_imag_out(x_in_4[15:0]),
    .b_real_out(x_in_5[31:16]),
    .b_imag_out(x_in_5[15:0]),

    .out_valid (v2)
);

// ----------------------------
// Butterfly 3: (6,7) with tw3
// ----------------------------
fft_atomic_p1 bfly3 (
    .clk       (clk),
    .rst_n     (rst_n),
    .in_valid  (start),

    .a_real    (x_out_6[31:16]),
    .a_imag    (x_out_6[15:0]),
    .b_real    (x_out_7[31:16]),
    .b_imag    (x_out_7[15:0]),

    .W_real    (tw_out_3[31:16]),
    .W_imag    (tw_out_3[15:0]),

    .a_real_out(x_in_6[31:16]),
    .a_imag_out(x_in_6[15:0]),
    .b_real_out(x_in_7[31:16]),
    .b_imag_out(x_in_7[15:0]),

    .out_valid (v3)
);

    assign x_we = { v3, v3, v2, v2, v1, v1, v0, v0 };

endmodule