module top_fft_64 (
    input  wire               clk,
    input  wire               rst_n,

    input  wire               start,
    output reg                busy,
    output reg                done,

    input  wire               in_valid,
    input  wire signed [15:0] in_real,
    input  wire signed [15:0] in_imag
);
    localparam integer N  = 64;
    localparam integer BW = 32;

    // -----------------------------
    // X-bank instance (this IS the RAM)
    // -----------------------------
    wire [N*32-1:0] x_out_bus;

    reg  [N*32-1:0] x_in_bus_mux;
    reg  [N-1:0]    x_we_mux;

    x_bank_64x32_bus u_xbank (
        .clk      (clk),
        .rst_n    (rst_n),
        .x_in_bus (x_in_bus_mux),
        .x_we     (x_we_mux),
        .x_out_bus(x_out_bus)
    );

    // -----------------------------
    // Twiddle bank
    // -----------------------------
    wire [BW*5-1:0]  tw_addr_bus;
    wire [BW*32-1:0] tw_out_bus;

    twiddle_bank_64_wrapper u_tw (
        .tw_addr_bus(tw_addr_bus),
        .tw_out_bus (tw_out_bus)
    );

    // -----------------------------
    // Stage core
    // -----------------------------
    reg        sc_start;
    reg [3:0]  sc_stage;

    wire [N*32-1:0] sc_x_in_bus;
    wire [N-1:0]    sc_x_we;

    fft_stage_core_buswrap #(.BW(BW), .N(N)) u_stage (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (sc_start),
        .stage      (sc_stage),

        .x_out_bus  (x_out_bus),
        .x_in_bus   (sc_x_in_bus),
        .x_we       (sc_x_we),

        .tw_addr_bus(tw_addr_bus),
        .tw_out_bus (tw_out_bus)
    );

    // -----------------------------
    // Input loader (writes x[0..63])
    // -----------------------------
    reg [5:0] load_idx;

    // build loader write buses
    reg [N*32-1:0] ld_x_in_bus;
    reg [N-1:0]    ld_x_we;

    integer i;
    always @(*) begin
        ld_x_in_bus = x_out_bus;      // default hold
        ld_x_we     = {N{1'b0}};

        if (in_valid) begin
            ld_x_in_bus[load_idx*32 +: 32] = {in_real, in_imag};
            ld_x_we[load_idx] = 1'b1;
        end
    end

    // -----------------------------
    // Controller: LOAD 64 -> RUN 6 stages
    // Need 2 cycles per stage because fft_atomic_p1 is 1-cycle pipelined
    // -----------------------------
    localparam S_IDLE = 2'd0;
    localparam S_LOAD = 2'd1;
    localparam S_EXEC = 2'd2;
    localparam S_DONE = 2'd3;

    reg [1:0] state;
    reg [3:0] stage_idx;
    reg       phase; // 0=launch, 1=commit

    always @(posedge clk) begin
        if (!rst_n) begin
            state    <= S_IDLE;
            busy     <= 1'b0;
            done     <= 1'b0;

            load_idx <= 6'd0;
            stage_idx<= 4'd0;
            phase    <= 1'b0;

            sc_start <= 1'b0;
            sc_stage <= 4'd0;
        end else begin
            done     <= 1'b0;
            sc_start <= 1'b0;

            case (state)
                S_IDLE: begin
                    busy <= 1'b0;
                    if (start) begin
                        busy     <= 1'b1;
                        load_idx <= 6'd0;
                        state    <= S_LOAD;
                    end
                end

                S_LOAD: begin
                    // mux loader into x-bank
                    if (in_valid) begin
                        if (load_idx == 6'd63) begin
                            stage_idx <= 4'd0;
                            phase     <= 1'b0;
                            state     <= S_EXEC;
                        end
                        load_idx <= load_idx + 6'd1;
                    end
                end

                S_EXEC: begin
                    sc_stage <= stage_idx;

                    if (phase == 1'b0) begin
                        // launch stage (feeds butterflies)
                        sc_start <= 1'b1;
                        phase    <= 1'b1;
                    end else begin
                        // commit cycle happens via sc_x_we/sc_x_in_bus
                        phase <= 1'b0;

                        if (stage_idx == 4'd5) begin
                            state <= S_DONE;
                        end else begin
                            stage_idx <= stage_idx + 4'd1;
                        end
                    end
                end

                S_DONE: begin
                    done  <= 1'b1;
                    busy  <= 1'b0;
                    state <= S_IDLE;
                end
            endcase
        end
    end

    // -----------------------------
    // Write mux into x-bank
    // During LOAD: loader drives writes
    // During EXEC: stage core drives writes
    // -----------------------------
    always @(*) begin
        if (state == S_LOAD) begin
            x_in_bus_mux = ld_x_in_bus;
            x_we_mux     = ld_x_we;
        end else begin
            x_in_bus_mux = sc_x_in_bus;
            x_we_mux     = sc_x_we;
        end
    end

endmodule