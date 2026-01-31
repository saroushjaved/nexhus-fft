// =====================================================================
// Wrapper: converts bus twiddle interface into your named-port twiddle bank
// Assumes you already have module twiddle_bank_64 with:
//   inputs  waddr_0..waddr_31  (5-bit each)
//   outputs wout_0..wout_31    (32-bit each)
// =====================================================================
module twiddle_bank_64_wrapper (
    input  wire [32*5-1:0]   tw_addr_bus,
    output wire [32*32-1:0]  tw_out_bus
);

    wire [4:0] a0  = tw_addr_bus[0*5  +: 5];
    wire [4:0] a1  = tw_addr_bus[1*5  +: 5];
    wire [4:0] a2  = tw_addr_bus[2*5  +: 5];
    wire [4:0] a3  = tw_addr_bus[3*5  +: 5];
    wire [4:0] a4  = tw_addr_bus[4*5  +: 5];
    wire [4:0] a5  = tw_addr_bus[5*5  +: 5];
    wire [4:0] a6  = tw_addr_bus[6*5  +: 5];
    wire [4:0] a7  = tw_addr_bus[7*5  +: 5];
    wire [4:0] a8  = tw_addr_bus[8*5  +: 5];
    wire [4:0] a9  = tw_addr_bus[9*5  +: 5];
    wire [4:0] a10 = tw_addr_bus[10*5 +: 5];
    wire [4:0] a11 = tw_addr_bus[11*5 +: 5];
    wire [4:0] a12 = tw_addr_bus[12*5 +: 5];
    wire [4:0] a13 = tw_addr_bus[13*5 +: 5];
    wire [4:0] a14 = tw_addr_bus[14*5 +: 5];
    wire [4:0] a15 = tw_addr_bus[15*5 +: 5];
    wire [4:0] a16 = tw_addr_bus[16*5 +: 5];
    wire [4:0] a17 = tw_addr_bus[17*5 +: 5];
    wire [4:0] a18 = tw_addr_bus[18*5 +: 5];
    wire [4:0] a19 = tw_addr_bus[19*5 +: 5];
    wire [4:0] a20 = tw_addr_bus[20*5 +: 5];
    wire [4:0] a21 = tw_addr_bus[21*5 +: 5];
    wire [4:0] a22 = tw_addr_bus[22*5 +: 5];
    wire [4:0] a23 = tw_addr_bus[23*5 +: 5];
    wire [4:0] a24 = tw_addr_bus[24*5 +: 5];
    wire [4:0] a25 = tw_addr_bus[25*5 +: 5];
    wire [4:0] a26 = tw_addr_bus[26*5 +: 5];
    wire [4:0] a27 = tw_addr_bus[27*5 +: 5];
    wire [4:0] a28 = tw_addr_bus[28*5 +: 5];
    wire [4:0] a29 = tw_addr_bus[29*5 +: 5];
    wire [4:0] a30 = tw_addr_bus[30*5 +: 5];
    wire [4:0] a31 = tw_addr_bus[31*5 +: 5];

    wire signed [31:0] w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15;
    wire signed [31:0] w16,w17,w18,w19,w20,w21,w22,w23,w24,w25,w26,w27,w28,w29,w30,w31;

    twiddle_bank_64 u_tw (
        .waddr_0(a0),  .waddr_1(a1),  .waddr_2(a2),  .waddr_3(a3),
        .waddr_4(a4),  .waddr_5(a5),  .waddr_6(a6),  .waddr_7(a7),
        .waddr_8(a8),  .waddr_9(a9),  .waddr_10(a10),.waddr_11(a11),
        .waddr_12(a12),.waddr_13(a13),.waddr_14(a14),.waddr_15(a15),
        .waddr_16(a16),.waddr_17(a17),.waddr_18(a18),.waddr_19(a19),
        .waddr_20(a20),.waddr_21(a21),.waddr_22(a22),.waddr_23(a23),
        .waddr_24(a24),.waddr_25(a25),.waddr_26(a26),.waddr_27(a27),
        .waddr_28(a28),.waddr_29(a29),.waddr_30(a30),.waddr_31(a31),

        .wout_0(w0),   .wout_1(w1),   .wout_2(w2),   .wout_3(w3),
        .wout_4(w4),   .wout_5(w5),   .wout_6(w6),   .wout_7(w7),
        .wout_8(w8),   .wout_9(w9),   .wout_10(w10), .wout_11(w11),
        .wout_12(w12), .wout_13(w13), .wout_14(w14), .wout_15(w15),
        .wout_16(w16), .wout_17(w17), .wout_18(w18), .wout_19(w19),
        .wout_20(w20), .wout_21(w21), .wout_22(w22), .wout_23(w23),
        .wout_24(w24), .wout_25(w25), .wout_26(w26), .wout_27(w27),
        .wout_28(w28), .wout_29(w29), .wout_30(w30), .wout_31(w31)
    );

    assign tw_out_bus[0*32  +: 32] = w0;
    assign tw_out_bus[1*32  +: 32] = w1;
    assign tw_out_bus[2*32  +: 32] = w2;
    assign tw_out_bus[3*32  +: 32] = w3;
    assign tw_out_bus[4*32  +: 32] = w4;
    assign tw_out_bus[5*32  +: 32] = w5;
    assign tw_out_bus[6*32  +: 32] = w6;
    assign tw_out_bus[7*32  +: 32] = w7;
    assign tw_out_bus[8*32  +: 32] = w8;
    assign tw_out_bus[9*32  +: 32] = w9;
    assign tw_out_bus[10*32 +: 32] = w10;
    assign tw_out_bus[11*32 +: 32] = w11;
    assign tw_out_bus[12*32 +: 32] = w12;
    assign tw_out_bus[13*32 +: 32] = w13;
    assign tw_out_bus[14*32 +: 32] = w14;
    assign tw_out_bus[15*32 +: 32] = w15;
    assign tw_out_bus[16*32 +: 32] = w16;
    assign tw_out_bus[17*32 +: 32] = w17;
    assign tw_out_bus[18*32 +: 32] = w18;
    assign tw_out_bus[19*32 +: 32] = w19;
    assign tw_out_bus[20*32 +: 32] = w20;
    assign tw_out_bus[21*32 +: 32] = w21;
    assign tw_out_bus[22*32 +: 32] = w22;
    assign tw_out_bus[23*32 +: 32] = w23;
    assign tw_out_bus[24*32 +: 32] = w24;
    assign tw_out_bus[25*32 +: 32] = w25;
    assign tw_out_bus[26*32 +: 32] = w26;
    assign tw_out_bus[27*32 +: 32] = w27;
    assign tw_out_bus[28*32 +: 32] = w28;
    assign tw_out_bus[29*32 +: 32] = w29;
    assign tw_out_bus[30*32 +: 32] = w30;
    assign tw_out_bus[31*32 +: 32] = w31;

endmodule