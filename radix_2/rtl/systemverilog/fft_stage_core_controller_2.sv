module fft_stage_core_controller #(
    parameter int N           = 16,   // fixed here for 8 lanes (must be even)
    parameter int CORE_CYCLES  = 2,   // stage core latency in cycles
    parameter bit AUTO_STAGE   = 1'b1, // 1: run full FFT (stage 0..log2(N)-1) per start
    parameter string TW_FILE   = "twiddle16.mem" // twiddle ROM init file
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
    logic [STW-1:0]          stage_reg;
    logic [3:0]              stage_eff;

    // start rising edge detect (prevents re-trigger while start is held high)
    logic start_d;
    wire  start_pulse;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) start_d <= 1'b0;
        else        start_d <= start;
    end
    assign start_pulse = start & ~start_d;

    // state + counters
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= S_IDLE;
            run_cnt <= 16'd0;
            stage_reg <= '0;
        end else begin
            state <= next_state;

            if (state == S_LOAD) begin
                // start full FFT at stage 0 after load
                stage_reg <= '0;
                run_cnt   <= 16'd0;
            end else if (state == S_RUN) begin
                // count cycles within a stage window
                if (run_cnt == (CORE_CYCLES-1)) begin
                    run_cnt <= 16'd0;
                    // advance stage at end of this stage window
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

    // next state + outputs
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
                // Otherwise, keep legacy behavior: single stage run for CORE_CYCLES.
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

    // effective stage used by datapath
    always_comb begin
        stage_eff = AUTO_STAGE ? stage_reg : stage;
    end

    //--------------------------------------------------------------------------
    // Internal datapath arrays
    //--------------------------------------------------------------------------
    logic [31:0] x_out     [0:N-1];   // RAM -> core
    logic [31:0] core_x_in [0:N-1];   // core -> (mux) -> RAM
    logic [31:0] ram_x_in  [0:N-1];   // muxed write data -> RAM

    logic [N-1:0] core_x_we;
    logic [N-1:0] ram_x_we;

    // Twiddles: N/2 butterflies
    localparam int N_BFLY  = N/2;
    localparam int NREAD   = N_BFLY;

    logic [$clog2(N)-1:0] waddr [0:NREAD-1];
    logic signed [31:0]   tw    [0:NREAD-1];

    //--------------------------------------------------------------------------
    // Unpack fft_data_in into an array: lane 0 at top bits to match your original
    // Original mapping:
    //   din0 = [255:224], ..., din7 = [31:0]
    // We'll keep that convention.
    //--------------------------------------------------------------------------
    genvar gi;
    generate
        for (gi = 0; gi < N; gi++) begin : GEN_UNPACK
            // lane gi takes chunk from MSB downward
            // base index from top: (N-1-gi)
            localparam int HI = (N-1-gi)*32 + 31;
            localparam int LO = (N-1-gi)*32;
            wire [31:0] din_lane = fft_data_in[HI:LO];

            // RAM input mux (LOAD vs RUN)
            always_comb begin
                ram_x_in[gi] = load_en ? din_lane : core_x_in[gi];
            end
        end
    endgenerate

    // write-enable mux
    always_comb begin
        if (load_en)      ram_x_we = {N{1'b1}};  // write all lanes
        else if (run_en)  ram_x_we = core_x_we;  // core writeback
        else              ram_x_we = {N{1'b0}};
    end

    //--------------------------------------------------------------------------
    // Twiddle ROM addressing
    // NOTE: your original used 4 ports. Here we generalize to N/2 ports.
    // For N=8 => 4 ports, same as before.
    //--------------------------------------------------------------------------
    integer t;
    integer stride;
    integer group_size;
    
    always_comb begin
        // defaults
        for (t = 0; t < NREAD; t++) begin
            waddr[t] = '0;
        end
    
        // guard against invalid stages
        if (stage_eff < LOGN) begin
            group_size = 1 << stage_eff;           // butterflies per twiddle group
            stride     = N >> (stage_eff + 1);     // twiddle spacing
    
            for (t = 0; t < NREAD; t++) begin
                waddr[t] = (t % group_size) * stride;
            end
        end
    end

    //--------------------------------------------------------------------------
    // Twiddle ROM (array ports)
    //--------------------------------------------------------------------------
    twiddle_rom #(
        .N       (N),
        .NREAD   (NREAD),
        .MEMFILE (TW_FILE)
    ) TWIDDLE_ROM (
        .waddr (waddr),
        .wout  (tw)
    );

    //--------------------------------------------------------------------------
    // FFT Stage Core (array ports)
    // start asserted during RUN (run_en)
    //--------------------------------------------------------------------------
    fft_stage_core #(
        .N (N)
    ) CORE (
        .clk    (clk),
        .rst_n  (rst_n),
        .start  (run_en),
        .stage  (stage_eff),

        .x_out  (x_out),
        .x_in   (core_x_in),
        .x_we   (core_x_we),

        .tw_out (tw)
    );

    //--------------------------------------------------------------------------
    // RAM (array ports)
    //--------------------------------------------------------------------------
    fft_ram_nx32 #(
        .N (N)
    ) RAM (
        .clk   (clk),
        .rst_n (rst_n),
        .x_we  (ram_x_we),
        .x_in  (ram_x_in),
        .x_out (x_out)
    );

    //--------------------------------------------------------------------------
    // Output packing
    // Your old fft_data_out was: {core_x_in_0, core_x_in_1, ... core_x_in_7}
    // We'll keep that ordering (lane0 at MSB).
    //--------------------------------------------------------------------------
    generate
        for (gi = 0; gi < N; gi++) begin : GEN_PACK
            localparam int HI = (N-1-gi)*32 + 31;
            localparam int LO = (N-1-gi)*32;
            always_comb begin
                fft_data_out[HI:LO] = core_x_in[gi];
            end
        end
    endgenerate

endmodule