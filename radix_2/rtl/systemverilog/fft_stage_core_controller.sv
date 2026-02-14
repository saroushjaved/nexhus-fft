module fft_stage_core_controller #(
    parameter int N           = 16,   // number of lanes (must be even)
    parameter int CORE_CYCLES = 2,    // stage core latency in cycles
    parameter bit AUTO_STAGE  = 1'b1, // 1: run full FFT (stage 0..log2(N)-1) per start
    parameter string TW_FILE  = "twiddle16.mem" // twiddle ROM init file
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             start,
    input  logic [3:0]       stage,        // used only when AUTO_STAGE=0
    input  logic [N*32-1:0]  fft_data_in,
    output logic [N*32-1:0]  fft_data_out,
    output logic             done
);

    localparam int LOGN = $clog2(N);
    localparam int N_BFLY = N/2;

    //--------------------------------------------------------------------------
    // FSM
    //--------------------------------------------------------------------------
    localparam logic [1:0] S_IDLE = 2'b00;
    localparam logic [1:0] S_LOAD = 2'b01;
    localparam logic [1:0] S_RUN  = 2'b10;
    localparam logic [1:0] S_DONE = 2'b11;

    logic [1:0] state, next_state;
    logic       load_en, run_en;
    logic [15:0] run_cnt;

    // internal stage counter when AUTO_STAGE=1
    // (guard for small N where LOGN could be 1)
    localparam int STW = (LOGN <= 1) ? 1 : $clog2(LOGN);
    logic [STW-1:0] stage_reg;
    logic [3:0]     stage_eff;

    // start rising edge detect (prevents re-trigger while start is held high)
    logic start_d;
    logic start_pulse;

    // One-cycle pulse to core per stage window (prevents double-issuing)
    logic core_start;

    //--------------------------------------------------------------------------
    // Internal datapath arrays
    //--------------------------------------------------------------------------
    logic [31:0] x_out      [0:N-1];   // RAM outputs (true stored state)
    logic [31:0] core_x_out [0:N-1];   // permuted inputs to core (adjacent pairs)
    logic [31:0] core_x_in  [0:N-1];   // core outputs (adjacent pairs)

    logic [31:0] ram_wdata  [0:N-1];   // write data into RAM
    logic [N-1:0] core_x_we;
    logic [N-1:0] ram_we;

    // Twiddles: one per butterfly
    logic [$clog2(N)-1:0] waddr [0:N_BFLY-1];
    logic signed [31:0]   tw    [0:N_BFLY-1];

    //--------------------------------------------------------------------------
    // Start edge detect
    //--------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) start_d <= 1'b0;
        else        start_d <= start;
    end
    assign start_pulse = start & ~start_d;

    //--------------------------------------------------------------------------
    // State + counters
    //--------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            run_cnt   <= 16'd0;
            stage_reg <= '0;
        end else begin
            state <= next_state;

            if (state == S_LOAD) begin
                // Start full FFT at stage 0 after load
                stage_reg <= '0;
                run_cnt   <= 16'd0;
            end else if (state == S_RUN) begin
                // Count cycles within a stage window
                if (run_cnt == (CORE_CYCLES-1)) begin
                    run_cnt <= 16'd0;

                    // Advance stage at end of this stage window
                    if (AUTO_STAGE && (stage_reg != (LOGN-1)))
                        stage_reg <= stage_reg + 1'b1;
                end else begin
                    run_cnt <= run_cnt + 16'd1;
                end
            end else begin
                run_cnt <= 16'd0;
            end
        end
    end

    //--------------------------------------------------------------------------
    // Next state + controls
    //--------------------------------------------------------------------------
    always_comb begin
        next_state = state;
        load_en    = 1'b0;
        run_en     = 1'b0;
        done       = 1'b0;

        unique case (state)
            S_IDLE: begin
                if (start_pulse)
                    next_state = S_LOAD;
            end

            S_LOAD: begin
                load_en    = 1'b1;     // one-cycle load
                next_state = S_RUN;
            end

            S_RUN: begin
                run_en = 1'b1;
                // If AUTO_STAGE, finish after last stage window completes.
                // Otherwise, legacy behavior: single stage run for CORE_CYCLES.
                if (run_cnt == (CORE_CYCLES-1)) begin
                    if (AUTO_STAGE) begin
                        if (stage_reg == (LOGN-1))
                            next_state = S_DONE;
                        else
                            next_state = S_RUN;
                    end else begin
                        next_state = S_DONE;
                    end
                end
            end

            S_DONE: begin
                done       = 1'b1;     // one cycle done pulse
                next_state = S_IDLE;
            end

            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    // Effective stage used by datapath
    always_comb begin
        stage_eff = AUTO_STAGE ? stage_reg : stage;
    end

    // One-cycle pulse to the core at the start of each stage window.
    // This prevents asserting in_valid for multiple cycles (which would re-run butterflies).
    assign core_start = (state == S_RUN) && (run_cnt == 16'd0);

    //--------------------------------------------------------------------------
    // Twiddle ROM addressing (DIT)
    // k = (j) * (N / 2^(stage+1))
    // With:
    //   group_size = 2^stage
    //   stride     = N / 2^(stage+1)
    //   j          = (butterfly_index % group_size)
    //--------------------------------------------------------------------------
    integer t;
    integer stride;
    integer group_size;

    always_comb begin
        for (t = 0; t < N_BFLY; t++) begin
            waddr[t] = '0;
        end

        if (stage_eff < LOGN) begin
            group_size = 1 << stage_eff;
            stride     = N >> (stage_eff + 1);

            for (t = 0; t < N_BFLY; t++) begin
                waddr[t] = (t % group_size) * stride;
            end
        end
    end

    //--------------------------------------------------------------------------
    // Twiddle ROM
    //--------------------------------------------------------------------------
    twiddle_rom #(
        .N       (N),
        .NREAD   (N_BFLY),
        .MEMFILE (TW_FILE)
    ) TWIDDLE_ROM (
        .waddr (waddr),
        .wout  (tw)
    );

    //--------------------------------------------------------------------------
    // DIT permutation between RAM and adjacent-pair core
    // Compute true DIT (a_idx, b_idx) and map them to adjacent lanes (2*i, 2*i+1)
    //--------------------------------------------------------------------------
    integer i;
    always_comb begin
        // default
        for (i = 0; i < N; i++) begin
            core_x_out[i] = 32'd0;
        end

        if (stage_eff < LOGN) begin
            int half;
            int m;
            half = 1 << stage_eff;
            m    = half << 1;

            for (i = 0; i < N_BFLY; i++) begin
                int group;
                int j;
                int a_idx;
                int b_idx;

                group = i / half;
                j     = i % half;
                a_idx = group*m + j;
                b_idx = a_idx + half;

                core_x_out[2*i]   = x_out[a_idx];
                core_x_out[2*i+1] = x_out[b_idx];
            end
        end
    end

    //--------------------------------------------------------------------------
    // RAM write data mapping
    // - LOAD: write fft_data_in into RAM in one cycle
    // - RUN : write core outputs back into the true DIT indices (a_idx/b_idx)
    //--------------------------------------------------------------------------
    integer k;
    always_comb begin
        // defaults
        for (k = 0; k < N; k++) begin
            ram_wdata[k] = 32'd0;
            ram_we[k]    = 1'b0;
        end

        if (load_en) begin
            // lane 0 at MSB to match your original convention
            for (k = 0; k < N; k++) begin
                ram_wdata[k] = fft_data_in[((N-1-k)*32) +: 32];
                ram_we[k]    = 1'b1;
            end
        end
        else if (run_en && (stage_eff < LOGN)) begin
            int half;
            int m;
            half = 1 << stage_eff;
            m    = half << 1;

            for (k = 0; k < N_BFLY; k++) begin
                int group;
                int j;
                int a_idx;
                int b_idx;

                group = k / half;
                j     = k % half;
                a_idx = group*m + j;
                b_idx = a_idx + half;

                // core lanes are adjacent: 2*k and 2*k+1
                ram_wdata[a_idx] = core_x_in[2*k];
                ram_we[a_idx]    = core_x_we[2*k];

                ram_wdata[b_idx] = core_x_in[2*k+1];
                ram_we[b_idx]    = core_x_we[2*k+1];
            end
        end
    end

    //--------------------------------------------------------------------------
    // FFT Stage Core (adjacent lanes)
    //--------------------------------------------------------------------------
    fft_stage_core #(
        .N (N)
    ) CORE (
        .clk    (clk),
        .rst_n  (rst_n),
        .start  (core_start),
        .stage  (stage_eff),

        .x_out  (core_x_out),
        .x_in   (core_x_in),
        .x_we   (core_x_we),

        .tw_out (tw)
    );

    //--------------------------------------------------------------------------
    // RAM
    //--------------------------------------------------------------------------
    fft_ram_nx32 #(
        .N (N)
    ) RAM (
        .clk   (clk),
        .rst_n (rst_n),
        .x_we  (ram_we),
        .x_in  (ram_wdata),
        .x_out (x_out)
    );

    //--------------------------------------------------------------------------
    // Output packing
    // IMPORTANT: pack from RAM contents (x_out), not from core_x_in
    // This represents the stored state after all writebacks.
    // lane0 at MSB to match original convention
    //--------------------------------------------------------------------------
    genvar gi;
    generate
        for (gi = 0; gi < N; gi++) begin : GEN_PACK
            localparam int HI = (N-1-gi)*32 + 31;
            localparam int LO = (N-1-gi)*32;
            assign fft_data_out[HI:LO] = x_out[gi];
        end
    endgenerate

endmodule
