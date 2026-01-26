// ------------------------------------------------------------
// sat16: saturate signed value down to signed 16-bit
// add_sat_s1: sat16( (a+b) >>> 1 )
// sub_sat_s1: sat16( (a-b) >>> 1 )
// ------------------------------------------------------------
module add_sub_sat_s1_q15 (
    input  signed [15:0] a_real,
    input  signed [15:0] a_imag,
    input  signed [15:0] t_real,
    input  signed [15:0] t_imag,
    output signed [15:0] y0_real,
    output signed [15:0] y0_imag,
    output signed [15:0] y1_real,
    output signed [15:0] y1_imag
);

    // widen for sum/diff: 16-bit + 16-bit -> 17-bit
    wire signed [16:0] sum_real  = {a_real[15], a_real} + {t_real[15], t_real};
    wire signed [16:0] sum_imag  = {a_imag[15], a_imag} + {t_imag[15], t_imag};
    wire signed [16:0] diff_real = {a_real[15], a_real} - {t_real[15], t_real};
    wire signed [16:0] diff_imag = {a_imag[15], a_imag} - {t_imag[15], t_imag};

    // arithmetic shift right by 1 (divide by 2, sign-preserving)
    wire signed [16:0] sum_real_s1  = sum_real  >>> 1;
    wire signed [16:0] sum_imag_s1  = sum_imag  >>> 1;
    wire signed [16:0] diff_real_s1 = diff_real >>> 1;
    wire signed [16:0] diff_imag_s1 = diff_imag >>> 1;

    // sat16 for 17-bit input: only overflow if top two bits differ
    // For a properly sign-extended 16-bit number in 17-bit, bits[16] and bits[15] are equal.
    wire sum_real_ovf_pos  = (sum_real_s1[16] == 1'b0) && (sum_real_s1[15] == 1'b1);
    wire sum_real_ovf_neg  = (sum_real_s1[16] == 1'b1) && (sum_real_s1[15] == 1'b0);

    wire sum_imag_ovf_pos  = (sum_imag_s1[16] == 1'b0) && (sum_imag_s1[15] == 1'b1);
    wire sum_imag_ovf_neg  = (sum_imag_s1[16] == 1'b1) && (sum_imag_s1[15] == 1'b0);

    wire diff_real_ovf_pos = (diff_real_s1[16] == 1'b0) && (diff_real_s1[15] == 1'b1);
    wire diff_real_ovf_neg = (diff_real_s1[16] == 1'b1) && (diff_real_s1[15] == 1'b0);

    wire diff_imag_ovf_pos = (diff_imag_s1[16] == 1'b0) && (diff_imag_s1[15] == 1'b1);
    wire diff_imag_ovf_neg = (diff_imag_s1[16] == 1'b1) && (diff_imag_s1[15] == 1'b0);

    // Saturated outputs (assign-only, no always blocks)
    assign y0_real = sum_real_ovf_pos  ? 16'sd32767 :
                     sum_real_ovf_neg  ? -16'sd32768 :
                     sum_real_s1[15:0];

    assign y0_imag = sum_imag_ovf_pos  ? 16'sd32767 :
                     sum_imag_ovf_neg  ? -16'sd32768 :
                     sum_imag_s1[15:0];

    assign y1_real = diff_real_ovf_pos ? 16'sd32767 :
                     diff_real_ovf_neg ? -16'sd32768 :
                     diff_real_s1[15:0];

    assign y1_imag = diff_imag_ovf_pos ? 16'sd32767 :
                     diff_imag_ovf_neg ? -16'sd32768 :
                     diff_imag_s1[15:0];

endmodule