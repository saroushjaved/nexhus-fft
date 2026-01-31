// Auto-generated Twiddle Bank for N=64 (Q1.15 signed)
// W[k] = cos(2*pi*k/64) - j*sin(2*pi*k/64), k=0..31
// Each wout_* is 32-bit: {real[15:0], imag[15:0]}

module twiddle_bank_64 (
    input  wire [4:0] waddr_0,
    input  wire [4:0] waddr_1,
    input  wire [4:0] waddr_2,
    input  wire [4:0] waddr_3,
    input  wire [4:0] waddr_4,
    input  wire [4:0] waddr_5,
    input  wire [4:0] waddr_6,
    input  wire [4:0] waddr_7,
    input  wire [4:0] waddr_8,
    input  wire [4:0] waddr_9,
    input  wire [4:0] waddr_10,
    input  wire [4:0] waddr_11,
    input  wire [4:0] waddr_12,
    input  wire [4:0] waddr_13,
    input  wire [4:0] waddr_14,
    input  wire [4:0] waddr_15,
    input  wire [4:0] waddr_16,
    input  wire [4:0] waddr_17,
    input  wire [4:0] waddr_18,
    input  wire [4:0] waddr_19,
    input  wire [4:0] waddr_20,
    input  wire [4:0] waddr_21,
    input  wire [4:0] waddr_22,
    input  wire [4:0] waddr_23,
    input  wire [4:0] waddr_24,
    input  wire [4:0] waddr_25,
    input  wire [4:0] waddr_26,
    input  wire [4:0] waddr_27,
    input  wire [4:0] waddr_28,
    input  wire [4:0] waddr_29,
    input  wire [4:0] waddr_30,
    input  wire [4:0] waddr_31,
    output wire signed [31:0] wout_0,
    output wire signed [31:0] wout_1,
    output wire signed [31:0] wout_2,
    output wire signed [31:0] wout_3,
    output wire signed [31:0] wout_4,
    output wire signed [31:0] wout_5,
    output wire signed [31:0] wout_6,
    output wire signed [31:0] wout_7,
    output wire signed [31:0] wout_8,
    output wire signed [31:0] wout_9,
    output wire signed [31:0] wout_10,
    output wire signed [31:0] wout_11,
    output wire signed [31:0] wout_12,
    output wire signed [31:0] wout_13,
    output wire signed [31:0] wout_14,
    output wire signed [31:0] wout_15,
    output wire signed [31:0] wout_16,
    output wire signed [31:0] wout_17,
    output wire signed [31:0] wout_18,
    output wire signed [31:0] wout_19,
    output wire signed [31:0] wout_20,
    output wire signed [31:0] wout_21,
    output wire signed [31:0] wout_22,
    output wire signed [31:0] wout_23,
    output wire signed [31:0] wout_24,
    output wire signed [31:0] wout_25,
    output wire signed [31:0] wout_26,
    output wire signed [31:0] wout_27,
    output wire signed [31:0] wout_28,
    output wire signed [31:0] wout_29,
    output wire signed [31:0] wout_30,
    output wire signed [31:0] wout_31
);

    function automatic [31:0] tw_lut;
        input [4:0] a;
        begin
            case (a)
                5'd00: tw_lut = 32'h7FFF0000;
                5'd01: tw_lut = 32'h7F62F374;
                5'd02: tw_lut = 32'h7D8AE707;
                5'd03: tw_lut = 32'h7A7DDAD8;
                5'd04: tw_lut = 32'h7642CF04;
                5'd05: tw_lut = 32'h70E3C3A9;
                5'd06: tw_lut = 32'h6A6EB8E3;
                5'd07: tw_lut = 32'h62F2AECC;
                5'd08: tw_lut = 32'h5A82A57E;
                5'd09: tw_lut = 32'h51349D0E;
                5'd10: tw_lut = 32'h471D9592;
                5'd11: tw_lut = 32'h3C578F1D;
                5'd12: tw_lut = 32'h30FC89BE;
                5'd13: tw_lut = 32'h25288583;
                5'd14: tw_lut = 32'h18F98276;
                5'd15: tw_lut = 32'h0C8C809E;
                5'd16: tw_lut = 32'h00008000;
                5'd17: tw_lut = 32'hF374809E;
                5'd18: tw_lut = 32'hE7078276;
                5'd19: tw_lut = 32'hDAD88583;
                5'd20: tw_lut = 32'hCF0489BE;
                5'd21: tw_lut = 32'hC3A98F1D;
                5'd22: tw_lut = 32'hB8E39592;
                5'd23: tw_lut = 32'hAECC9D0E;
                5'd24: tw_lut = 32'hA57EA57E;
                5'd25: tw_lut = 32'h9D0EAECC;
                5'd26: tw_lut = 32'h9592B8E3;
                5'd27: tw_lut = 32'h8F1DC3A9;
                5'd28: tw_lut = 32'h89BECF04;
                5'd29: tw_lut = 32'h8583DAD8;
                5'd30: tw_lut = 32'h8276E707;
                5'd31: tw_lut = 32'h809EF374;
                default: tw_lut = 32'h0000_0000;
            endcase
        end
    endfunction

    assign wout_0 = tw_lut(waddr_0);
    assign wout_1 = tw_lut(waddr_1);
    assign wout_2 = tw_lut(waddr_2);
    assign wout_3 = tw_lut(waddr_3);
    assign wout_4 = tw_lut(waddr_4);
    assign wout_5 = tw_lut(waddr_5);
    assign wout_6 = tw_lut(waddr_6);
    assign wout_7 = tw_lut(waddr_7);
    assign wout_8 = tw_lut(waddr_8);
    assign wout_9 = tw_lut(waddr_9);
    assign wout_10 = tw_lut(waddr_10);
    assign wout_11 = tw_lut(waddr_11);
    assign wout_12 = tw_lut(waddr_12);
    assign wout_13 = tw_lut(waddr_13);
    assign wout_14 = tw_lut(waddr_14);
    assign wout_15 = tw_lut(waddr_15);
    assign wout_16 = tw_lut(waddr_16);
    assign wout_17 = tw_lut(waddr_17);
    assign wout_18 = tw_lut(waddr_18);
    assign wout_19 = tw_lut(waddr_19);
    assign wout_20 = tw_lut(waddr_20);
    assign wout_21 = tw_lut(waddr_21);
    assign wout_22 = tw_lut(waddr_22);
    assign wout_23 = tw_lut(waddr_23);
    assign wout_24 = tw_lut(waddr_24);
    assign wout_25 = tw_lut(waddr_25);
    assign wout_26 = tw_lut(waddr_26);
    assign wout_27 = tw_lut(waddr_27);
    assign wout_28 = tw_lut(waddr_28);
    assign wout_29 = tw_lut(waddr_29);
    assign wout_30 = tw_lut(waddr_30);
    assign wout_31 = tw_lut(waddr_31);

endmodule
