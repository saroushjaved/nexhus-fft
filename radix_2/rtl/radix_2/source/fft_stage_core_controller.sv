`timescale 1ns/1ps

module fft_stage_core_controller #(
    parameter int N = 1024
)(
    input  logic            clk,
    input  logic            rst_n,
    input  logic            start,
    input  logic [3:0]      stage,
    output logic            done,
    output logic            busy,

    // External sample memory write port (used when idle)
    input  logic            ext_we,
    input  logic [$clog2(N)-1:0] ext_waddr,
    input  logic [31:0]     ext_wdata,

    // External sample memory read port
    input  logic [$clog2(N)-1:0] ext_raddr,
    output logic [31:0]     ext_rdata
);

    localparam int AW    = $clog2(N);
    localparam int TW_AW = $clog2(N/2);

    typedef enum logic [2:0] {
        S_IDLE,
        S_REORDER,
        S_KICK,
        S_RUN,
        S_DONE
    } state_t;

    state_t state, next_state;


    function automatic [AW-1:0] bitrev(input [AW-1:0] x);
        integer i;
        begin
            for (i = 0; i < AW; i = i + 1)
                bitrev[i] = x[AW-1-i];
        end
    endfunction
    // ------------------------------------------------------------
    // Local sample memory
    // ------------------------------------------------------------
    logic [31:0] sample_mem [0:N-1];

    // ------------------------------------------------------------
    // Stage-core handshake
    // ------------------------------------------------------------
    logic core_start;
    logic core_done;
    logic core_busy;

    // ------------------------------------------------------------
    // Stage-core RAM ports
    // ------------------------------------------------------------
    logic [AW-1:0] rd_addr_a;
    logic [AW-1:0] rd_addr_b;
    logic [31:0]   rd_data_a;
    logic [31:0]   rd_data_b;

    logic          wr_en_a;
    logic          wr_en_b;
    logic [AW-1:0] wr_addr_a;
    logic [AW-1:0] wr_addr_b;
    logic [31:0]   wr_data_a;
    logic [31:0]   wr_data_b;

    // ------------------------------------------------------------
    // Twiddle ROM ports
    // ------------------------------------------------------------
    logic [TW_AW-1:0] tw_addr;
    logic [31:0]      tw_data;

    // ------------------------------------------------------------
    // External read port always available
    // ------------------------------------------------------------
    assign ext_rdata = sample_mem[ext_raddr];

    // ------------------------------------------------------------
    // Sample memory read behavior for stage core
    // Async-read style for now
    // ------------------------------------------------------------
    assign rd_data_a = sample_mem[rd_addr_a];
    assign rd_data_b = sample_mem[rd_addr_b];

    // ------------------------------------------------------------
    // Twiddle ROM
    // ------------------------------------------------------------
    twiddle_rom #(
        .N(N/2)
    ) u_twiddle_rom (
        .tw_addr(tw_addr),
        .tw_data(tw_data)
    );

    // ------------------------------------------------------------
    // RAM-based stage core
    // ------------------------------------------------------------
    fft_stage_core #(
        .N(N)
    ) u_stage_core (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (core_start),
        .stage    (stage),
        .done     (core_done),
        .busy     (core_busy),

        .rd_addr_a(rd_addr_a),
        .rd_addr_b(rd_addr_b),
        .rd_data_a(rd_data_a),
        .rd_data_b(rd_data_b),

        .wr_en_a  (wr_en_a),
        .wr_en_b  (wr_en_b),
        .wr_addr_a(wr_addr_a),
        .wr_addr_b(wr_addr_b),
        .wr_data_a(wr_data_a),
        .wr_data_b(wr_data_b),

        .tw_addr  (tw_addr),
        .tw_data  (tw_data)
    );

    // ------------------------------------------------------------
    // FSM outputs
    // ------------------------------------------------------------
always_comb begin
    next_state = state;

    core_start = 1'b0;
    done       = 1'b0;
    busy       = (state != S_IDLE);

    case (state)
        S_IDLE: begin
            if (start) begin
                if (stage == 4'd0)
                    next_state = S_REORDER;
                else
                    next_state = S_KICK;
            end
        end

        S_REORDER: begin
            next_state = S_KICK;
        end

        S_KICK: begin
            core_start = 1'b1;
            next_state = S_RUN;
        end

        S_RUN: begin
            if (core_done)
                next_state = S_DONE;
        end

        S_DONE: begin
            done       = 1'b1;
            next_state = S_IDLE;
        end

        default: begin
            next_state = S_IDLE;
        end
    endcase
end
    // ------------------------------------------------------------
    // State register
    // ------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // ------------------------------------------------------------
    // Sample memory write arbitration
    // External writes allowed only in IDLE
    // Stage-core writes allowed only in RUN
    // ------------------------------------------------------------
integer k;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (k = 0; k < N; k = k + 1)
            sample_mem[k] <= 32'd0;
    end
    else begin
        case (state)
            S_IDLE: begin
                if (ext_we)
                    sample_mem[ext_waddr] <= ext_wdata;
            end

            S_REORDER: begin
                for (k = 0; k < N; k = k + 1)
                    sample_mem[k] <= sample_mem[bitrev(k[AW-1:0])];
            end

            S_RUN: begin
                if (wr_en_a)
                    sample_mem[wr_addr_a] <= wr_data_a;
                if (wr_en_b)
                    sample_mem[wr_addr_b] <= wr_data_b;
            end

            default: begin
            end
        endcase
    end
end
endmodule