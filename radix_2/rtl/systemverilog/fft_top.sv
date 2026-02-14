module fft_top #(
    parameter int N           = 16,
    parameter int CORE_CYCLES = 2,
    parameter string TW_FILE  = "twiddle16.mem"
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             start,         // one pulse triggers FULL FFT (all stages)
    input  logic [N*32-1:0]  fft_data_in,
    output logic [N*32-1:0]  fft_data_out,
    output logic             done
);

    localparam int LOGN = $clog2(N);
    localparam int STW  = (LOGN <= 1) ? 1 : $clog2(LOGN);
    localparam GROUND  = 1'b0;
    // start edge detect (top-level)
    logic start_d;
    logic start_pulse;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) start_d <= 1'b0;
        else        start_d <= start;
    end
    assign start_pulse = start & ~start_d;

    // ------------------------------------------------------------
    // FSM for stage sequencing
    // ------------------------------------------------------------
    typedef enum logic [2:0] {
        T_IDLE,
        T_LAUNCH,    // issue 1-cycle start to inner
        T_WAIT,      // wait for inner done
        T_NEXT,      // advance stage / update data
        T_DONE
    } tstate_t;

    tstate_t tstate, tnext;

    // stage index (0..LOGN-1)
    logic [STW-1:0] stage_reg;

    // data that feeds the inner controller
    logic [N*32-1:0] in_buf;
    logic [N*32-1:0] out_buf;

    // handshake to inner controller
    logic inner_start;
    logic inner_done;

    // ------------------------------------------------------------
    // Inner controller runs ONE stage only (AUTO_STAGE=0)
    // ------------------------------------------------------------
    logic [3:0] stage_to_inner;
    assign stage_to_inner = stage_reg;  // zero-extends automatically

    fft_stage_core_controller #(
        .N(N),
        .CORE_CYCLES(CORE_CYCLES),
        .AUTO_STAGE(1'b0),
        .TW_FILE(TW_FILE)
    ) u_stage_ctrl (
        .clk         (clk),
        .rst_n       (rst_n),
        .start       (inner_start),
        .stage       (stage_to_inner),
        .fft_data_in (in_buf),
        .fft_data_out(out_buf),
        .done        (inner_done)
    );

   
    // ------------------------------------------------------------
    // Sequential: state, stage, buffers
    // ------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tstate     <= T_IDLE;
            stage_reg  <= '0;
            in_buf     <= '0;
            fft_data_out <= '0;
        end else begin
            tstate <= tnext;

            // capture initial input at start of full FFT
            if (tstate == T_IDLE && start_pulse) begin
                in_buf    <= fft_data_in;
                stage_reg <= '0;
            end

            // when inner finishes a stage, latch its output as next stage input
            if (tstate == T_WAIT && inner_done) begin
                in_buf <= out_buf; // feed next stage
            end

            // when fully done, publish final output
            if (tstate == T_DONE) begin
                fft_data_out <= in_buf; // in_buf holds last stage output
            end

            // advance stage after a stage completes
            if (tstate == T_NEXT) begin
                if (stage_reg != (LOGN-1))
                    stage_reg <= stage_reg + 1'b1;
            end
        end
    end

    // ------------------------------------------------------------
    // Combinational: next-state + outputs
    // ------------------------------------------------------------
    always_comb begin
        tnext       = tstate;
        inner_start = 1'b0;
        done        = 1'b0;

        unique case (tstate)
            T_IDLE: begin
                if (start_pulse)
                    tnext = T_LAUNCH;
            end

            // pulse inner_start for exactly 1 cycle
            T_LAUNCH: begin
                inner_start = 1'b1;
                tnext       = T_WAIT;
            end

            // wait for the inner controller to finish this stage
            T_WAIT: begin
                if (inner_done)
                    tnext = T_NEXT;
            end

            // decide whether to run next stage or finish
            T_NEXT: begin
                if (stage_reg == (LOGN-1))
                    tnext = T_DONE;
                else
                    tnext = T_LAUNCH;
            end

            T_DONE: begin
                done  = 1'b1;     // 1-cycle pulse
                tnext = T_IDLE;
            end

            default: tnext = T_IDLE;
        endcase
    end

endmodule
