`timescale 1ns / 1ps

module fft_stage_core_runtime #(
    parameter int NMAX = 2048
)(
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic [3:0] stage,
    input  logic [3:0] size_log2,
    output logic done,
    output logic busy,

    output logic [$clog2(NMAX)-1:0]   rd_addr_a,
    output logic [$clog2(NMAX)-1:0]   rd_addr_b,
    input  logic [31:0]               rd_data_a,
    input  logic [31:0]               rd_data_b,

    output logic                      wr_en_a,
    output logic                      wr_en_b,
    output logic [$clog2(NMAX)-1:0]   wr_addr_a,
    output logic [$clog2(NMAX)-1:0]   wr_addr_b,
    output logic [31:0]               wr_data_a,
    output logic [31:0]               wr_data_b,

    output logic [$clog2(NMAX/2)-1:0] tw_addr,
    input  logic [31:0]               tw_data
);

    localparam int AW     = $clog2(NMAX);
    localparam int TW_AW  = $clog2(NMAX/2);

    typedef enum logic [3:0] {
        S_IDLE,
        S_ADDR,
        S_MEMWAIT,
        S_READ,
        S_RUN,
        S_WAIT,
        S_WRITE,
        S_NEXT,
        S_DONE
    } state_t;

    state_t state, next_state;

    logic [AW-1:0] pair_idx;
    logic [AW-1:0] pair_idx_next;

    logic [AW:0] active_n;
    logic [AW:0] active_pairs;
    logic [AW:0] span;
    logic [AW:0] group_size;
    logic [AW-1:0] last_pair_idx;

    logic [AW:0] j_idx_w;
    logic [AW:0] grp_idx_w;

    logic [AW-1:0]    a_idx_calc;
    logic [AW-1:0]    b_idx_calc;
    logic [TW_AW-1:0] tw_idx_calc;

    logic [AW-1:0]    a_idx_reg, b_idx_reg;
    logic [TW_AW-1:0] tw_idx_reg;

    logic [31:0] a_data_reg;
    logic [31:0] b_data_reg;

    logic in_valid;
    logic out_valid;

    logic signed [15:0] a_real_out;
    logic signed [15:0] a_imag_out;
    logic signed [15:0] b_real_out;
    logic signed [15:0] b_imag_out;

    always_comb begin
        active_n     = ({{AW{1'b0}}, 1'b1} << size_log2);
        active_pairs = active_n >> 1;
        span         = ({{AW{1'b0}}, 1'b1} << stage);
        group_size   = ({{AW{1'b0}}, 1'b1} << (stage + 1'b1));
        last_pair_idx = active_pairs[AW-1:0] - {{AW-1{1'b0}}, 1'b1};
    end

    always_comb begin
        j_idx_w     = '0;
        grp_idx_w   = '0;
        a_idx_calc  = '0;
        b_idx_calc  = '0;
        tw_idx_calc = '0;

        if (span != 0) begin
            j_idx_w   = pair_idx % span;
            grp_idx_w = pair_idx / span;
        end

        a_idx_calc = (grp_idx_w * group_size) + j_idx_w;
        b_idx_calc = a_idx_calc + span[AW-1:0];

        if (group_size != 0)
            tw_idx_calc = j_idx_w * (active_n / group_size);
    end

    always_comb begin
        rd_addr_a = a_idx_reg;
        rd_addr_b = b_idx_reg;
        tw_addr   = tw_idx_reg;

        wr_addr_a = a_idx_reg;
        wr_addr_b = b_idx_reg;

        wr_data_a = {a_real_out, a_imag_out};
        wr_data_b = {b_real_out, b_imag_out};

        wr_en_a   = 1'b0;
        wr_en_b   = 1'b0;

        done      = 1'b0;
        busy      = (state != S_IDLE);
        in_valid  = 1'b0;

        case (state)
            S_RUN: begin
                in_valid = 1'b1;
            end

            S_WRITE: begin
                wr_en_a = 1'b1;
                wr_en_b = 1'b1;
            end

            S_DONE: begin
                done = 1'b1;
            end

            default: begin
            end
        endcase
    end

    always_comb begin
        next_state    = state;
        pair_idx_next = pair_idx;

        case (state)
            S_IDLE: begin
                if (start)
                    next_state = S_ADDR;
            end

            S_ADDR: begin
                next_state = S_MEMWAIT;
            end

            S_MEMWAIT: begin
                next_state = S_READ;
            end

            S_READ: begin
                next_state = S_RUN;
            end

            S_RUN: begin
                next_state = S_WAIT;
            end

            S_WAIT: begin
                if (out_valid)
                    next_state = S_WRITE;
            end

            S_WRITE: begin
                next_state = S_NEXT;
            end

            S_NEXT: begin
                if (pair_idx == last_pair_idx)
                    next_state = S_DONE;
                else begin
                    pair_idx_next = pair_idx + 1'b1;
                    next_state    = S_ADDR;
                end
            end

            S_DONE: begin
                next_state = S_IDLE;
            end

            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= S_IDLE;
            pair_idx   <= '0;
            a_idx_reg  <= '0;
            b_idx_reg  <= '0;
            tw_idx_reg <= '0;
            a_data_reg <= '0;
            b_data_reg <= '0;
        end
        else begin
            state    <= next_state;
            pair_idx <= pair_idx_next;

            case (state)
                S_IDLE: begin
                    if (start)
                        pair_idx <= '0;
                end

                S_ADDR: begin
                    a_idx_reg  <= a_idx_calc;
                    b_idx_reg  <= b_idx_calc;
                    tw_idx_reg <= tw_idx_calc;
                end

                S_READ: begin
                    a_data_reg <= rd_data_a;
                    b_data_reg <= rd_data_b;
                end

                default: begin
                end
            endcase
        end
    end

    fft_atomic_p1 u_bfly (
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (in_valid),
        .a_real    (a_data_reg[31:16]),
        .a_imag    (a_data_reg[15:0]),
        .b_real    (b_data_reg[31:16]),
        .b_imag    (b_data_reg[15:0]),
        .W_real    (tw_data[31:16]),
        .W_imag    (tw_data[15:0]),
        .a_real_out(a_real_out),
        .a_imag_out(a_imag_out),
        .b_real_out(b_real_out),
        .b_imag_out(b_imag_out),
        .out_valid (out_valid)
    );

endmodule
