// Q1.15 complex multiply with rounding and saturation to 16-bit signed
// Matches:
// real = (arbr - aibi + (1<<14)) >> 15
// imag = (arbi + aibr + (1<<14)) >> 15
module cmulq15 (
    input  signed [15:0] a_real,
    input  signed [15:0] a_imag,
    input  signed [15:0] b_real,
    input  signed [15:0] b_imag,
    output signed [15:0] y_real,
    output signed [15:0] y_imag
);

    // 16x16 -> 32-bit signed products
    wire signed [31:0] arbr = a_real * b_real;
    wire signed [31:0] aibi = a_imag * b_imag;
    wire signed [31:0] arbi = a_real * b_imag;
    wire signed [31:0] aibr = a_imag * b_real;

    // Intermediate sums (need extra bit for safety)
    wire signed [32:0] real_acc = {arbr[31], arbr} - {aibi[31], aibi} + 33'sd16384; // + (1<<14)
    wire signed [32:0] imag_acc = {arbi[31], arbi} + {aibr[31], aibr} + 33'sd16384; // + (1<<14)

    // Arithmetic right shift by 15 (keeps sign)
    wire signed [32:0] real_q15_wide = real_acc >>> 15;
    wire signed [32:0] imag_q15_wide = imag_acc >>> 15;

    // Saturation to signed 16-bit
    function signed [15:0] sat16;
        input signed [32:0] x;
        begin
            if (x > 33'sd32767)
                sat16 = 16'sd32767;
            else if (x < -33'sd32768)
                sat16 = -16'sd32768;
            else
                sat16 = x[15:0];
        end
    endfunction

    assign y_real = sat16(real_q15_wide);
    assign y_imag = sat16(imag_q15_wide);

endmodule