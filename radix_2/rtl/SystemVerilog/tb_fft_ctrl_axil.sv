`timescale 1ns/1ps

module tb_fft_ctrl_axil;

    localparam int AXI_ADDR_W = 16;
    localparam int AXI_DATA_W = 32;

    logic                      clk;
    logic                      rst_n;

    logic                      fft_done;
    logic                      fft_busy;
    logic                      start_pulse;

    // AXI4-Lite Slave Interface
    logic [AXI_ADDR_W-1:0]     S_AXI_AWADDR;
    logic                      S_AXI_AWVALID;
    logic                      S_AXI_AWREADY;

    logic [AXI_DATA_W-1:0]     S_AXI_WDATA;
    logic [AXI_DATA_W/8-1:0]   S_AXI_WSTRB;
    logic                      S_AXI_WVALID;
    logic                      S_AXI_WREADY;

    logic [1:0]                S_AXI_BRESP;
    logic                      S_AXI_BVALID;
    logic                      S_AXI_BREADY;

    logic [AXI_ADDR_W-1:0]     S_AXI_ARADDR;
    logic                      S_AXI_ARVALID;
    logic                      S_AXI_ARREADY;

    logic [AXI_DATA_W-1:0]     S_AXI_RDATA;
    logic [1:0]                S_AXI_RRESP;
    logic                      S_AXI_RVALID;
    logic                      S_AXI_RREADY;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------
    fft_ctrl_axil #(
        .AXI_ADDR_W(AXI_ADDR_W),
        .AXI_DATA_W(AXI_DATA_W)
    ) dut (
        .clk         (clk),
        .rst_n       (rst_n),

        .fft_done    (fft_done),
        .fft_busy    (fft_busy),
        .start_pulse (start_pulse),

        .S_AXI_AWADDR (S_AXI_AWADDR),
        .S_AXI_AWVALID(S_AXI_AWVALID),
        .S_AXI_AWREADY(S_AXI_AWREADY),

        .S_AXI_WDATA  (S_AXI_WDATA),
        .S_AXI_WSTRB  (S_AXI_WSTRB),
        .S_AXI_WVALID (S_AXI_WVALID),
        .S_AXI_WREADY (S_AXI_WREADY),

        .S_AXI_BRESP  (S_AXI_BRESP),
        .S_AXI_BVALID (S_AXI_BVALID),
        .S_AXI_BREADY (S_AXI_BREADY),

        .S_AXI_ARADDR (S_AXI_ARADDR),
        .S_AXI_ARVALID(S_AXI_ARVALID),
        .S_AXI_ARREADY(S_AXI_ARREADY),

        .S_AXI_RDATA  (S_AXI_RDATA),
        .S_AXI_RRESP  (S_AXI_RRESP),
        .S_AXI_RVALID (S_AXI_RVALID),
        .S_AXI_RREADY (S_AXI_RREADY)
    );

    // ------------------------------------------------------------
    // Clock
    // ------------------------------------------------------------
    always #5 clk = ~clk;

    // ------------------------------------------------------------
    // AXI-Lite helpers
    // ------------------------------------------------------------
    task automatic axi_write(
        input logic [AXI_ADDR_W-1:0] addr,
        input logic [AXI_DATA_W-1:0] data
    );
    begin
        @(posedge clk);
        S_AXI_AWADDR  <= addr;
        S_AXI_AWVALID <= 1'b1;
        S_AXI_WDATA   <= data;
        S_AXI_WSTRB   <= 4'hF;
        S_AXI_WVALID  <= 1'b1;
        S_AXI_BREADY  <= 1'b1;

        wait (S_AXI_AWREADY && S_AXI_WREADY);
        @(posedge clk);
        S_AXI_AWVALID <= 1'b0;
        S_AXI_WVALID  <= 1'b0;
        S_AXI_AWADDR  <= '0;
        S_AXI_WDATA   <= '0;
        S_AXI_WSTRB   <= '0;

        wait (S_AXI_BVALID);
        $display("[%0t] AXI WRITE addr=0x%04h data=0x%08h resp=%0d",
                 $time, addr, data, S_AXI_BRESP);

        @(posedge clk);
        S_AXI_BREADY <= 1'b0;
    end
    endtask

    task automatic axi_read(
        input  logic [AXI_ADDR_W-1:0] addr,
        output logic [AXI_DATA_W-1:0] data
    );
    begin
        @(posedge clk);
        S_AXI_ARADDR  <= addr;
        S_AXI_ARVALID <= 1'b1;
        S_AXI_RREADY  <= 1'b1;

        wait (S_AXI_ARREADY);
        @(posedge clk);
        S_AXI_ARVALID <= 1'b0;
        S_AXI_ARADDR  <= '0;

        wait (S_AXI_RVALID);
        data = S_AXI_RDATA;
        $display("[%0t] AXI READ  addr=0x%04h data=0x%08h resp=%0d",
                 $time, addr, S_AXI_RDATA, S_AXI_RRESP);

        @(posedge clk);
        S_AXI_RREADY <= 1'b0;
    end
    endtask

    // ------------------------------------------------------------
    // Monitor
    // ------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst_n && start_pulse)
            $display("[%0t] start_pulse asserted", $time);
    end

    // ------------------------------------------------------------
    // Stimulus
    // ------------------------------------------------------------
    logic [31:0] rd_data;

    initial begin
        clk           = 1'b0;
        rst_n         = 1'b0;
        fft_done      = 1'b0;
        fft_busy      = 1'b0;

        S_AXI_AWADDR  = '0;
        S_AXI_AWVALID = 1'b0;
        S_AXI_WDATA   = '0;
        S_AXI_WSTRB   = '0;
        S_AXI_WVALID  = 1'b0;
        S_AXI_BREADY  = 1'b0;

        S_AXI_ARADDR  = '0;
        S_AXI_ARVALID = 1'b0;
        S_AXI_RREADY  = 1'b0;

        repeat (4) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        // --------------------------------------------------------
        // 1. Read STATUS when idle
        // expect done=0, busy=0
        // --------------------------------------------------------
        axi_read(16'h0004, rd_data);

        // --------------------------------------------------------
        // 2. Write CTRL.start when idle
        // expect start_pulse
        // --------------------------------------------------------
        axi_write(16'h0000, 32'h0000_0001);

        // --------------------------------------------------------
        // 3. Pretend FFT is busy, read STATUS
        // expect busy=1
        // --------------------------------------------------------
        fft_busy = 1'b1;
        repeat (2) @(posedge clk);
        axi_read(16'h0004, rd_data);

        // --------------------------------------------------------
        // 4. Try start while busy
        // expect SLVERR response
        // --------------------------------------------------------
        axi_write(16'h0000, 32'h0000_0001);

        // --------------------------------------------------------
        // 5. Pretend FFT finished
        // expect done=1, busy=0
        // --------------------------------------------------------
        fft_busy = 1'b0;
        fft_done = 1'b1;
        repeat (2) @(posedge clk);
        axi_read(16'h0004, rd_data);

        // --------------------------------------------------------
        // 6. Invalid read
        // expect SLVERR + DEAD_BEEF
        // --------------------------------------------------------
        axi_read(16'h0010, rd_data);

        $display("TB completed.");
        $finish;
    end

endmodule