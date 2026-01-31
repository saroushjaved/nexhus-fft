module fft_stage_core #(
    parameter integer BW = 32,
    parameter integer N  = 64
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               start,
    input  wire [3:0]         stage,   // 0..5 for N=64 (DIT)

    // ================================
    // X-BANK (named wires)
    // ================================
    input  wire [31:0] x_out_0,  input wire [31:0] x_out_1,
    input  wire [31:0] x_out_2,  input wire [31:0] x_out_3,
    input  wire [31:0] x_out_4,  input wire [31:0] x_out_5,
    input  wire [31:0] x_out_6,  input wire [31:0] x_out_7,
    input  wire [31:0] x_out_8,  input wire [31:0] x_out_9,
    input  wire [31:0] x_out_10, input wire [31:0] x_out_11,
    input  wire [31:0] x_out_12, input wire [31:0] x_out_13,
    input  wire [31:0] x_out_14, input wire [31:0] x_out_15,
    input  wire [31:0] x_out_16, input wire [31:0] x_out_17,
    input  wire [31:0] x_out_18, input wire [31:0] x_out_19,
    input  wire [31:0] x_out_20, input wire [31:0] x_out_21,
    input  wire [31:0] x_out_22, input wire [31:0] x_out_23,
    input  wire [31:0] x_out_24, input wire [31:0] x_out_25,
    input  wire [31:0] x_out_26, input wire [31:0] x_out_27,
    input  wire [31:0] x_out_28, input wire [31:0] x_out_29,
    input  wire [31:0] x_out_30, input wire [31:0] x_out_31,
    input  wire [31:0] x_out_32, input wire [31:0] x_out_33,
    input  wire [31:0] x_out_34, input wire [31:0] x_out_35,
    input  wire [31:0] x_out_36, input wire [31:0] x_out_37,
    input  wire [31:0] x_out_38, input wire [31:0] x_out_39,
    input  wire [31:0] x_out_40, input wire [31:0] x_out_41,
    input  wire [31:0] x_out_42, input wire [31:0] x_out_43,
    input  wire [31:0] x_out_44, input wire [31:0] x_out_45,
    input  wire [31:0] x_out_46, input wire [31:0] x_out_47,
    input  wire [31:0] x_out_48, input wire [31:0] x_out_49,
    input  wire [31:0] x_out_50, input wire [31:0] x_out_51,
    input  wire [31:0] x_out_52, input wire [31:0] x_out_53,
    input  wire [31:0] x_out_54, input wire [31:0] x_out_55,
    input  wire [31:0] x_out_56, input wire [31:0] x_out_57,
    input  wire [31:0] x_out_58, input wire [31:0] x_out_59,
    input  wire [31:0] x_out_60, input wire [31:0] x_out_61,
    input  wire [31:0] x_out_62, input wire [31:0] x_out_63,

    output wire [31:0] x_in_0,  output wire [31:0] x_in_1,
    output wire [31:0] x_in_2,  output wire [31:0] x_in_3,
    output wire [31:0] x_in_4,  output wire [31:0] x_in_5,
    output wire [31:0] x_in_6,  output wire [31:0] x_in_7,
    output wire [31:0] x_in_8,  output wire [31:0] x_in_9,
    output wire [31:0] x_in_10, output wire [31:0] x_in_11,
    output wire [31:0] x_in_12, output wire [31:0] x_in_13,
    output wire [31:0] x_in_14, output wire [31:0] x_in_15,
    output wire [31:0] x_in_16, output wire [31:0] x_in_17,
    output wire [31:0] x_in_18, output wire [31:0] x_in_19,
    output wire [31:0] x_in_20, output wire [31:0] x_in_21,
    output wire [31:0] x_in_22, output wire [31:0] x_in_23,
    output wire [31:0] x_in_24, output wire [31:0] x_in_25,
    output wire [31:0] x_in_26, output wire [31:0] x_in_27,
    output wire [31:0] x_in_28, output wire [31:0] x_in_29,
    output wire [31:0] x_in_30, output wire [31:0] x_in_31,
    output wire [31:0] x_in_32, output wire [31:0] x_in_33,
    output wire [31:0] x_in_34, output wire [31:0] x_in_35,
    output wire [31:0] x_in_36, output wire [31:0] x_in_37,
    output wire [31:0] x_in_38, output wire [31:0] x_in_39,
    output wire [31:0] x_in_40, output wire [31:0] x_in_41,
    output wire [31:0] x_in_42, output wire [31:0] x_in_43,
    output wire [31:0] x_in_44, output wire [31:0] x_in_45,
    output wire [31:0] x_in_46, output wire [31:0] x_in_47,
    output wire [31:0] x_in_48, output wire [31:0] x_in_49,
    output wire [31:0] x_in_50, output wire [31:0] x_in_51,
    output wire [31:0] x_in_52, output wire [31:0] x_in_53,
    output wire [31:0] x_in_54, output wire [31:0] x_in_55,
    output wire [31:0] x_in_56, output wire [31:0] x_in_57,
    output wire [31:0] x_in_58, output wire [31:0] x_in_59,
    output wire [31:0] x_in_60, output wire [31:0] x_in_61,
    output wire [31:0] x_in_62, output wire [31:0] x_in_63,

    output wire [63:0] x_we,

    // ================================
    // Twiddle bank (Option A, named)
    // ================================
    output wire [4:0] tw_addr_0,  output wire [4:0] tw_addr_1,
    output wire [4:0] tw_addr_2,  output wire [4:0] tw_addr_3,
    output wire [4:0] tw_addr_4,  output wire [4:0] tw_addr_5,
    output wire [4:0] tw_addr_6,  output wire [4:0] tw_addr_7,
    output wire [4:0] tw_addr_8,  output wire [4:0] tw_addr_9,
    output wire [4:0] tw_addr_10, output wire [4:0] tw_addr_11,
    output wire [4:0] tw_addr_12, output wire [4:0] tw_addr_13,
    output wire [4:0] tw_addr_14, output wire [4:0] tw_addr_15,
    output wire [4:0] tw_addr_16, output wire [4:0] tw_addr_17,
    output wire [4:0] tw_addr_18, output wire [4:0] tw_addr_19,
    output wire [4:0] tw_addr_20, output wire [4:0] tw_addr_21,
    output wire [4:0] tw_addr_22, output wire [4:0] tw_addr_23,
    output wire [4:0] tw_addr_24, output wire [4:0] tw_addr_25,
    output wire [4:0] tw_addr_26, output wire [4:0] tw_addr_27,
    output wire [4:0] tw_addr_28, output wire [4:0] tw_addr_29,
    output wire [4:0] tw_addr_30, output wire [4:0] tw_addr_31,

    input  wire signed [31:0] tw_out_0,  input wire signed [31:0] tw_out_1,
    input  wire signed [31:0] tw_out_2,  input wire signed [31:0] tw_out_3,
    input  wire signed [31:0] tw_out_4,  input wire signed [31:0] tw_out_5,
    input  wire signed [31:0] tw_out_6,  input wire signed [31:0] tw_out_7,
    input  wire signed [31:0] tw_out_8,  input wire signed [31:0] tw_out_9,
    input  wire signed [31:0] tw_out_10, input wire signed [31:0] tw_out_11,
    input  wire signed [31:0] tw_out_12, input wire signed [31:0] tw_out_13,
    input  wire signed [31:0] tw_out_14, input wire signed [31:0] tw_out_15,
    input  wire signed [31:0] tw_out_16, input wire signed [31:0] tw_out_17,
    input  wire signed [31:0] tw_out_18, input wire signed [31:0] tw_out_19,
    input  wire signed [31:0] tw_out_20, input wire signed [31:0] tw_out_21,
    input  wire signed [31:0] tw_out_22, input wire signed [31:0] tw_out_23,
    input  wire signed [31:0] tw_out_24, input wire signed [31:0] tw_out_25,
    input  wire signed [31:0] tw_out_26, input wire signed [31:0] tw_out_27,
    input  wire signed [31:0] tw_out_28, input wire signed [31:0] tw_out_29,
    input  wire signed [31:0] tw_out_30, input wire signed [31:0] tw_out_31
);

    // ============================================================
    // Helpers
    // ============================================================
    function [15:0] RE16; input [31:0] c; begin RE16 = c[31:16]; end endfunction
    function [15:0] IM16; input [31:0] c; begin IM16 = c[15:0];  end endfunction
    function [31:0] PACK32; input [15:0] re; input [15:0] im; begin PACK32 = {re,im}; end endfunction

    // Select x_out[idx] with a case mux (plain Verilog safe)
    function [31:0] XSEL;
        input [5:0] idx;
        begin
            case (idx)
                6'd0:  XSEL = x_out_0;   6'd1:  XSEL = x_out_1;
                6'd2:  XSEL = x_out_2;   6'd3:  XSEL = x_out_3;
                6'd4:  XSEL = x_out_4;   6'd5:  XSEL = x_out_5;
                6'd6:  XSEL = x_out_6;   6'd7:  XSEL = x_out_7;
                6'd8:  XSEL = x_out_8;   6'd9:  XSEL = x_out_9;
                6'd10: XSEL = x_out_10;  6'd11: XSEL = x_out_11;
                6'd12: XSEL = x_out_12;  6'd13: XSEL = x_out_13;
                6'd14: XSEL = x_out_14;  6'd15: XSEL = x_out_15;
                6'd16: XSEL = x_out_16;  6'd17: XSEL = x_out_17;
                6'd18: XSEL = x_out_18;  6'd19: XSEL = x_out_19;
                6'd20: XSEL = x_out_20;  6'd21: XSEL = x_out_21;
                6'd22: XSEL = x_out_22;  6'd23: XSEL = x_out_23;
                6'd24: XSEL = x_out_24;  6'd25: XSEL = x_out_25;
                6'd26: XSEL = x_out_26;  6'd27: XSEL = x_out_27;
                6'd28: XSEL = x_out_28;  6'd29: XSEL = x_out_29;
                6'd30: XSEL = x_out_30;  6'd31: XSEL = x_out_31;
                6'd32: XSEL = x_out_32;  6'd33: XSEL = x_out_33;
                6'd34: XSEL = x_out_34;  6'd35: XSEL = x_out_35;
                6'd36: XSEL = x_out_36;  6'd37: XSEL = x_out_37;
                6'd38: XSEL = x_out_38;  6'd39: XSEL = x_out_39;
                6'd40: XSEL = x_out_40;  6'd41: XSEL = x_out_41;
                6'd42: XSEL = x_out_42;  6'd43: XSEL = x_out_43;
                6'd44: XSEL = x_out_44;  6'd45: XSEL = x_out_45;
                6'd46: XSEL = x_out_46;  6'd47: XSEL = x_out_47;
                6'd48: XSEL = x_out_48;  6'd49: XSEL = x_out_49;
                6'd50: XSEL = x_out_50;  6'd51: XSEL = x_out_51;
                6'd52: XSEL = x_out_52;  6'd53: XSEL = x_out_53;
                6'd54: XSEL = x_out_54;  6'd55: XSEL = x_out_55;
                6'd56: XSEL = x_out_56;  6'd57: XSEL = x_out_57;
                6'd58: XSEL = x_out_58;  6'd59: XSEL = x_out_59;
                6'd60: XSEL = x_out_60;  6'd61: XSEL = x_out_61;
                6'd62: XSEL = x_out_62;  6'd63: XSEL = x_out_63;
                default: XSEL = 32'h0;
            endcase
        end
    endfunction

    // DIT twiddle index for N=64, lane b (0..31)
    function [4:0] TW_IDX64_DIT;
        input [3:0] st;
        input [4:0] b;
        begin
            case (st)
                4'd0: TW_IDX64_DIT = 5'd0;
                4'd1: TW_IDX64_DIT = {b[0],   4'b0000}; // (b%2)*16
                4'd2: TW_IDX64_DIT = {b[1:0], 3'b000};  // (b%4)*8
                4'd3: TW_IDX64_DIT = {b[2:0], 2'b00};   // (b%8)*4
                4'd4: TW_IDX64_DIT = {b[3:0], 1'b0};    // (b%16)*2
                4'd5: TW_IDX64_DIT = b;                // (b%32)*1
                default: TW_IDX64_DIT = 5'd0;
            endcase
        end
    endfunction

    // ============================================================
    // Stage parameters for DIT
    // half = 2^stage, m = 2*half
    // ============================================================
    wire [5:0] half = (stage <= 4'd5) ? (6'd1 << stage) : 6'd32;
    wire [5:0] m    = half << 1;

    // ============================================================
    // Per-lane packed buses (no hierarchical indexing)
    // ============================================================
    wire [BW-1:0]         lane_v;

    wire [BW*6-1:0]       lane_i0r_bus;
    wire [BW*6-1:0]       lane_i1r_bus;

    wire [BW*16-1:0]      lane_y0_re_bus, lane_y0_im_bus;
    wire [BW*16-1:0]      lane_y1_re_bus, lane_y1_im_bus;

    // ============================================================
    // Twiddle addr outputs (named)
    // ============================================================
    assign tw_addr_0  = TW_IDX64_DIT(stage, 5'd0);
    assign tw_addr_1  = TW_IDX64_DIT(stage, 5'd1);
    assign tw_addr_2  = TW_IDX64_DIT(stage, 5'd2);
    assign tw_addr_3  = TW_IDX64_DIT(stage, 5'd3);
    assign tw_addr_4  = TW_IDX64_DIT(stage, 5'd4);
    assign tw_addr_5  = TW_IDX64_DIT(stage, 5'd5);
    assign tw_addr_6  = TW_IDX64_DIT(stage, 5'd6);
    assign tw_addr_7  = TW_IDX64_DIT(stage, 5'd7);
    assign tw_addr_8  = TW_IDX64_DIT(stage, 5'd8);
    assign tw_addr_9  = TW_IDX64_DIT(stage, 5'd9);
    assign tw_addr_10 = TW_IDX64_DIT(stage, 5'd10);
    assign tw_addr_11 = TW_IDX64_DIT(stage, 5'd11);
    assign tw_addr_12 = TW_IDX64_DIT(stage, 5'd12);
    assign tw_addr_13 = TW_IDX64_DIT(stage, 5'd13);
    assign tw_addr_14 = TW_IDX64_DIT(stage, 5'd14);
    assign tw_addr_15 = TW_IDX64_DIT(stage, 5'd15);
    assign tw_addr_16 = TW_IDX64_DIT(stage, 5'd16);
    assign tw_addr_17 = TW_IDX64_DIT(stage, 5'd17);
    assign tw_addr_18 = TW_IDX64_DIT(stage, 5'd18);
    assign tw_addr_19 = TW_IDX64_DIT(stage, 5'd19);
    assign tw_addr_20 = TW_IDX64_DIT(stage, 5'd20);
    assign tw_addr_21 = TW_IDX64_DIT(stage, 5'd21);
    assign tw_addr_22 = TW_IDX64_DIT(stage, 5'd22);
    assign tw_addr_23 = TW_IDX64_DIT(stage, 5'd23);
    assign tw_addr_24 = TW_IDX64_DIT(stage, 5'd24);
    assign tw_addr_25 = TW_IDX64_DIT(stage, 5'd25);
    assign tw_addr_26 = TW_IDX64_DIT(stage, 5'd26);
    assign tw_addr_27 = TW_IDX64_DIT(stage, 5'd27);
    assign tw_addr_28 = TW_IDX64_DIT(stage, 5'd28);
    assign tw_addr_29 = TW_IDX64_DIT(stage, 5'd29);
    assign tw_addr_30 = TW_IDX64_DIT(stage, 5'd30);
    assign tw_addr_31 = TW_IDX64_DIT(stage, 5'd31);

    // ============================================================
    // Generate 32 butterflies
    // ============================================================
    genvar g;
    generate
        for (g = 0; g < BW; g = g + 1) begin : GEN_LANE

            // lane index
            wire [5:0] b_lane = g[5:0];

            // group/j
            wire [5:0] grp  = b_lane / half;
            wire [5:0] j    = b_lane % half;
            wire [5:0] base = grp * m;

            wire [5:0] i0 = base + j;
            wire [5:0] i1 = i0 + half;

            // read A/B from x-bank (case mux)
            wire [31:0] a32 = XSEL(i0);
            wire [31:0] b32 = XSEL(i1);

            wire signed [15:0] a_re = RE16(a32);
            wire signed [15:0] a_im = IM16(a32);
            wire signed [15:0] b_re = RE16(b32);
            wire signed [15:0] b_im = IM16(b32);

            // twiddle per lane: provided by twiddle_bank_64 outputs tw_out_g
            wire signed [31:0] w32 =
                (g==0)  ? tw_out_0  :
                (g==1)  ? tw_out_1  :
                (g==2)  ? tw_out_2  :
                (g==3)  ? tw_out_3  :
                (g==4)  ? tw_out_4  :
                (g==5)  ? tw_out_5  :
                (g==6)  ? tw_out_6  :
                (g==7)  ? tw_out_7  :
                (g==8)  ? tw_out_8  :
                (g==9)  ? tw_out_9  :
                (g==10) ? tw_out_10 :
                (g==11) ? tw_out_11 :
                (g==12) ? tw_out_12 :
                (g==13) ? tw_out_13 :
                (g==14) ? tw_out_14 :
                (g==15) ? tw_out_15 :
                (g==16) ? tw_out_16 :
                (g==17) ? tw_out_17 :
                (g==18) ? tw_out_18 :
                (g==19) ? tw_out_19 :
                (g==20) ? tw_out_20 :
                (g==21) ? tw_out_21 :
                (g==22) ? tw_out_22 :
                (g==23) ? tw_out_23 :
                (g==24) ? tw_out_24 :
                (g==25) ? tw_out_25 :
                (g==26) ? tw_out_26 :
                (g==27) ? tw_out_27 :
                (g==28) ? tw_out_28 :
                (g==29) ? tw_out_29 :
                (g==30) ? tw_out_30 :
                          tw_out_31;

            wire signed [15:0] w_re = RE16(w32);
            wire signed [15:0] w_im = IM16(w32);

            // pipeline dest addresses by 1 cycle (align with fft_atomic_p1 out_valid)
            reg [5:0] i0_r, i1_r;
            always @(posedge clk) begin
                if (!rst_n) begin
                    i0_r <= 6'd0;
                    i1_r <= 6'd0;
                end else if (start) begin
                    i0_r <= i0;
                    i1_r <= i1;
                end
            end

            assign lane_i0r_bus[g*6 +: 6] = i0_r;
            assign lane_i1r_bus[g*6 +: 6] = i1_r;

            wire signed [15:0] y0_re, y0_im, y1_re, y1_im;
            wire               v_out;

            fft_atomic_p1 u_bfly (
                .clk        (clk),
                .rst_n      (rst_n),
                .in_valid   (start),

                .a_real     (a_re),
                .a_imag     (a_im),
                .b_real     (b_re),
                .b_imag     (b_im),
                .W_real     (w_re),
                .W_imag     (w_im),

                .a_real_out (y0_re),
                .a_imag_out (y0_im),
                .b_real_out (y1_re),
                .b_imag_out (y1_im),
                .out_valid  (v_out)
            );

            assign lane_v[g] = v_out;

            assign lane_y0_re_bus[g*16 +: 16] = y0_re;
            assign lane_y0_im_bus[g*16 +: 16] = y0_im;
            assign lane_y1_re_bus[g*16 +: 16] = y1_re;
            assign lane_y1_im_bus[g*16 +: 16] = y1_im;

        end
    endgenerate

    // ============================================================
    // Extract helpers for packed per-lane buses (case mux)
    // ============================================================
    function [5:0] LANE_I0R; input [5:0] k;
        begin
            case (k)
                6'd0:  LANE_I0R = lane_i0r_bus[0*6 +: 6];
                6'd1:  LANE_I0R = lane_i0r_bus[1*6 +: 6];
                6'd2:  LANE_I0R = lane_i0r_bus[2*6 +: 6];
                6'd3:  LANE_I0R = lane_i0r_bus[3*6 +: 6];
                6'd4:  LANE_I0R = lane_i0r_bus[4*6 +: 6];
                6'd5:  LANE_I0R = lane_i0r_bus[5*6 +: 6];
                6'd6:  LANE_I0R = lane_i0r_bus[6*6 +: 6];
                6'd7:  LANE_I0R = lane_i0r_bus[7*6 +: 6];
                6'd8:  LANE_I0R = lane_i0r_bus[8*6 +: 6];
                6'd9:  LANE_I0R = lane_i0r_bus[9*6 +: 6];
                6'd10: LANE_I0R = lane_i0r_bus[10*6 +: 6];
                6'd11: LANE_I0R = lane_i0r_bus[11*6 +: 6];
                6'd12: LANE_I0R = lane_i0r_bus[12*6 +: 6];
                6'd13: LANE_I0R = lane_i0r_bus[13*6 +: 6];
                6'd14: LANE_I0R = lane_i0r_bus[14*6 +: 6];
                6'd15: LANE_I0R = lane_i0r_bus[15*6 +: 6];
                6'd16: LANE_I0R = lane_i0r_bus[16*6 +: 6];
                6'd17: LANE_I0R = lane_i0r_bus[17*6 +: 6];
                6'd18: LANE_I0R = lane_i0r_bus[18*6 +: 6];
                6'd19: LANE_I0R = lane_i0r_bus[19*6 +: 6];
                6'd20: LANE_I0R = lane_i0r_bus[20*6 +: 6];
                6'd21: LANE_I0R = lane_i0r_bus[21*6 +: 6];
                6'd22: LANE_I0R = lane_i0r_bus[22*6 +: 6];
                6'd23: LANE_I0R = lane_i0r_bus[23*6 +: 6];
                6'd24: LANE_I0R = lane_i0r_bus[24*6 +: 6];
                6'd25: LANE_I0R = lane_i0r_bus[25*6 +: 6];
                6'd26: LANE_I0R = lane_i0r_bus[26*6 +: 6];
                6'd27: LANE_I0R = lane_i0r_bus[27*6 +: 6];
                6'd28: LANE_I0R = lane_i0r_bus[28*6 +: 6];
                6'd29: LANE_I0R = lane_i0r_bus[29*6 +: 6];
                6'd30: LANE_I0R = lane_i0r_bus[30*6 +: 6];
                6'd31: LANE_I0R = lane_i0r_bus[31*6 +: 6];
                default: LANE_I0R = 6'd0;
            endcase
        end
    endfunction

    function [5:0] LANE_I1R; input [5:0] k;
        begin
            case (k)
                6'd0:  LANE_I1R = lane_i1r_bus[0*6 +: 6];
                6'd1:  LANE_I1R = lane_i1r_bus[1*6 +: 6];
                6'd2:  LANE_I1R = lane_i1r_bus[2*6 +: 6];
                6'd3:  LANE_I1R = lane_i1r_bus[3*6 +: 6];
                6'd4:  LANE_I1R = lane_i1r_bus[4*6 +: 6];
                6'd5:  LANE_I1R = lane_i1r_bus[5*6 +: 6];
                6'd6:  LANE_I1R = lane_i1r_bus[6*6 +: 6];
                6'd7:  LANE_I1R = lane_i1r_bus[7*6 +: 6];
                6'd8:  LANE_I1R = lane_i1r_bus[8*6 +: 6];
                6'd9:  LANE_I1R = lane_i1r_bus[9*6 +: 6];
                6'd10: LANE_I1R = lane_i1r_bus[10*6 +: 6];
                6'd11: LANE_I1R = lane_i1r_bus[11*6 +: 6];
                6'd12: LANE_I1R = lane_i1r_bus[12*6 +: 6];
                6'd13: LANE_I1R = lane_i1r_bus[13*6 +: 6];
                6'd14: LANE_I1R = lane_i1r_bus[14*6 +: 6];
                6'd15: LANE_I1R = lane_i1r_bus[15*6 +: 6];
                6'd16: LANE_I1R = lane_i1r_bus[16*6 +: 6];
                6'd17: LANE_I1R = lane_i1r_bus[17*6 +: 6];
                6'd18: LANE_I1R = lane_i1r_bus[18*6 +: 6];
                6'd19: LANE_I1R = lane_i1r_bus[19*6 +: 6];
                6'd20: LANE_I1R = lane_i1r_bus[20*6 +: 6];
                6'd21: LANE_I1R = lane_i1r_bus[21*6 +: 6];
                6'd22: LANE_I1R = lane_i1r_bus[22*6 +: 6];
                6'd23: LANE_I1R = lane_i1r_bus[23*6 +: 6];
                6'd24: LANE_I1R = lane_i1r_bus[24*6 +: 6];
                6'd25: LANE_I1R = lane_i1r_bus[25*6 +: 6];
                6'd26: LANE_I1R = lane_i1r_bus[26*6 +: 6];
                6'd27: LANE_I1R = lane_i1r_bus[27*6 +: 6];
                6'd28: LANE_I1R = lane_i1r_bus[28*6 +: 6];
                6'd29: LANE_I1R = lane_i1r_bus[29*6 +: 6];
                6'd30: LANE_I1R = lane_i1r_bus[30*6 +: 6];
                6'd31: LANE_I1R = lane_i1r_bus[31*6 +: 6];
                default: LANE_I1R = 6'd0;
            endcase
        end
    endfunction

    function signed [15:0] LANE_Y0RE; input [5:0] k;
        begin
            case (k)
                6'd0:  LANE_Y0RE = lane_y0_re_bus[0*16 +: 16];
                6'd1:  LANE_Y0RE = lane_y0_re_bus[1*16 +: 16];
                6'd2:  LANE_Y0RE = lane_y0_re_bus[2*16 +: 16];
                6'd3:  LANE_Y0RE = lane_y0_re_bus[3*16 +: 16];
                6'd4:  LANE_Y0RE = lane_y0_re_bus[4*16 +: 16];
                6'd5:  LANE_Y0RE = lane_y0_re_bus[5*16 +: 16];
                6'd6:  LANE_Y0RE = lane_y0_re_bus[6*16 +: 16];
                6'd7:  LANE_Y0RE = lane_y0_re_bus[7*16 +: 16];
                6'd8:  LANE_Y0RE = lane_y0_re_bus[8*16 +: 16];
                6'd9:  LANE_Y0RE = lane_y0_re_bus[9*16 +: 16];
                6'd10: LANE_Y0RE = lane_y0_re_bus[10*16 +: 16];
                6'd11: LANE_Y0RE = lane_y0_re_bus[11*16 +: 16];
                6'd12: LANE_Y0RE = lane_y0_re_bus[12*16 +: 16];
                6'd13: LANE_Y0RE = lane_y0_re_bus[13*16 +: 16];
                6'd14: LANE_Y0RE = lane_y0_re_bus[14*16 +: 16];
                6'd15: LANE_Y0RE = lane_y0_re_bus[15*16 +: 16];
                6'd16: LANE_Y0RE = lane_y0_re_bus[16*16 +: 16];
                6'd17: LANE_Y0RE = lane_y0_re_bus[17*16 +: 16];
                6'd18: LANE_Y0RE = lane_y0_re_bus[18*16 +: 16];
                6'd19: LANE_Y0RE = lane_y0_re_bus[19*16 +: 16];
                6'd20: LANE_Y0RE = lane_y0_re_bus[20*16 +: 16];
                6'd21: LANE_Y0RE = lane_y0_re_bus[21*16 +: 16];
                6'd22: LANE_Y0RE = lane_y0_re_bus[22*16 +: 16];
                6'd23: LANE_Y0RE = lane_y0_re_bus[23*16 +: 16];
                6'd24: LANE_Y0RE = lane_y0_re_bus[24*16 +: 16];
                6'd25: LANE_Y0RE = lane_y0_re_bus[25*16 +: 16];
                6'd26: LANE_Y0RE = lane_y0_re_bus[26*16 +: 16];
                6'd27: LANE_Y0RE = lane_y0_re_bus[27*16 +: 16];
                6'd28: LANE_Y0RE = lane_y0_re_bus[28*16 +: 16];
                6'd29: LANE_Y0RE = lane_y0_re_bus[29*16 +: 16];
                6'd30: LANE_Y0RE = lane_y0_re_bus[30*16 +: 16];
                6'd31: LANE_Y0RE = lane_y0_re_bus[31*16 +: 16];
                default: LANE_Y0RE = 16'sd0;
            endcase
        end
    endfunction

    function signed [15:0] LANE_Y0IM; input [5:0] k;
        begin
            case (k)
                6'd0:  LANE_Y0IM = lane_y0_im_bus[0*16 +: 16];
                6'd1:  LANE_Y0IM = lane_y0_im_bus[1*16 +: 16];
                6'd2:  LANE_Y0IM = lane_y0_im_bus[2*16 +: 16];
                6'd3:  LANE_Y0IM = lane_y0_im_bus[3*16 +: 16];
                6'd4:  LANE_Y0IM = lane_y0_im_bus[4*16 +: 16];
                6'd5:  LANE_Y0IM = lane_y0_im_bus[5*16 +: 16];
                6'd6:  LANE_Y0IM = lane_y0_im_bus[6*16 +: 16];
                6'd7:  LANE_Y0IM = lane_y0_im_bus[7*16 +: 16];
                6'd8:  LANE_Y0IM = lane_y0_im_bus[8*16 +: 16];
                6'd9:  LANE_Y0IM = lane_y0_im_bus[9*16 +: 16];
                6'd10: LANE_Y0IM = lane_y0_im_bus[10*16 +: 16];
                6'd11: LANE_Y0IM = lane_y0_im_bus[11*16 +: 16];
                6'd12: LANE_Y0IM = lane_y0_im_bus[12*16 +: 16];
                6'd13: LANE_Y0IM = lane_y0_im_bus[13*16 +: 16];
                6'd14: LANE_Y0IM = lane_y0_im_bus[14*16 +: 16];
                6'd15: LANE_Y0IM = lane_y0_im_bus[15*16 +: 16];
                6'd16: LANE_Y0IM = lane_y0_im_bus[16*16 +: 16];
                6'd17: LANE_Y0IM = lane_y0_im_bus[17*16 +: 16];
                6'd18: LANE_Y0IM = lane_y0_im_bus[18*16 +: 16];
                6'd19: LANE_Y0IM = lane_y0_im_bus[19*16 +: 16];
                6'd20: LANE_Y0IM = lane_y0_im_bus[20*16 +: 16];
                6'd21: LANE_Y0IM = lane_y0_im_bus[21*16 +: 16];
                6'd22: LANE_Y0IM = lane_y0_im_bus[22*16 +: 16];
                6'd23: LANE_Y0IM = lane_y0_im_bus[23*16 +: 16];
                6'd24: LANE_Y0IM = lane_y0_im_bus[24*16 +: 16];
                6'd25: LANE_Y0IM = lane_y0_im_bus[25*16 +: 16];
                6'd26: LANE_Y0IM = lane_y0_im_bus[26*16 +: 16];
                6'd27: LANE_Y0IM = lane_y0_im_bus[27*16 +: 16];
                6'd28: LANE_Y0IM = lane_y0_im_bus[28*16 +: 16];
                6'd29: LANE_Y0IM = lane_y0_im_bus[29*16 +: 16];
                6'd30: LANE_Y0IM = lane_y0_im_bus[30*16 +: 16];
                6'd31: LANE_Y0IM = lane_y0_im_bus[31*16 +: 16];
                default: LANE_Y0IM = 16'sd0;
            endcase
        end
    endfunction

    function signed [15:0] LANE_Y1RE; input [5:0] k;
        begin
            case (k)
                6'd0:  LANE_Y1RE = lane_y1_re_bus[0*16 +: 16];
                6'd1:  LANE_Y1RE = lane_y1_re_bus[1*16 +: 16];
                6'd2:  LANE_Y1RE = lane_y1_re_bus[2*16 +: 16];
                6'd3:  LANE_Y1RE = lane_y1_re_bus[3*16 +: 16];
                6'd4:  LANE_Y1RE = lane_y1_re_bus[4*16 +: 16];
                6'd5:  LANE_Y1RE = lane_y1_re_bus[5*16 +: 16];
                6'd6:  LANE_Y1RE = lane_y1_re_bus[6*16 +: 16];
                6'd7:  LANE_Y1RE = lane_y1_re_bus[7*16 +: 16];
                6'd8:  LANE_Y1RE = lane_y1_re_bus[8*16 +: 16];
                6'd9:  LANE_Y1RE = lane_y1_re_bus[9*16 +: 16];
                6'd10: LANE_Y1RE = lane_y1_re_bus[10*16 +: 16];
                6'd11: LANE_Y1RE = lane_y1_re_bus[11*16 +: 16];
                6'd12: LANE_Y1RE = lane_y1_re_bus[12*16 +: 16];
                6'd13: LANE_Y1RE = lane_y1_re_bus[13*16 +: 16];
                6'd14: LANE_Y1RE = lane_y1_re_bus[14*16 +: 16];
                6'd15: LANE_Y1RE = lane_y1_re_bus[15*16 +: 16];
                6'd16: LANE_Y1RE = lane_y1_re_bus[16*16 +: 16];
                6'd17: LANE_Y1RE = lane_y1_re_bus[17*16 +: 16];
                6'd18: LANE_Y1RE = lane_y1_re_bus[18*16 +: 16];
                6'd19: LANE_Y1RE = lane_y1_re_bus[19*16 +: 16];
                6'd20: LANE_Y1RE = lane_y1_re_bus[20*16 +: 16];
                6'd21: LANE_Y1RE = lane_y1_re_bus[21*16 +: 16];
                6'd22: LANE_Y1RE = lane_y1_re_bus[22*16 +: 16];
                6'd23: LANE_Y1RE = lane_y1_re_bus[23*16 +: 16];
                6'd24: LANE_Y1RE = lane_y1_re_bus[24*16 +: 16];
                6'd25: LANE_Y1RE = lane_y1_re_bus[25*16 +: 16];
                6'd26: LANE_Y1RE = lane_y1_re_bus[26*16 +: 16];
                6'd27: LANE_Y1RE = lane_y1_re_bus[27*16 +: 16];
                6'd28: LANE_Y1RE = lane_y1_re_bus[28*16 +: 16];
                6'd29: LANE_Y1RE = lane_y1_re_bus[29*16 +: 16];
                6'd30: LANE_Y1RE = lane_y1_re_bus[30*16 +: 16];
                6'd31: LANE_Y1RE = lane_y1_re_bus[31*16 +: 16];
                default: LANE_Y1RE = 16'sd0;
            endcase
        end
    endfunction

    function signed [15:0] LANE_Y1IM; input [5:0] k;
        begin
            case (k)
                6'd0:  LANE_Y1IM = lane_y1_im_bus[0*16 +: 16];
                6'd1:  LANE_Y1IM = lane_y1_im_bus[1*16 +: 16];
                6'd2:  LANE_Y1IM = lane_y1_im_bus[2*16 +: 16];
                6'd3:  LANE_Y1IM = lane_y1_im_bus[3*16 +: 16];
                6'd4:  LANE_Y1IM = lane_y1_im_bus[4*16 +: 16];
                6'd5:  LANE_Y1IM = lane_y1_im_bus[5*16 +: 16];
                6'd6:  LANE_Y1IM = lane_y1_im_bus[6*16 +: 16];
                6'd7:  LANE_Y1IM = lane_y1_im_bus[7*16 +: 16];
                6'd8:  LANE_Y1IM = lane_y1_im_bus[8*16 +: 16];
                6'd9:  LANE_Y1IM = lane_y1_im_bus[9*16 +: 16];
                6'd10: LANE_Y1IM = lane_y1_im_bus[10*16 +: 16];
                6'd11: LANE_Y1IM = lane_y1_im_bus[11*16 +: 16];
                6'd12: LANE_Y1IM = lane_y1_im_bus[12*16 +: 16];
                6'd13: LANE_Y1IM = lane_y1_im_bus[13*16 +: 16];
                6'd14: LANE_Y1IM = lane_y1_im_bus[14*16 +: 16];
                6'd15: LANE_Y1IM = lane_y1_im_bus[15*16 +: 16];
                6'd16: LANE_Y1IM = lane_y1_im_bus[16*16 +: 16];
                6'd17: LANE_Y1IM = lane_y1_im_bus[17*16 +: 16];
                6'd18: LANE_Y1IM = lane_y1_im_bus[18*16 +: 16];
                6'd19: LANE_Y1IM = lane_y1_im_bus[19*16 +: 16];
                6'd20: LANE_Y1IM = lane_y1_im_bus[20*16 +: 16];
                6'd21: LANE_Y1IM = lane_y1_im_bus[21*16 +: 16];
                6'd22: LANE_Y1IM = lane_y1_im_bus[22*16 +: 16];
                6'd23: LANE_Y1IM = lane_y1_im_bus[23*16 +: 16];
                6'd24: LANE_Y1IM = lane_y1_im_bus[24*16 +: 16];
                6'd25: LANE_Y1IM = lane_y1_im_bus[25*16 +: 16];
                6'd26: LANE_Y1IM = lane_y1_im_bus[26*16 +: 16];
                6'd27: LANE_Y1IM = lane_y1_im_bus[27*16 +: 16];
                6'd28: LANE_Y1IM = lane_y1_im_bus[28*16 +: 16];
                6'd29: LANE_Y1IM = lane_y1_im_bus[29*16 +: 16];
                6'd30: LANE_Y1IM = lane_y1_im_bus[30*16 +: 16];
                6'd31: LANE_Y1IM = lane_y1_im_bus[31*16 +: 16];
                default: LANE_Y1IM = 16'sd0;
            endcase
        end
    endfunction

    // ============================================================
    // Writeback comb logic: start from current x_out, overwrite i0/i1
    // ============================================================
    reg [31:0] x_in_arr [0:63];
    reg [63:0] x_we_r;

    integer ii, kk;
    always @(*) begin
        // default: hold values, no writes
        for (ii = 0; ii < 64; ii = ii + 1) begin
            x_in_arr[ii] = XSEL(ii[5:0]);
        end
        x_we_r = 64'd0;

        // apply lane results when valid
        for (kk = 0; kk < BW; kk = kk + 1) begin
            if (lane_v[kk]) begin
                x_in_arr[LANE_I0R(kk[5:0])] = PACK32(LANE_Y0RE(kk[5:0]), LANE_Y0IM(kk[5:0]));
                x_in_arr[LANE_I1R(kk[5:0])] = PACK32(LANE_Y1RE(kk[5:0]), LANE_Y1IM(kk[5:0]));
                x_we_r[LANE_I0R(kk[5:0])]   = 1'b1;
                x_we_r[LANE_I1R(kk[5:0])]   = 1'b1;
            end
        end
    end

    assign x_we = x_we_r;

    // drive named x_in_* outputs from array
    assign x_in_0  = x_in_arr[0];  assign x_in_1  = x_in_arr[1];
    assign x_in_2  = x_in_arr[2];  assign x_in_3  = x_in_arr[3];
    assign x_in_4  = x_in_arr[4];  assign x_in_5  = x_in_arr[5];
    assign x_in_6  = x_in_arr[6];  assign x_in_7  = x_in_arr[7];
    assign x_in_8  = x_in_arr[8];  assign x_in_9  = x_in_arr[9];
    assign x_in_10 = x_in_arr[10]; assign x_in_11 = x_in_arr[11];
    assign x_in_12 = x_in_arr[12]; assign x_in_13 = x_in_arr[13];
    assign x_in_14 = x_in_arr[14]; assign x_in_15 = x_in_arr[15];
    assign x_in_16 = x_in_arr[16]; assign x_in_17 = x_in_arr[17];
    assign x_in_18 = x_in_arr[18]; assign x_in_19 = x_in_arr[19];
    assign x_in_20 = x_in_arr[20]; assign x_in_21 = x_in_arr[21];
    assign x_in_22 = x_in_arr[22]; assign x_in_23 = x_in_arr[23];
    assign x_in_24 = x_in_arr[24]; assign x_in_25 = x_in_arr[25];
    assign x_in_26 = x_in_arr[26]; assign x_in_27 = x_in_arr[27];
    assign x_in_28 = x_in_arr[28]; assign x_in_29 = x_in_arr[29];
    assign x_in_30 = x_in_arr[30]; assign x_in_31 = x_in_arr[31];
    assign x_in_32 = x_in_arr[32]; assign x_in_33 = x_in_arr[33];
    assign x_in_34 = x_in_arr[34]; assign x_in_35 = x_in_arr[35];
    assign x_in_36 = x_in_arr[36]; assign x_in_37 = x_in_arr[37];
    assign x_in_38 = x_in_arr[38]; assign x_in_39 = x_in_arr[39];
    assign x_in_40 = x_in_arr[40]; assign x_in_41 = x_in_arr[41];
    assign x_in_42 = x_in_arr[42]; assign x_in_43 = x_in_arr[43];
    assign x_in_44 = x_in_arr[44]; assign x_in_45 = x_in_arr[45];
    assign x_in_46 = x_in_arr[46]; assign x_in_47 = x_in_arr[47];
    assign x_in_48 = x_in_arr[48]; assign x_in_49 = x_in_arr[49];
    assign x_in_50 = x_in_arr[50]; assign x_in_51 = x_in_arr[51];
    assign x_in_52 = x_in_arr[52]; assign x_in_53 = x_in_arr[53];
    assign x_in_54 = x_in_arr[54]; assign x_in_55 = x_in_arr[55];
    assign x_in_56 = x_in_arr[56]; assign x_in_57 = x_in_arr[57];
    assign x_in_58 = x_in_arr[58]; assign x_in_59 = x_in_arr[59];
    assign x_in_60 = x_in_arr[60]; assign x_in_61 = x_in_arr[61];
    assign x_in_62 = x_in_arr[62]; assign x_in_63 = x_in_arr[63];

endmodule