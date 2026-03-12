`timescale 1ns/1ps

module fft_axi_wrapper #(
    parameter int N            = 1024,
    parameter int AXI_ADDR_W   = 16,
    parameter int AXI_DATA_W   = 32,
    parameter int AXI_ID_W     = 4,
    parameter int CORE_CYCLES  = 2,
    parameter string TW_FILE   = "twiddle1024.mem"
)(
    input  logic                     ACLK,
    input  logic                     ARESETn,

    //==============================
    // AXI4 slave write address channel
    //==============================
    input  logic [AXI_ID_W-1:0]      S_AXI_AWID,
    input  logic [AXI_ADDR_W-1:0]    S_AXI_AWADDR,
    input  logic [7:0]               S_AXI_AWLEN,
    input  logic [2:0]               S_AXI_AWSIZE,
    input  logic [1:0]               S_AXI_AWBURST,
    input  logic                     S_AXI_AWVALID,
    output logic                     S_AXI_AWREADY,

    //==============================
    // AXI4 slave write data channel
    //==============================
    input  logic [AXI_DATA_W-1:0]    S_AXI_WDATA,
    input  logic [AXI_DATA_W/8-1:0]  S_AXI_WSTRB,
    input  logic                     S_AXI_WLAST,
    input  logic                     S_AXI_WVALID,
    output logic                     S_AXI_WREADY,

    //==============================
    // AXI4 slave write response channel
    //==============================
    output logic [AXI_ID_W-1:0]      S_AXI_BID,
    output logic [1:0]               S_AXI_BRESP,
    output logic                     S_AXI_BVALID,
    input  logic                     S_AXI_BREADY,

    //==============================
    // AXI4 slave read address channel
    //==============================
    input  logic [AXI_ID_W-1:0]      S_AXI_ARID,
    input  logic [AXI_ADDR_W-1:0]    S_AXI_ARADDR,
    input  logic [7:0]               S_AXI_ARLEN,
    input  logic [2:0]               S_AXI_ARSIZE,
    input  logic [1:0]               S_AXI_ARBURST,
    input  logic                     S_AXI_ARVALID,
    output logic                     S_AXI_ARREADY,

    //==============================
    // AXI4 slave read data channel
    //==============================
    output logic [AXI_ID_W-1:0]      S_AXI_RID,
    output logic [AXI_DATA_W-1:0]    S_AXI_RDATA,
    output logic [1:0]               S_AXI_RRESP,
    output logic                     S_AXI_RLAST,
    output logic                     S_AXI_RVALID,
    input  logic                     S_AXI_RREADY,

    // Optional interrupt
    output logic                     irq
);

    // --------------------------------------------------------------------
    // Local parameters
    // --------------------------------------------------------------------
    localparam int WORD_BYTES = AXI_DATA_W / 8;

    localparam logic [AXI_ADDR_W-1:0] CTRL_ADDR   = 'h0000;
    localparam logic [AXI_ADDR_W-1:0] STATUS_ADDR = 'h0004;
    localparam logic [AXI_ADDR_W-1:0] IN_BASE     = 'h1000;
    localparam logic [AXI_ADDR_W-1:0] OUT_BASE    = 'h2000;

    localparam logic [AXI_ADDR_W-1:0] IN_LAST     = IN_BASE  + (N*4) - 4;
    localparam logic [AXI_ADDR_W-1:0] OUT_LAST    = OUT_BASE + (N*4) - 4;

    localparam logic [1:0] AXI_RESP_OKAY   = 2'b00;
    localparam logic [1:0] AXI_RESP_SLVERR = 2'b10;

    // --------------------------------------------------------------------
    // Buffers
    // --------------------------------------------------------------------
    logic [31:0] in_buf  [0:N-1];
    logic [31:0] out_buf [0:N-1];

    // --------------------------------------------------------------------
    // FFT interface
    // --------------------------------------------------------------------
    logic            fft_start;
    logic            fft_done_core;
    logic [N*32-1:0] fft_data_in_bus;
    logic [N*32-1:0] fft_data_out_bus;

    logic            fft_busy;
    logic            fft_done_sticky;
    logic            capture_pending;

    assign irq = fft_done_sticky;

    genvar gi;
    generate
        for (gi = 0; gi < N; gi++) begin : GEN_PACK_IN
            assign fft_data_in_bus[gi*32 +: 32] = in_buf[gi];
        end
    endgenerate

    fft_top #(
        .N           (N),
        .CORE_CYCLES (CORE_CYCLES),
        .TW_FILE     (TW_FILE)
    ) u_fft_top (
        .clk         (ACLK),
        .rst_n       (ARESETn),
        .start       (fft_start),
        .fft_data_in (fft_data_in_bus),
        .fft_data_out(fft_data_out_bus),
        .done        (fft_done_core)
    );

    // --------------------------------------------------------------------
    // Helper functions
    // --------------------------------------------------------------------
    function automatic logic [31:0] apply_wstrb32(
        input logic [31:0] oldv,
        input logic [31:0] newv,
        input logic [3:0]  wstrb
    );
        logic [31:0] tmp;
        begin
            tmp = oldv;
            if (wstrb[0]) tmp[7:0]   = newv[7:0];
            if (wstrb[1]) tmp[15:8]  = newv[15:8];
            if (wstrb[2]) tmp[23:16] = newv[23:16];
            if (wstrb[3]) tmp[31:24] = newv[31:24];
            apply_wstrb32 = tmp;
        end
    endfunction

    function automatic logic [AXI_ADDR_W-1:0] next_axi_addr(
        input logic [AXI_ADDR_W-1:0] addr,
        input logic [2:0]            size,
        input logic [1:0]            burst
    );
        logic [AXI_ADDR_W-1:0] incr;
        begin
            incr = '0;
            incr = ({{(AXI_ADDR_W-1){1'b0}}, 1'b1} << size);

            case (burst)
                2'b00: next_axi_addr = addr;        // FIXED
                2'b01: next_axi_addr = addr + incr; // INCR
                default: next_axi_addr = addr;      // WRAP unsupported
            endcase
        end
    endfunction

    function automatic logic addr_is_valid_word(
        input logic [AXI_ADDR_W-1:0] addr
    );
        begin
            addr_is_valid_word =
                (addr == CTRL_ADDR)   ||
                (addr == STATUS_ADDR) ||
                ((addr >= IN_BASE)  && (addr <= IN_LAST)) ||
                ((addr >= OUT_BASE) && (addr <= OUT_LAST));
        end
    endfunction

    function automatic logic [31:0] axi_read_word(
        input logic [AXI_ADDR_W-1:0] addr
    );
        integer idx;
        begin
            axi_read_word = 32'h0000_0000;

            if (addr == CTRL_ADDR) begin
                axi_read_word = 32'h0000_0000;
            end
            else if (addr == STATUS_ADDR) begin
                axi_read_word = {30'd0, fft_busy, fft_done_sticky};
            end
            else if ((addr >= IN_BASE) && (addr <= IN_LAST)) begin
                idx = (addr - IN_BASE) >> 2;
                axi_read_word = in_buf[idx];
            end
            else if ((addr >= OUT_BASE) && (addr <= OUT_LAST)) begin
                idx = (addr - OUT_BASE) >> 2;
                axi_read_word = out_buf[idx];
            end
            else begin
                axi_read_word = 32'hDEAD_BEEF;
            end
        end
    endfunction

    // --------------------------------------------------------------------
    // FFT control
    // --------------------------------------------------------------------
    logic start_req_pulse;
    integer k;

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            fft_start       <= 1'b0;
            fft_busy        <= 1'b0;
            fft_done_sticky <= 1'b0;
            capture_pending <= 1'b0;
            for (k = 0; k < N; k++) begin
                out_buf[k] <= 32'd0;
            end
        end
        else begin
            fft_start <= 1'b0;

            if (start_req_pulse && !fft_busy) begin
                fft_start       <= 1'b1;
                fft_busy        <= 1'b1;
                fft_done_sticky <= 1'b0;
            end

            if (fft_done_core) begin
                capture_pending <= 1'b1;
            end

            if (capture_pending) begin
                capture_pending <= 1'b0;
                fft_busy        <= 1'b0;
                fft_done_sticky <= 1'b1;
                for (k = 0; k < N; k++) begin
                    out_buf[k] <= fft_data_out_bus[k*32 +: 32];
                end
            end
        end
    end

    // --------------------------------------------------------------------
    // Write channel state
    // --------------------------------------------------------------------
    logic [AXI_ID_W-1:0]   wr_id;
    logic [AXI_ADDR_W-1:0] wr_addr;
    logic [AXI_ADDR_W-1:0] wr_next_addr;
    logic [7:0]            wr_beats_left;
    logic [2:0]            wr_size;
    logic [1:0]            wr_burst;
    logic                  wr_active;
    logic [1:0]            wr_resp_accum;

    logic                  ctrl_start_req;
    logic                  status_clear_req;

    assign start_req_pulse = ctrl_start_req;
    assign wr_next_addr    = next_axi_addr(wr_addr, wr_size, wr_burst);

    wire aw_hs = S_AXI_AWVALID && S_AXI_AWREADY;
    wire w_hs  = S_AXI_WVALID  && S_AXI_WREADY;
    wire b_hs  = S_AXI_BVALID  && S_AXI_BREADY;

    integer widx;

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            S_AXI_AWREADY    <= 1'b1;
            S_AXI_WREADY     <= 1'b0;
            S_AXI_BVALID     <= 1'b0;
            S_AXI_BRESP      <= AXI_RESP_OKAY;
            S_AXI_BID        <= '0;

            wr_id            <= '0;
            wr_addr          <= '0;
            wr_beats_left    <= '0;
            wr_size          <= 3'd0;
            wr_burst         <= 2'b01;
            wr_active        <= 1'b0;
            wr_resp_accum    <= AXI_RESP_OKAY;

            ctrl_start_req   <= 1'b0;
            status_clear_req <= 1'b0;
        end
        else begin
            ctrl_start_req   <= 1'b0;
            status_clear_req <= 1'b0;

            if (status_clear_req)
                fft_done_sticky <= 1'b0;

            if (b_hs) begin
                S_AXI_BVALID  <= 1'b0;
                S_AXI_BRESP   <= AXI_RESP_OKAY;
                S_AXI_BID     <= '0;
                S_AXI_AWREADY <= 1'b1;
            end

            if (!wr_active && !S_AXI_BVALID) begin
                S_AXI_AWREADY <= 1'b1;
                S_AXI_WREADY  <= 1'b0;

                if (aw_hs) begin
                    wr_id         <= S_AXI_AWID;
                    wr_addr       <= S_AXI_AWADDR;
                    wr_beats_left <= S_AXI_AWLEN + 8'd1;
                    wr_size       <= S_AXI_AWSIZE;
                    wr_burst      <= S_AXI_AWBURST;
                    wr_active     <= 1'b1;
                    wr_resp_accum <= AXI_RESP_OKAY;

                    S_AXI_AWREADY <= 1'b0;
                    S_AXI_WREADY  <= 1'b1;

                    if (S_AXI_AWSIZE != 3'd2)
                        wr_resp_accum <= AXI_RESP_SLVERR;

                    if ((S_AXI_AWBURST != 2'b00) && (S_AXI_AWBURST != 2'b01))
                        wr_resp_accum <= AXI_RESP_SLVERR;
                end
            end
            else if (wr_active) begin
                if (w_hs) begin
                    if (wr_size != 3'd2)
                        wr_resp_accum <= AXI_RESP_SLVERR;

                    if ((wr_burst != 2'b00) && (wr_burst != 2'b01))
                        wr_resp_accum <= AXI_RESP_SLVERR;

                    if (wr_addr[1:0] != 2'b00)
                        wr_resp_accum <= AXI_RESP_SLVERR;

                    if ((wr_size == 3'd2) && (wr_addr[1:0] == 2'b00)) begin
                        if (wr_addr == CTRL_ADDR) begin
                            if (S_AXI_WSTRB[0] && S_AXI_WDATA[0])
                                ctrl_start_req <= 1'b1;
                        end
                        else if (wr_addr == STATUS_ADDR) begin
                            if (S_AXI_WSTRB[0] && S_AXI_WDATA[0])
                                status_clear_req <= 1'b1;
                        end
                        else if ((wr_addr >= IN_BASE) && (wr_addr <= IN_LAST)) begin
                            widx = (wr_addr - IN_BASE) >> 2;
                            in_buf[widx] <= apply_wstrb32(in_buf[widx], S_AXI_WDATA, S_AXI_WSTRB);
                        end
                        else if ((wr_addr >= OUT_BASE) && (wr_addr <= OUT_LAST)) begin
                            widx = (wr_addr - OUT_BASE) >> 2;
                            out_buf[widx] <= apply_wstrb32(out_buf[widx], S_AXI_WDATA, S_AXI_WSTRB);
                        end
                        else begin
                            wr_resp_accum <= AXI_RESP_SLVERR;
                        end
                    end

                    if (((wr_beats_left == 8'd1) && !S_AXI_WLAST) ||
                        ((wr_beats_left != 8'd1) &&  S_AXI_WLAST)) begin
                        wr_resp_accum <= AXI_RESP_SLVERR;
                    end

                    if (wr_beats_left == 8'd1) begin
                        wr_active    <= 1'b0;
                        S_AXI_WREADY <= 1'b0;
                        S_AXI_BVALID <= 1'b1;
                        S_AXI_BRESP  <= wr_resp_accum;
                        S_AXI_BID    <= wr_id;
                    end
                    else begin
                        wr_beats_left <= wr_beats_left - 8'd1;
                        wr_addr       <= wr_next_addr;
                    end
                end
            end
        end
    end

    // --------------------------------------------------------------------
    // Read channel state
    // --------------------------------------------------------------------
    logic [AXI_ID_W-1:0]   rd_id;
    logic [AXI_ADDR_W-1:0] rd_addr;
    logic [AXI_ADDR_W-1:0] rd_next_addr;
    logic [7:0]            rd_beats_left;
    logic [2:0]            rd_size;
    logic [1:0]            rd_burst;
    logic                  rd_active;
    logic [1:0]            rd_resp_accum;

    assign rd_next_addr = next_axi_addr(rd_addr, rd_size, rd_burst);

    wire ar_hs = S_AXI_ARVALID && S_AXI_ARREADY;
    wire r_hs  = S_AXI_RVALID  && S_AXI_RREADY;

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            S_AXI_ARREADY <= 1'b1;
            S_AXI_RVALID  <= 1'b0;
            S_AXI_RRESP   <= AXI_RESP_OKAY;
            S_AXI_RLAST   <= 1'b0;
            S_AXI_RDATA   <= '0;
            S_AXI_RID     <= '0;

            rd_id         <= '0;
            rd_addr       <= '0;
            rd_beats_left <= '0;
            rd_size       <= 3'd0;
            rd_burst      <= 2'b01;
            rd_active     <= 1'b0;
            rd_resp_accum <= AXI_RESP_OKAY;
        end
        else begin
            if (!rd_active && !S_AXI_RVALID) begin
                S_AXI_ARREADY <= 1'b1;

                if (ar_hs) begin
                    rd_id         <= S_AXI_ARID;
                    rd_addr       <= S_AXI_ARADDR;
                    rd_beats_left <= S_AXI_ARLEN + 8'd1;
                    rd_size       <= S_AXI_ARSIZE;
                    rd_burst      <= S_AXI_ARBURST;
                    rd_active     <= 1'b1;
                    rd_resp_accum <= AXI_RESP_OKAY;
                    S_AXI_ARREADY <= 1'b0;

                    if (S_AXI_ARSIZE != 3'd2)
                        rd_resp_accum <= AXI_RESP_SLVERR;

                    if ((S_AXI_ARBURST != 2'b00) && (S_AXI_ARBURST != 2'b01))
                        rd_resp_accum <= AXI_RESP_SLVERR;

                    S_AXI_RVALID <= 1'b1;
                    S_AXI_RID    <= S_AXI_ARID;
                    S_AXI_RLAST  <= (S_AXI_ARLEN == 8'd0);

                    if ((S_AXI_ARSIZE != 3'd2) ||
                        (S_AXI_ARADDR[1:0] != 2'b00) ||
                        !addr_is_valid_word(S_AXI_ARADDR)) begin
                        S_AXI_RRESP <= AXI_RESP_SLVERR;
                        S_AXI_RDATA <= 32'hDEAD_BEEF;
                    end
                    else begin
                        S_AXI_RRESP <= AXI_RESP_OKAY;
                        S_AXI_RDATA <= axi_read_word(S_AXI_ARADDR);
                    end
                end
            end
            else if (rd_active) begin
                if (r_hs) begin
                    if (rd_beats_left == 8'd1) begin
                        rd_active    <= 1'b0;
                        S_AXI_RVALID <= 1'b0;
                        S_AXI_RLAST  <= 1'b0;
                        S_AXI_RRESP  <= AXI_RESP_OKAY;
                        S_AXI_RID    <= '0;
                    end
                    else begin
                        rd_beats_left <= rd_beats_left - 8'd1;
                        rd_addr       <= rd_next_addr;

                        S_AXI_RVALID  <= 1'b1;
                        S_AXI_RID     <= rd_id;
                        S_AXI_RLAST   <= (rd_beats_left == 8'd2);

                        if ((rd_size != 3'd2) ||
                            (rd_next_addr[1:0] != 2'b00) ||
                            !addr_is_valid_word(rd_next_addr)) begin
                            S_AXI_RRESP <= AXI_RESP_SLVERR;
                            S_AXI_RDATA <= 32'hDEAD_BEEF;
                        end
                        else begin
                            S_AXI_RRESP <= rd_resp_accum;
                            S_AXI_RDATA <= axi_read_word(rd_next_addr);
                        end
                    end
                end
            end
        end
    end

endmodule