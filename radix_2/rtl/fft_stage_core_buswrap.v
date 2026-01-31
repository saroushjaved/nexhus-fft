module fft_stage_core_controller #(
    parameter integer N          = 8,       // fixed here for 8 lanes
    parameter integer CORE_CYCLES = 2      // adjust to your fft_stage_core stage latency
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               start,
    input  wire [3:0]         stage,        // external stage select (0..2 for N=8)
    input  wire [N*32-1:0]    fft_data_in,
    output  wire [N*32-1:0]    fft_data_out,
    output reg                done
);

    //--------------------------------------------------------------------------
    // FSM (Verilog style)
    //--------------------------------------------------------------------------
    localparam [1:0] S_IDLE = 2'b00;
    localparam [1:0] S_LOAD = 2'b01;
    localparam [1:0] S_RUN  = 2'b10;
    localparam [1:0] S_DONE = 2'b11;

    reg [1:0] state, next_state;

    reg load_en;
    reg run_en;

    // counter for RUN phase
    reg [15:0] run_cnt;


        reg start_d;
        wire start_pulse;
        
        always @(posedge clk or negedge rst_n) begin
          if (!rst_n) start_d <= 1'b0;
          else       start_d <= start;
        end
        
        assign start_pulse = start & ~start_d;  // rising edge
    // sequential state + counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= S_IDLE;
            run_cnt <= 16'd0;
        end else begin
            state <= next_state;

            // run counter only in RUN
            if (state == S_RUN) begin
                if (run_cnt != (CORE_CYCLES-1))
                    run_cnt <= run_cnt + 16'd1;
            end else begin
                run_cnt <= 16'd0;
            end
        end
    end

    // combinational next state + controls
    always @(*) begin
        next_state = state;
        load_en    = 1'b0;
        run_en     = 1'b0;
        done       = 1'b0;

        case (state)
            S_IDLE: begin
             if (start_pulse)
                next_state = S_LOAD;
            end

            S_LOAD: begin
                // one-cycle parallel load of all 8 entries
                load_en    = 1'b1;
                next_state = S_RUN;
            end

           S_RUN: begin
                    run_en = 1'b1;
                    if (run_cnt == (CORE_CYCLES-1))
                        next_state = S_DONE;
                    else
                        next_state = S_RUN;
                    end
            S_DONE: begin
                done       = 1'b1;  // done for 1 cycle
                next_state = S_IDLE;
            end

            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    //--------------------------------------------------------------------------
    // Twiddle ROM addressing (for N=8, stages 0..2)
    //--------------------------------------------------------------------------
    reg  [2:0] waddr_0, waddr_1, waddr_2, waddr_3;
    wire signed [31:0] wout_0, wout_1, wout_2, wout_3;

    always @(*) begin
        // defaults
        waddr_0 = 3'd0;
        waddr_1 = 3'd0;
        waddr_2 = 3'd0;
        waddr_3 = 3'd0;

        case (stage)
            4'd0: begin
                // stage 0: all twiddles = W0
                waddr_0 = 3'd0; waddr_1 = 3'd0;
                waddr_2 = 3'd0; waddr_3 = 3'd0;
            end

            4'd1: begin
                // stage 1: example pattern for 4 butterflies
                waddr_0 = 3'd0; waddr_1 = 3'd2;
                waddr_2 = 3'd0; waddr_3 = 3'd2;
            end

            4'd2: begin
                // stage 2: twiddles 0,1,2,3
                waddr_0 = 3'd0; waddr_1 = 3'd1;
                waddr_2 = 3'd2; waddr_3 = 3'd3;
            end

            default: begin
                waddr_0 = 3'd0; waddr_1 = 3'd0;
                waddr_2 = 3'd0; waddr_3 = 3'd0;
            end
        endcase
    end

    twiddle_rom TWIDDLE_ROM (
        .waddr_0 (waddr_0),
        .waddr_1 (waddr_1),
        .waddr_2 (waddr_2),
        .waddr_3 (waddr_3),

        .wout_0  (wout_0),
        .wout_1  (wout_1),
        .wout_2  (wout_2),
        .wout_3  (wout_3)
    );

    //--------------------------------------------------------------------------
    // RAM outputs (read side) -> core inputs
    //--------------------------------------------------------------------------
    wire [31:0] x_out_0, x_out_1, x_out_2, x_out_3;
    wire [31:0] x_out_4, x_out_5, x_out_6, x_out_7;

    //--------------------------------------------------------------------------
    // Core writeback (computed) wires
    //--------------------------------------------------------------------------
    wire [31:0] core_x_in_0, core_x_in_1, core_x_in_2, core_x_in_3;
    wire [31:0] core_x_in_4, core_x_in_5, core_x_in_6, core_x_in_7;
    wire [7:0]  core_x_we;

    //--------------------------------------------------------------------------
    // RAM write port wires (muxed between LOAD and RUN)
    //--------------------------------------------------------------------------
    wire [31:0] ram_x_in_0, ram_x_in_1, ram_x_in_2, ram_x_in_3;
    wire [31:0] ram_x_in_4, ram_x_in_5, ram_x_in_6, ram_x_in_7;
    wire [7:0]  ram_x_we;

    // unpack fft_data_in (N=8)
    wire [31:0] din0 = fft_data_in[255:224];
    wire [31:0] din1 = fft_data_in[223:192];
    wire [31:0] din2 = fft_data_in[191:160];
    wire [31:0] din3 = fft_data_in[159:128];
    wire [31:0] din4 = fft_data_in[127: 96];
    wire [31:0] din5 = fft_data_in[ 95: 64];
    wire [31:0] din6 = fft_data_in[ 63: 32];
    wire [31:0] din7 = fft_data_in[ 31:  0];

    // RAM data mux: load_en selects external inputs, else core writeback
    assign ram_x_in_0 = load_en ? din0 : core_x_in_0;
    assign ram_x_in_1 = load_en ? din1 : core_x_in_1;
    assign ram_x_in_2 = load_en ? din2 : core_x_in_2;
    assign ram_x_in_3 = load_en ? din3 : core_x_in_3;
    assign ram_x_in_4 = load_en ? din4 : core_x_in_4;
    assign ram_x_in_5 = load_en ? din5 : core_x_in_5;
    assign ram_x_in_6 = load_en ? din6 : core_x_in_6;
    assign ram_x_in_7 = load_en ? din7 : core_x_in_7;

    // RAM write-enable mux:
    // - during load: write all 8 entries in 1 cycle
    // - during run : core decides which lanes write
    // - else       : no writes
    assign ram_x_we = load_en ? 8'hFF :
                      run_en  ? core_x_we :
                               8'h00;

    //--------------------------------------------------------------------------
    // FFT Stage Core
    // - Start only when RUN is active (run_en)
    // - Reads x_out_* from RAM, writes core_x_in_* back to RAM via mux
    //--------------------------------------------------------------------------
    fft_stage_core I_4x16BF_Core (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (run_en),
        .stage    (stage),

        .x_out_0  (x_out_0),
        .x_out_1  (x_out_1),
        .x_out_2  (x_out_2),
        .x_out_3  (x_out_3),
        .x_out_4  (x_out_4),
        .x_out_5  (x_out_5),
        .x_out_6  (x_out_6),
        .x_out_7  (x_out_7),

        .x_in_0   (core_x_in_0),
        .x_in_1   (core_x_in_1),
        .x_in_2   (core_x_in_2),
        .x_in_3   (core_x_in_3),
        .x_in_4   (core_x_in_4),
        .x_in_5   (core_x_in_5),
        .x_in_6   (core_x_in_6),
        .x_in_7   (core_x_in_7),

        .x_we     (core_x_we),

        .tw_out_0 (wout_0),
        .tw_out_1 (wout_1),
        .tw_out_2 (wout_2),
        .tw_out_3 (wout_3)
    );

    
    //--------------------------------------------------------------------------
    // RAM
    //--------------------------------------------------------------------------
    fft_ram_8x32 RAM (
        .clk     (clk),
        .rst_n   (rst_n),

        .x_we    (ram_x_we),

        .x_in_0  (ram_x_in_0),
        .x_in_1  (ram_x_in_1),
        .x_in_2  (ram_x_in_2),
        .x_in_3  (ram_x_in_3),
        .x_in_4  (ram_x_in_4),
        .x_in_5  (ram_x_in_5),
        .x_in_6  (ram_x_in_6),
        .x_in_7  (ram_x_in_7),

        .x_out_0 (x_out_0),
        .x_out_1 (x_out_1),
        .x_out_2 (x_out_2),
        .x_out_3 (x_out_3),
        .x_out_4 (x_out_4),
        .x_out_5 (x_out_5),
        .x_out_6 (x_out_6),
        .x_out_7 (x_out_7)
    );

    assign fft_data_out = {core_x_in_0, core_x_in_1, core_x_in_2, core_x_in_3, core_x_in_4, core_x_in_5,core_x_in_6,core_x_in_7 };
    
endmodule