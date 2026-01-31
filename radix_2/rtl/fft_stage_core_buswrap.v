module fft_stage_core_buswrap #(
    parameter integer BW = 32,
    parameter integer N  = 64
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               start,
    input  wire [3:0]         stage,

    // bus x-bank ports (what your top uses)
    input  wire [N*32-1:0]    x_out_bus,
    output wire [N*32-1:0]    x_in_bus,
    output wire [N-1:0]       x_we,

    // bus twiddle ports (what your top uses)
    output wire [BW*5-1:0]    tw_addr_bus,
    input  wire signed [BW*32-1:0] tw_out_bus
);

    // ----------------------------
    // Unpack X bus -> named wires
    // ----------------------------
    wire [31:0] x_out_0  = x_out_bus[0*32  +: 32];
    wire [31:0] x_out_1  = x_out_bus[1*32  +: 32];
    wire [31:0] x_out_2  = x_out_bus[2*32  +: 32];
    wire [31:0] x_out_3  = x_out_bus[3*32  +: 32];
    wire [31:0] x_out_4  = x_out_bus[4*32  +: 32];
    wire [31:0] x_out_5  = x_out_bus[5*32  +: 32];
    wire [31:0] x_out_6  = x_out_bus[6*32  +: 32];
    wire [31:0] x_out_7  = x_out_bus[7*32  +: 32];
    wire [31:0] x_out_8  = x_out_bus[8*32  +: 32];
    wire [31:0] x_out_9  = x_out_bus[9*32  +: 32];
    wire [31:0] x_out_10 = x_out_bus[10*32 +: 32];
    wire [31:0] x_out_11 = x_out_bus[11*32 +: 32];
    wire [31:0] x_out_12 = x_out_bus[12*32 +: 32];
    wire [31:0] x_out_13 = x_out_bus[13*32 +: 32];
    wire [31:0] x_out_14 = x_out_bus[14*32 +: 32];
    wire [31:0] x_out_15 = x_out_bus[15*32 +: 32];
    wire [31:0] x_out_16 = x_out_bus[16*32 +: 32];
    wire [31:0] x_out_17 = x_out_bus[17*32 +: 32];
    wire [31:0] x_out_18 = x_out_bus[18*32 +: 32];
    wire [31:0] x_out_19 = x_out_bus[19*32 +: 32];
    wire [31:0] x_out_20 = x_out_bus[20*32 +: 32];
    wire [31:0] x_out_21 = x_out_bus[21*32 +: 32];
    wire [31:0] x_out_22 = x_out_bus[22*32 +: 32];
    wire [31:0] x_out_23 = x_out_bus[23*32 +: 32];
    wire [31:0] x_out_24 = x_out_bus[24*32 +: 32];
    wire [31:0] x_out_25 = x_out_bus[25*32 +: 32];
    wire [31:0] x_out_26 = x_out_bus[26*32 +: 32];
    wire [31:0] x_out_27 = x_out_bus[27*32 +: 32];
    wire [31:0] x_out_28 = x_out_bus[28*32 +: 32];
    wire [31:0] x_out_29 = x_out_bus[29*32 +: 32];
    wire [31:0] x_out_30 = x_out_bus[30*32 +: 32];
    wire [31:0] x_out_31 = x_out_bus[31*32 +: 32];
    wire [31:0] x_out_32 = x_out_bus[32*32 +: 32];
    wire [31:0] x_out_33 = x_out_bus[33*32 +: 32];
    wire [31:0] x_out_34 = x_out_bus[34*32 +: 32];
    wire [31:0] x_out_35 = x_out_bus[35*32 +: 32];
    wire [31:0] x_out_36 = x_out_bus[36*32 +: 32];
    wire [31:0] x_out_37 = x_out_bus[37*32 +: 32];
    wire [31:0] x_out_38 = x_out_bus[38*32 +: 32];
    wire [31:0] x_out_39 = x_out_bus[39*32 +: 32];
    wire [31:0] x_out_40 = x_out_bus[40*32 +: 32];
    wire [31:0] x_out_41 = x_out_bus[41*32 +: 32];
    wire [31:0] x_out_42 = x_out_bus[42*32 +: 32];
    wire [31:0] x_out_43 = x_out_bus[43*32 +: 32];
    wire [31:0] x_out_44 = x_out_bus[44*32 +: 32];
    wire [31:0] x_out_45 = x_out_bus[45*32 +: 32];
    wire [31:0] x_out_46 = x_out_bus[46*32 +: 32];
    wire [31:0] x_out_47 = x_out_bus[47*32 +: 32];
    wire [31:0] x_out_48 = x_out_bus[48*32 +: 32];
    wire [31:0] x_out_49 = x_out_bus[49*32 +: 32];
    wire [31:0] x_out_50 = x_out_bus[50*32 +: 32];
    wire [31:0] x_out_51 = x_out_bus[51*32 +: 32];
    wire [31:0] x_out_52 = x_out_bus[52*32 +: 32];
    wire [31:0] x_out_53 = x_out_bus[53*32 +: 32];
    wire [31:0] x_out_54 = x_out_bus[54*32 +: 32];
    wire [31:0] x_out_55 = x_out_bus[55*32 +: 32];
    wire [31:0] x_out_56 = x_out_bus[56*32 +: 32];
    wire [31:0] x_out_57 = x_out_bus[57*32 +: 32];
    wire [31:0] x_out_58 = x_out_bus[58*32 +: 32];
    wire [31:0] x_out_59 = x_out_bus[59*32 +: 32];
    wire [31:0] x_out_60 = x_out_bus[60*32 +: 32];
    wire [31:0] x_out_61 = x_out_bus[61*32 +: 32];
    wire [31:0] x_out_62 = x_out_bus[62*32 +: 32];
    wire [31:0] x_out_63 = x_out_bus[63*32 +: 32];

    // outputs from core (named)
    wire [31:0] x_in_0,  x_in_1,  x_in_2,  x_in_3,  x_in_4,  x_in_5,  x_in_6,  x_in_7;
    wire [31:0] x_in_8,  x_in_9,  x_in_10, x_in_11, x_in_12, x_in_13, x_in_14, x_in_15;
    wire [31:0] x_in_16, x_in_17, x_in_18, x_in_19, x_in_20, x_in_21, x_in_22, x_in_23;
    wire [31:0] x_in_24, x_in_25, x_in_26, x_in_27, x_in_28, x_in_29, x_in_30, x_in_31;
    wire [31:0] x_in_32, x_in_33, x_in_34, x_in_35, x_in_36, x_in_37, x_in_38, x_in_39;
    wire [31:0] x_in_40, x_in_41, x_in_42, x_in_43, x_in_44, x_in_45, x_in_46, x_in_47;
    wire [31:0] x_in_48, x_in_49, x_in_50, x_in_51, x_in_52, x_in_53, x_in_54, x_in_55;
    wire [31:0] x_in_56, x_in_57, x_in_58, x_in_59, x_in_60, x_in_61, x_in_62, x_in_63;

    // pack named x_in -> x_in_bus
    assign x_in_bus[0*32  +: 32] = x_in_0;
    assign x_in_bus[1*32  +: 32] = x_in_1;
    assign x_in_bus[2*32  +: 32] = x_in_2;
    assign x_in_bus[3*32  +: 32] = x_in_3;
    assign x_in_bus[4*32  +: 32] = x_in_4;
    assign x_in_bus[5*32  +: 32] = x_in_5;
    assign x_in_bus[6*32  +: 32] = x_in_6;
    assign x_in_bus[7*32  +: 32] = x_in_7;
    assign x_in_bus[8*32  +: 32] = x_in_8;
    assign x_in_bus[9*32  +: 32] = x_in_9;
    assign x_in_bus[10*32 +: 32] = x_in_10;
    assign x_in_bus[11*32 +: 32] = x_in_11;
    assign x_in_bus[12*32 +: 32] = x_in_12;
    assign x_in_bus[13*32 +: 32] = x_in_13;
    assign x_in_bus[14*32 +: 32] = x_in_14;
    assign x_in_bus[15*32 +: 32] = x_in_15;
    assign x_in_bus[16*32 +: 32] = x_in_16;
    assign x_in_bus[17*32 +: 32] = x_in_17;
    assign x_in_bus[18*32 +: 32] = x_in_18;
    assign x_in_bus[19*32 +: 32] = x_in_19;
    assign x_in_bus[20*32 +: 32] = x_in_20;
    assign x_in_bus[21*32 +: 32] = x_in_21;
    assign x_in_bus[22*32 +: 32] = x_in_22;
    assign x_in_bus[23*32 +: 32] = x_in_23;
    assign x_in_bus[24*32 +: 32] = x_in_24;
    assign x_in_bus[25*32 +: 32] = x_in_25;
    assign x_in_bus[26*32 +: 32] = x_in_26;
    assign x_in_bus[27*32 +: 32] = x_in_27;
    assign x_in_bus[28*32 +: 32] = x_in_28;
    assign x_in_bus[29*32 +: 32] = x_in_29;
    assign x_in_bus[30*32 +: 32] = x_in_30;
    assign x_in_bus[31*32 +: 32] = x_in_31;
    assign x_in_bus[32*32 +: 32] = x_in_32;
    assign x_in_bus[33*32 +: 32] = x_in_33;
    assign x_in_bus[34*32 +: 32] = x_in_34;
    assign x_in_bus[35*32 +: 32] = x_in_35;
    assign x_in_bus[36*32 +: 32] = x_in_36;
    assign x_in_bus[37*32 +: 32] = x_in_37;
    assign x_in_bus[38*32 +: 32] = x_in_38;
    assign x_in_bus[39*32 +: 32] = x_in_39;
    assign x_in_bus[40*32 +: 32] = x_in_40;
    assign x_in_bus[41*32 +: 32] = x_in_41;
    assign x_in_bus[42*32 +: 32] = x_in_42;
    assign x_in_bus[43*32 +: 32] = x_in_43;
    assign x_in_bus[44*32 +: 32] = x_in_44;
    assign x_in_bus[45*32 +: 32] = x_in_45;
    assign x_in_bus[46*32 +: 32] = x_in_46;
    assign x_in_bus[47*32 +: 32] = x_in_47;
    assign x_in_bus[48*32 +: 32] = x_in_48;
    assign x_in_bus[49*32 +: 32] = x_in_49;
    assign x_in_bus[50*32 +: 32] = x_in_50;
    assign x_in_bus[51*32 +: 32] = x_in_51;
    assign x_in_bus[52*32 +: 32] = x_in_52;
    assign x_in_bus[53*32 +: 32] = x_in_53;
    assign x_in_bus[54*32 +: 32] = x_in_54;
    assign x_in_bus[55*32 +: 32] = x_in_55;
    assign x_in_bus[56*32 +: 32] = x_in_56;
    assign x_in_bus[57*32 +: 32] = x_in_57;
    assign x_in_bus[58*32 +: 32] = x_in_58;
    assign x_in_bus[59*32 +: 32] = x_in_59;
    assign x_in_bus[60*32 +: 32] = x_in_60;
    assign x_in_bus[61*32 +: 32] = x_in_61;
    assign x_in_bus[62*32 +: 32] = x_in_62;
    assign x_in_bus[63*32 +: 32] = x_in_63;

    // ----------------------------
    // Unpack twiddle buses -> named
    // ----------------------------
    wire [4:0] tw_addr_0,  tw_addr_1,  tw_addr_2,  tw_addr_3,  tw_addr_4,  tw_addr_5,  tw_addr_6,  tw_addr_7;
    wire [4:0] tw_addr_8,  tw_addr_9,  tw_addr_10, tw_addr_11, tw_addr_12, tw_addr_13, tw_addr_14, tw_addr_15;
    wire [4:0] tw_addr_16, tw_addr_17, tw_addr_18, tw_addr_19, tw_addr_20, tw_addr_21, tw_addr_22, tw_addr_23;
    wire [4:0] tw_addr_24, tw_addr_25, tw_addr_26, tw_addr_27, tw_addr_28, tw_addr_29, tw_addr_30, tw_addr_31;

    assign tw_addr_bus[0*5  +: 5] = tw_addr_0;
    assign tw_addr_bus[1*5  +: 5] = tw_addr_1;
    assign tw_addr_bus[2*5  +: 5] = tw_addr_2;
    assign tw_addr_bus[3*5  +: 5] = tw_addr_3;
    assign tw_addr_bus[4*5  +: 5] = tw_addr_4;
    assign tw_addr_bus[5*5  +: 5] = tw_addr_5;
    assign tw_addr_bus[6*5  +: 5] = tw_addr_6;
    assign tw_addr_bus[7*5  +: 5] = tw_addr_7;
    assign tw_addr_bus[8*5  +: 5] = tw_addr_8;
    assign tw_addr_bus[9*5  +: 5] = tw_addr_9;
    assign tw_addr_bus[10*5 +: 5] = tw_addr_10;
    assign tw_addr_bus[11*5 +: 5] = tw_addr_11;
    assign tw_addr_bus[12*5 +: 5] = tw_addr_12;
    assign tw_addr_bus[13*5 +: 5] = tw_addr_13;
    assign tw_addr_bus[14*5 +: 5] = tw_addr_14;
    assign tw_addr_bus[15*5 +: 5] = tw_addr_15;
    assign tw_addr_bus[16*5 +: 5] = tw_addr_16;
    assign tw_addr_bus[17*5 +: 5] = tw_addr_17;
    assign tw_addr_bus[18*5 +: 5] = tw_addr_18;
    assign tw_addr_bus[19*5 +: 5] = tw_addr_19;
    assign tw_addr_bus[20*5 +: 5] = tw_addr_20;
    assign tw_addr_bus[21*5 +: 5] = tw_addr_21;
    assign tw_addr_bus[22*5 +: 5] = tw_addr_22;
    assign tw_addr_bus[23*5 +: 5] = tw_addr_23;
    assign tw_addr_bus[24*5 +: 5] = tw_addr_24;
    assign tw_addr_bus[25*5 +: 5] = tw_addr_25;
    assign tw_addr_bus[26*5 +: 5] = tw_addr_26;
    assign tw_addr_bus[27*5 +: 5] = tw_addr_27;
    assign tw_addr_bus[28*5 +: 5] = tw_addr_28;
    assign tw_addr_bus[29*5 +: 5] = tw_addr_29;
    assign tw_addr_bus[30*5 +: 5] = tw_addr_30;
    assign tw_addr_bus[31*5 +: 5] = tw_addr_31;

    wire signed [31:0] tw_out_0  = tw_out_bus[0*32  +: 32];
    wire signed [31:0] tw_out_1  = tw_out_bus[1*32  +: 32];
    wire signed [31:0] tw_out_2  = tw_out_bus[2*32  +: 32];
    wire signed [31:0] tw_out_3  = tw_out_bus[3*32  +: 32];
    wire signed [31:0] tw_out_4  = tw_out_bus[4*32  +: 32];
    wire signed [31:0] tw_out_5  = tw_out_bus[5*32  +: 32];
    wire signed [31:0] tw_out_6  = tw_out_bus[6*32  +: 32];
    wire signed [31:0] tw_out_7  = tw_out_bus[7*32  +: 32];
    wire signed [31:0] tw_out_8  = tw_out_bus[8*32  +: 32];
    wire signed [31:0] tw_out_9  = tw_out_bus[9*32  +: 32];
    wire signed [31:0] tw_out_10 = tw_out_bus[10*32 +: 32];
    wire signed [31:0] tw_out_11 = tw_out_bus[11*32 +: 32];
    wire signed [31:0] tw_out_12 = tw_out_bus[12*32 +: 32];
    wire signed [31:0] tw_out_13 = tw_out_bus[13*32 +: 32];
    wire signed [31:0] tw_out_14 = tw_out_bus[14*32 +: 32];
    wire signed [31:0] tw_out_15 = tw_out_bus[15*32 +: 32];
    wire signed [31:0] tw_out_16 = tw_out_bus[16*32 +: 32];
    wire signed [31:0] tw_out_17 = tw_out_bus[17*32 +: 32];
    wire signed [31:0] tw_out_18 = tw_out_bus[18*32 +: 32];
    wire signed [31:0] tw_out_19 = tw_out_bus[19*32 +: 32];
    wire signed [31:0] tw_out_20 = tw_out_bus[20*32 +: 32];
    wire signed [31:0] tw_out_21 = tw_out_bus[21*32 +: 32];
    wire signed [31:0] tw_out_22 = tw_out_bus[22*32 +: 32];
    wire signed [31:0] tw_out_23 = tw_out_bus[23*32 +: 32];
    wire signed [31:0] tw_out_24 = tw_out_bus[24*32 +: 32];
    wire signed [31:0] tw_out_25 = tw_out_bus[25*32 +: 32];
    wire signed [31:0] tw_out_26 = tw_out_bus[26*32 +: 32];
    wire signed [31:0] tw_out_27 = tw_out_bus[27*32 +: 32];
    wire signed [31:0] tw_out_28 = tw_out_bus[28*32 +: 32];
    wire signed [31:0] tw_out_29 = tw_out_bus[29*32 +: 32];
    wire signed [31:0] tw_out_30 = tw_out_bus[30*32 +: 32];
    wire signed [31:0] tw_out_31 = tw_out_bus[31*32 +: 32];

    // ------------------------------------------------------------
    // Instantiate the *named-port* fft_stage_core you fixed
    // ------------------------------------------------------------
    fft_stage_core u_named (
        .clk(clk), .rst_n(rst_n), .start(start), .stage(stage),

        .x_out_0(x_out_0),  .x_out_1(x_out_1),   .x_out_2(x_out_2),   .x_out_3(x_out_3),
        .x_out_4(x_out_4),  .x_out_5(x_out_5),   .x_out_6(x_out_6),   .x_out_7(x_out_7),
        .x_out_8(x_out_8),  .x_out_9(x_out_9),   .x_out_10(x_out_10), .x_out_11(x_out_11),
        .x_out_12(x_out_12),.x_out_13(x_out_13), .x_out_14(x_out_14), .x_out_15(x_out_15),
        .x_out_16(x_out_16),.x_out_17(x_out_17), .x_out_18(x_out_18), .x_out_19(x_out_19),
        .x_out_20(x_out_20),.x_out_21(x_out_21), .x_out_22(x_out_22), .x_out_23(x_out_23),
        .x_out_24(x_out_24),.x_out_25(x_out_25), .x_out_26(x_out_26), .x_out_27(x_out_27),
        .x_out_28(x_out_28),.x_out_29(x_out_29), .x_out_30(x_out_30), .x_out_31(x_out_31),
        .x_out_32(x_out_32),.x_out_33(x_out_33), .x_out_34(x_out_34), .x_out_35(x_out_35),
        .x_out_36(x_out_36),.x_out_37(x_out_37), .x_out_38(x_out_38), .x_out_39(x_out_39),
        .x_out_40(x_out_40),.x_out_41(x_out_41), .x_out_42(x_out_42), .x_out_43(x_out_43),
        .x_out_44(x_out_44),.x_out_45(x_out_45), .x_out_46(x_out_46), .x_out_47(x_out_47),
        .x_out_48(x_out_48),.x_out_49(x_out_49), .x_out_50(x_out_50), .x_out_51(x_out_51),
        .x_out_52(x_out_52),.x_out_53(x_out_53), .x_out_54(x_out_54), .x_out_55(x_out_55),
        .x_out_56(x_out_56),.x_out_57(x_out_57), .x_out_58(x_out_58), .x_out_59(x_out_59),
        .x_out_60(x_out_60),.x_out_61(x_out_61), .x_out_62(x_out_62), .x_out_63(x_out_63),

        .x_in_0(x_in_0),  .x_in_1(x_in_1),   .x_in_2(x_in_2),   .x_in_3(x_in_3),
        .x_in_4(x_in_4),  .x_in_5(x_in_5),   .x_in_6(x_in_6),   .x_in_7(x_in_7),
        .x_in_8(x_in_8),  .x_in_9(x_in_9),   .x_in_10(x_in_10), .x_in_11(x_in_11),
        .x_in_12(x_in_12),.x_in_13(x_in_13), .x_in_14(x_in_14), .x_in_15(x_in_15),
        .x_in_16(x_in_16),.x_in_17(x_in_17), .x_in_18(x_in_18), .x_in_19(x_in_19),
        .x_in_20(x_in_20),.x_in_21(x_in_21), .x_in_22(x_in_22), .x_in_23(x_in_23),
        .x_in_24(x_in_24),.x_in_25(x_in_25), .x_in_26(x_in_26), .x_in_27(x_in_27),
        .x_in_28(x_in_28),.x_in_29(x_in_29), .x_in_30(x_in_30), .x_in_31(x_in_31),
        .x_in_32(x_in_32),.x_in_33(x_in_33), .x_in_34(x_in_34), .x_in_35(x_in_35),
        .x_in_36(x_in_36),.x_in_37(x_in_37), .x_in_38(x_in_38), .x_in_39(x_in_39),
        .x_in_40(x_in_40),.x_in_41(x_in_41), .x_in_42(x_in_42), .x_in_43(x_in_43),
        .x_in_44(x_in_44),.x_in_45(x_in_45), .x_in_46(x_in_46), .x_in_47(x_in_47),
        .x_in_48(x_in_48),.x_in_49(x_in_49), .x_in_50(x_in_50), .x_in_51(x_in_51),
        .x_in_52(x_in_52),.x_in_53(x_in_53), .x_in_54(x_in_54), .x_in_55(x_in_55),
        .x_in_56(x_in_56),.x_in_57(x_in_57), .x_in_58(x_in_58), .x_in_59(x_in_59),
        .x_in_60(x_in_60),.x_in_61(x_in_61), .x_in_62(x_in_62), .x_in_63(x_in_63),

        .x_we(x_we),

        .tw_addr_0(tw_addr_0), .tw_addr_1(tw_addr_1), .tw_addr_2(tw_addr_2), .tw_addr_3(tw_addr_3),
        .tw_addr_4(tw_addr_4), .tw_addr_5(tw_addr_5), .tw_addr_6(tw_addr_6), .tw_addr_7(tw_addr_7),
        .tw_addr_8(tw_addr_8), .tw_addr_9(tw_addr_9), .tw_addr_10(tw_addr_10), .tw_addr_11(tw_addr_11),
        .tw_addr_12(tw_addr_12), .tw_addr_13(tw_addr_13), .tw_addr_14(tw_addr_14), .tw_addr_15(tw_addr_15),
        .tw_addr_16(tw_addr_16), .tw_addr_17(tw_addr_17), .tw_addr_18(tw_addr_18), .tw_addr_19(tw_addr_19),
        .tw_addr_20(tw_addr_20), .tw_addr_21(tw_addr_21), .tw_addr_22(tw_addr_22), .tw_addr_23(tw_addr_23),
        .tw_addr_24(tw_addr_24), .tw_addr_25(tw_addr_25), .tw_addr_26(tw_addr_26), .tw_addr_27(tw_addr_27),
        .tw_addr_28(tw_addr_28), .tw_addr_29(tw_addr_29), .tw_addr_30(tw_addr_30), .tw_addr_31(tw_addr_31),

        .tw_out_0(tw_out_0), .tw_out_1(tw_out_1), .tw_out_2(tw_out_2), .tw_out_3(tw_out_3),
        .tw_out_4(tw_out_4), .tw_out_5(tw_out_5), .tw_out_6(tw_out_6), .tw_out_7(tw_out_7),
        .tw_out_8(tw_out_8), .tw_out_9(tw_out_9), .tw_out_10(tw_out_10), .tw_out_11(tw_out_11),
        .tw_out_12(tw_out_12), .tw_out_13(tw_out_13), .tw_out_14(tw_out_14), .tw_out_15(tw_out_15),
        .tw_out_16(tw_out_16), .tw_out_17(tw_out_17), .tw_out_18(tw_out_18), .tw_out_19(tw_out_19),
        .tw_out_20(tw_out_20), .tw_out_21(tw_out_21), .tw_out_22(tw_out_22), .tw_out_23(tw_out_23),
        .tw_out_24(tw_out_24), .tw_out_25(tw_out_25), .tw_out_26(tw_out_26), .tw_out_27(tw_out_27),
        .tw_out_28(tw_out_28), .tw_out_29(tw_out_29), .tw_out_30(tw_out_30), .tw_out_31(tw_out_31)
    );

endmodule