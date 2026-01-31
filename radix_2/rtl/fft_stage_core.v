module fft_stage_core #(
    parameter integer BW = 32,       // butterflies per cycle
    parameter integer N  = 1024       // FFT size (power of two)
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               start,
    input  wire [3:0]         stage,  // 0..LOG2N-1

    // Handshake
    output reg                done,

    // Read address outputs to BRAM (packed bus: BW lanes * LOG2N bits)
    output wire [BW*LOG2N-1:0] a_addr_bus,
    output wire [BW*LOG2N-1:0] b_addr_bus,
    output reg                 rd_en,

    // Write address outputs to BRAM (packed bus)
    output wire [BW*LOG2N-1:0] y0_addr_bus,
    output wire [BW*LOG2N-1:0] y1_addr_bus,
    output reg                 wr_en,

    // Data from BRAM (packed bus: BW lanes * 16 bits), valid 1 cycle after rd_en+addr
    input  wire signed [BW*16-1:0] a_real_in_bus,
    input  wire signed [BW*16-1:0] a_imag_in_bus,
    input  wire signed [BW*16-1:0] b_real_in_bus,
    input  wire signed [BW*16-1:0] b_imag_in_bus,

    // Twiddles (packed bus: BW lanes * 16 bits), must align with BRAM data cycle
    input  wire signed [BW*16-1:0] W_real_in_bus,
    input  wire signed [BW*16-1:0] W_imag_in_bus,

    // Outputs to write back to BRAM (packed bus: BW lanes * 16 bits), valid with wr_en
    output wire signed [BW*16-1:0] y0_real_out_bus,
    output wire signed [BW*16-1:0] y0_imag_out_bus,
    output wire signed [BW*16-1:0] y1_real_out_bus,
    output wire signed [BW*16-1:0] y1_imag_out_bus
);

    // ------------------------------------------------------------
    // Verilog-friendly clog2
    // ------------------------------------------------------------
    function integer clog2;
        input integer value;
        integer v;
        begin
            v = value - 1;
            for (clog2 = 0; v > 0; clog2 = clog2 + 1)
                v = v >> 1;
        end
    endfunction

    localparam integer LOG2N = clog2(N);

    // ------------------------------------------------------------
    // Stage parameters (shift-only, synthesizable)
    // half_m = 1<<stage
    // m      = 1<<(stage+1)
    // step   = N>>(stage+1)
    // ------------------------------------------------------------
    wire [LOG2N:0] half_m = ({{LOG2N{1'b0}},1'b1} << stage);
    wire [LOG2N:0] m      = (half_m << 1);
    wire [LOG2N:0] step   = (N >> (stage + 1));  // (not used inside here, but kept for completeness)

    // ------------------------------------------------------------
    // FSM counters
    // ------------------------------------------------------------
    reg [LOG2N-1:0] k_base, j_base;
    reg [LOG2N-1:0] k_next, j_next;

    // FSM
    localparam [1:0] IDLE  = 2'd0;
    localparam [1:0] RUN   = 2'd1;
    localparam [1:0] DONEs = 2'd2;

    reg [1:0] state, state_next;

    // next-state logic
    always @(*) begin
        state_next = state;
        k_next     = k_base;
        j_next     = j_base;

        rd_en      = 1'b0;
        done       = 1'b0;

        case (state)
            IDLE: begin
                if (start) begin
                    k_next     = {LOG2N{1'b0}};
                    j_next     = {LOG2N{1'b0}};
                    state_next = RUN;
                end
            end

            RUN: begin
                rd_en = 1'b1;

                // advance j by BW
                if ((j_base + BW[LOG2N-1:0]) >= half_m[LOG2N-1:0]) begin
                    j_next = {LOG2N{1'b0}};

                    // advance k by m
                    if ((k_base + m[LOG2N-1:0]) >= N[LOG2N-1:0]) begin
                        state_next = DONEs;
                    end else begin
                        k_next = k_base + m[LOG2N-1:0];
                    end
                end else begin
                    j_next = j_base + BW[LOG2N-1:0];
                end
            end

            DONEs: begin
                done       = 1'b1;    // 1-cycle pulse
                state_next = IDLE;
            end

            default: begin
                state_next = IDLE;
            end
        endcase
    end

    // state regs
    always @(posedge clk) begin
        if (!rst_n) begin
            state  <= IDLE;
            k_base <= {LOG2N{1'b0}};
            j_base <= {LOG2N{1'b0}};
        end else begin
            state  <= state_next;
            k_base <= k_next;
            j_base <= j_next;
        end
    end

    // ------------------------------------------------------------
    // Address generation (combinational) -> packed buses
    // a_idx = k + (j + lane)
    // b_idx = a_idx + half_m
    // ------------------------------------------------------------
    genvar gi;
    generate
        for (gi = 0; gi < BW; gi = gi + 1) begin : GEN_ADDR
            // per-lane computed addresses
            wire [LOG2N-1:0] a_lane = k_base + j_base + gi[LOG2N-1:0];
            wire [LOG2N-1:0] b_lane = a_lane + half_m[LOG2N-1:0];

            // pack into buses
            assign a_addr_bus[(gi+1)*LOG2N-1 -: LOG2N] = a_lane;
            assign b_addr_bus[(gi+1)*LOG2N-1 -: LOG2N] = b_lane;
        end
    endgenerate

    // ------------------------------------------------------------
    // Control alignment:
    // BRAM read latency = 1 cycle
    // fft_atomic_p1 latency = 1 cycle
    // => writeback latency = 2 cycles
    // ------------------------------------------------------------
    reg rd_en_d1, rd_en_d2;

    reg [BW*LOG2N-1:0] y0_addr_d1_bus, y0_addr_d2_bus;
    reg [BW*LOG2N-1:0] y1_addr_d1_bus, y1_addr_d2_bus;

    always @(posedge clk) begin
        if (!rst_n) begin
            rd_en_d1 <= 1'b0;
            rd_en_d2 <= 1'b0;

            y0_addr_d1_bus <= {BW*LOG2N{1'b0}};
            y0_addr_d2_bus <= {BW*LOG2N{1'b0}};
            y1_addr_d1_bus <= {BW*LOG2N{1'b0}};
            y1_addr_d2_bus <= {BW*LOG2N{1'b0}};
        end else begin
            rd_en_d1 <= rd_en;
            rd_en_d2 <= rd_en_d1;

            // y0/y1 addresses are just the read indices, delayed
            y0_addr_d1_bus <= a_addr_bus;
            y0_addr_d2_bus <= y0_addr_d1_bus;

            y1_addr_d1_bus <= b_addr_bus;
            y1_addr_d2_bus <= y1_addr_d1_bus;
        end
    end

    // write enable aligned to output data
    always @(posedge clk) begin
        if (!rst_n) wr_en <= 1'b0;
        else       wr_en <= rd_en_d2;
    end

    assign y0_addr_bus = y0_addr_d2_bus;
    assign y1_addr_bus = y1_addr_d2_bus;

    // ------------------------------------------------------------
    // 32 butterflies (atomic is pipelined)
    // BRAM data valid on rd_en_d1 cycle; feed that into atomic_p1
    // Atomic outputs valid 1 cycle later => aligned to wr_en (= rd_en_d2)
    // ------------------------------------------------------------
    generate
        for (gi = 0; gi < BW; gi = gi + 1) begin : GEN_BFLY
            wire signed [15:0] a_r = a_real_in_bus[(gi+1)*16-1 -: 16];
            wire signed [15:0] a_i = a_imag_in_bus[(gi+1)*16-1 -: 16];
            wire signed [15:0] b_r = b_real_in_bus[(gi+1)*16-1 -: 16];
            wire signed [15:0] b_i = b_imag_in_bus[(gi+1)*16-1 -: 16];

            wire signed [15:0] w_r = W_real_in_bus[(gi+1)*16-1 -: 16];
            wire signed [15:0] w_i = W_imag_in_bus[(gi+1)*16-1 -: 16];

            wire signed [15:0] y0_r, y0_i, y1_r, y1_i;
            wire               out_v; // optional

            fft_atomic_p1 u_atomic_p1 (
                .clk       (clk),
                .rst_n     (rst_n),
                .in_valid  (rd_en_d1),

                .a_real    (a_r),
                .a_imag    (a_i),
                .b_real    (b_r),
                .b_imag    (b_i),
                .W_real    (w_r),
                .W_imag    (w_i),

                .a_real_out(y0_r),
                .a_imag_out(y0_i),
                .b_real_out(y1_r),
                .b_imag_out(y1_i),
                .out_valid (out_v)
            );

            assign y0_real_out_bus[(gi+1)*16-1 -: 16] = y0_r;
            assign y0_imag_out_bus[(gi+1)*16-1 -: 16] = y0_i;
            assign y1_real_out_bus[(gi+1)*16-1 -: 16] = y1_r;
            assign y1_imag_out_bus[(gi+1)*16-1 -: 16] = y1_i;
        end
    endgenerate

endmodule