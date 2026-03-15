`timescale 1ns/1ps

module tb_fft_axi_system_16;

    localparam int N           = 16;
    localparam int AXI_ADDR_W  = 16;
    localparam int AXI_DATA_W  = 32;
    localparam int AXI_ID_W    = 4;

    localparam logic [AXI_ADDR_W-1:0] MEM_BASE    = 16'h1000;
    localparam logic [AXI_ADDR_W-1:0] CTRL_ADDR   = 16'h0000;
    localparam logic [AXI_ADDR_W-1:0] STATUS_ADDR = 16'h0004;

    logic clk;
    logic rst_n;

    // ------------------------------------------------------------
    // AXI-Lite control signals
    // ------------------------------------------------------------
    logic [AXI_ADDR_W-1:0]      S_AXIL_AWADDR;
    logic                       S_AXIL_AWVALID;
    logic                       S_AXIL_AWREADY;

    logic [AXI_DATA_W-1:0]      S_AXIL_WDATA;
    logic [AXI_DATA_W/8-1:0]    S_AXIL_WSTRB;
    logic                       S_AXIL_WVALID;
    logic                       S_AXIL_WREADY;

    logic [1:0]                 S_AXIL_BRESP;
    logic                       S_AXIL_BVALID;
    logic                       S_AXIL_BREADY;

    logic [AXI_ADDR_W-1:0]      S_AXIL_ARADDR;
    logic                       S_AXIL_ARVALID;
    logic                       S_AXIL_ARREADY;

    logic [AXI_DATA_W-1:0]      S_AXIL_RDATA;
    logic [1:0]                 S_AXIL_RRESP;
    logic                       S_AXIL_RVALID;
    logic                       S_AXIL_RREADY;

    // ------------------------------------------------------------
    // AXI4 memory-window signals
    // ------------------------------------------------------------
    logic [AXI_ID_W-1:0]        S_AXI_AWID;
    logic [AXI_ADDR_W-1:0]      S_AXI_AWADDR;
    logic [7:0]                 S_AXI_AWLEN;
    logic [2:0]                 S_AXI_AWSIZE;
    logic [1:0]                 S_AXI_AWBURST;
    logic                       S_AXI_AWVALID;
    logic                       S_AXI_AWREADY;

    logic [AXI_DATA_W-1:0]      S_AXI_WDATA;
    logic [AXI_DATA_W/8-1:0]    S_AXI_WSTRB;
    logic                       S_AXI_WLAST;
    logic                       S_AXI_WVALID;
    logic                       S_AXI_WREADY;

    logic [AXI_ID_W-1:0]        S_AXI_BID;
    logic [1:0]                 S_AXI_BRESP;
    logic                       S_AXI_BVALID;
    logic                       S_AXI_BREADY;

    logic [AXI_ID_W-1:0]        S_AXI_ARID;
    logic [AXI_ADDR_W-1:0]      S_AXI_ARADDR;
    logic [7:0]                 S_AXI_ARLEN;
    logic [2:0]                 S_AXI_ARSIZE;
    logic [1:0]                 S_AXI_ARBURST;
    logic                       S_AXI_ARVALID;
    logic                       S_AXI_ARREADY;

    logic [AXI_ID_W-1:0]        S_AXI_RID;
    logic [AXI_DATA_W-1:0]      S_AXI_RDATA;
    logic [1:0]                 S_AXI_RRESP;
    logic                       S_AXI_RLAST;
    logic                       S_AXI_RVALID;
    logic                       S_AXI_RREADY;

    // ------------------------------------------------------------
    // Internal interconnect
    // ------------------------------------------------------------
    logic                       fft_done;
    logic                       fft_busy;
    logic                       start_pulse;

    logic                       mem_we;
    logic [$clog2(N)-1:0]       mem_waddr;
    logic [31:0]                mem_wdata;
    logic [$clog2(N)-1:0]       mem_raddr;
    logic [31:0]                mem_rdata;

    integer i;
    integer mismatches;
    integer poll_count;

    logic signed [15:0] re, im;
    logic [31:0] read_buf [0:N-1];
    logic [31:0] expected [0:N-1];
    logic [31:0] status;

    // ------------------------------------------------------------
    // DUT pieces
    // ------------------------------------------------------------
    fft_ctrl_axil #(
        .AXI_ADDR_W(AXI_ADDR_W),
        .AXI_DATA_W(AXI_DATA_W)
    ) u_ctrl (
        .clk         (clk),
        .rst_n       (rst_n),
        .fft_done    (fft_done),
        .fft_busy    (fft_busy),
        .start_pulse (start_pulse),

        .S_AXI_AWADDR (S_AXIL_AWADDR),
        .S_AXI_AWVALID(S_AXIL_AWVALID),
        .S_AXI_AWREADY(S_AXIL_AWREADY),

        .S_AXI_WDATA  (S_AXIL_WDATA),
        .S_AXI_WSTRB  (S_AXIL_WSTRB),
        .S_AXI_WVALID (S_AXIL_WVALID),
        .S_AXI_WREADY (S_AXIL_WREADY),

        .S_AXI_BRESP  (S_AXIL_BRESP),
        .S_AXI_BVALID (S_AXIL_BVALID),
        .S_AXI_BREADY (S_AXIL_BREADY),

        .S_AXI_ARADDR (S_AXIL_ARADDR),
        .S_AXI_ARVALID(S_AXIL_ARVALID),
        .S_AXI_ARREADY(S_AXIL_ARREADY),

        .S_AXI_RDATA  (S_AXIL_RDATA),
        .S_AXI_RRESP  (S_AXIL_RRESP),
        .S_AXI_RVALID (S_AXIL_RVALID),
        .S_AXI_RREADY (S_AXIL_RREADY)
    );

    fft_mem_axi4_slave #(
        .N(N),
        .AXI_ADDR_W(AXI_ADDR_W),
        .AXI_DATA_W(AXI_DATA_W),
        .AXI_ID_W(AXI_ID_W)
    ) u_mem_axi (
        .clk        (clk),
        .rst_n      (rst_n),
        .fft_busy   (fft_busy),

        .mem_we     (mem_we),
        .mem_waddr  (mem_waddr),
        .mem_wdata  (mem_wdata),
        .mem_raddr  (mem_raddr),
        .mem_rdata  (mem_rdata),

        .S_AXI_AWID    (S_AXI_AWID),
        .S_AXI_AWADDR  (S_AXI_AWADDR),
        .S_AXI_AWLEN   (S_AXI_AWLEN),
        .S_AXI_AWSIZE  (S_AXI_AWSIZE),
        .S_AXI_AWBURST (S_AXI_AWBURST),
        .S_AXI_AWVALID (S_AXI_AWVALID),
        .S_AXI_AWREADY (S_AXI_AWREADY),

        .S_AXI_WDATA   (S_AXI_WDATA),
        .S_AXI_WSTRB   (S_AXI_WSTRB),
        .S_AXI_WLAST   (S_AXI_WLAST),
        .S_AXI_WVALID  (S_AXI_WVALID),
        .S_AXI_WREADY  (S_AXI_WREADY),

        .S_AXI_BID     (S_AXI_BID),
        .S_AXI_BRESP   (S_AXI_BRESP),
        .S_AXI_BVALID  (S_AXI_BVALID),
        .S_AXI_BREADY  (S_AXI_BREADY),

        .S_AXI_ARID    (S_AXI_ARID),
        .S_AXI_ARADDR  (S_AXI_ARADDR),
        .S_AXI_ARLEN   (S_AXI_ARLEN),
        .S_AXI_ARSIZE  (S_AXI_ARSIZE),
        .S_AXI_ARBURST (S_AXI_ARBURST),
        .S_AXI_ARVALID (S_AXI_ARVALID),
        .S_AXI_ARREADY (S_AXI_ARREADY),

        .S_AXI_RID     (S_AXI_RID),
        .S_AXI_RDATA   (S_AXI_RDATA),
        .S_AXI_RRESP   (S_AXI_RRESP),
        .S_AXI_RLAST   (S_AXI_RLAST),
        .S_AXI_RVALID  (S_AXI_RVALID),
        .S_AXI_RREADY  (S_AXI_RREADY)
    );

    fft_top #(
        .N(N)
    ) u_fft (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (start_pulse),
        .done     (fft_done),
        .busy     (fft_busy),

        .ext_we   (mem_we),
        .ext_waddr(mem_waddr),
        .ext_wdata(mem_wdata),
        .ext_raddr(mem_raddr),
        .ext_rdata(mem_rdata)
    );

    // ------------------------------------------------------------
    // Clock
    // ------------------------------------------------------------
    always #5 clk = ~clk;

    // ------------------------------------------------------------
    // AXI-Lite tasks
    // ------------------------------------------------------------
    task automatic axil_write(
        input logic [AXI_ADDR_W-1:0] addr,
        input logic [31:0]           data
    );
    begin
        @(negedge clk);
        S_AXIL_AWADDR  = addr;
        S_AXIL_AWVALID = 1'b1;
        S_AXIL_WDATA   = data;
        S_AXIL_WSTRB   = 4'hF;
        S_AXIL_WVALID  = 1'b1;
        S_AXIL_BREADY  = 1'b1;

        while (!(S_AXIL_AWREADY && S_AXIL_WREADY))
            @(posedge clk);

        @(negedge clk);
        S_AXIL_AWVALID = 1'b0;
        S_AXIL_WVALID  = 1'b0;
        S_AXIL_AWADDR  = '0;
        S_AXIL_WDATA   = '0;
        S_AXIL_WSTRB   = '0;

        while (!S_AXIL_BVALID)
            @(posedge clk);

        @(negedge clk);
        S_AXIL_BREADY = 1'b0;
    end
    endtask

    task automatic axil_read(
        input  logic [AXI_ADDR_W-1:0] addr,
        output logic [31:0]           data
    );
    begin
        @(negedge clk);
        S_AXIL_ARADDR  = addr;
        S_AXIL_ARVALID = 1'b1;
        S_AXIL_RREADY  = 1'b1;

        while (!S_AXIL_ARREADY)
            @(posedge clk);

        @(negedge clk);
        S_AXIL_ARVALID = 1'b0;
        S_AXIL_ARADDR  = '0;

        while (!S_AXIL_RVALID)
            @(posedge clk);

        data = S_AXIL_RDATA;

        @(negedge clk);
        S_AXIL_RREADY = 1'b0;
    end
    endtask

    // ------------------------------------------------------------
    // AXI4 tasks
    // ------------------------------------------------------------
    task automatic axi_burst_write_16;
        integer k;
        logic signed [15:0] tmp_re, tmp_im;
    begin
        @(negedge clk);
        S_AXI_AWID    = '0;
        S_AXI_AWADDR  = MEM_BASE;
        S_AXI_AWLEN   = N-1;
        S_AXI_AWSIZE  = 3'd2;
        S_AXI_AWBURST = 2'b01;
        S_AXI_AWVALID = 1'b1;
        S_AXI_BREADY  = 1'b1;

        while (!S_AXI_AWREADY)
            @(posedge clk);

        @(negedge clk);
        S_AXI_AWVALID = 1'b0;

        for (k = 0; k < N; k = k + 1) begin
            tmp_re = N-1-k;
            tmp_im = -(N-1-k);

            @(negedge clk);
            S_AXI_WDATA  = {tmp_re, tmp_im};
            S_AXI_WSTRB  = 4'hF;
            S_AXI_WLAST  = (k == N-1);
            S_AXI_WVALID = 1'b1;

            while (!S_AXI_WREADY)
                @(posedge clk);

            @(negedge clk);
            S_AXI_WVALID = 1'b0;
            S_AXI_WLAST  = 1'b0;
            S_AXI_WDATA  = '0;
            S_AXI_WSTRB  = '0;
        end

        while (!S_AXI_BVALID)
            @(posedge clk);

        @(negedge clk);
        S_AXI_BREADY = 1'b0;
    end
    endtask

    task automatic axi_burst_read_16;
        integer k;
    begin
        @(negedge clk);
        S_AXI_ARID    = '0;
        S_AXI_ARADDR  = MEM_BASE;
        S_AXI_ARLEN   = N-1;
        S_AXI_ARSIZE  = 3'd2;
        S_AXI_ARBURST = 2'b01;
        S_AXI_ARVALID = 1'b1;
        S_AXI_RREADY  = 1'b1;

        while (!S_AXI_ARREADY)
            @(posedge clk);

        @(negedge clk);
        S_AXI_ARVALID = 1'b0;

        for (k = 0; k < N; k = k + 1) begin
            while (!S_AXI_RVALID)
                @(posedge clk);

            read_buf[k] = S_AXI_RDATA;

            if ((k == N-1) && !S_AXI_RLAST)
                $display("ERROR: missing RLAST on final beat");
            if ((k != N-1) && S_AXI_RLAST)
                $display("ERROR: early RLAST at beat %0d", k);

            @(negedge clk);
        end

        S_AXI_RREADY = 1'b0;
    end
    endtask

    // ------------------------------------------------------------
    // Debug / checking
    // ------------------------------------------------------------
    task automatic dump_read_buf(input string tag);
    begin
        $display("\n%s", tag);
        for (i = 0; i < N; i = i + 1) begin
            re = read_buf[i][31:16];
            im = read_buf[i][15:0];
            $display("MEM[%0d] = %0d + j%0d", i, re, im);
        end
    end
    endtask

    task automatic check_input_memory;
    begin
        axi_burst_read_16();
        dump_read_buf("AXI MEMORY IMAGE BEFORE FFT:");
    end
    endtask

task automatic init_expected;
begin
    expected[0]  = { 16'sd7,  -16'sd8 };
    expected[1]  = { -16'sd3, -16'sd4 };
    expected[2]  = { -16'sd1, -16'sd2 };
    expected[3]  = { -16'sd1, -16'sd2 };
    expected[4]  = { 16'sd0,  -16'sd1 };
    expected[5]  = { 16'sd0,  -16'sd1 };
    expected[6]  = { 16'sd0,  -16'sd1 };
    expected[7]  = { 16'sd0,   16'sd0 };
    expected[8]  = { 16'sd0,  -16'sd1 };
    expected[9]  = { 16'sd0,  -16'sd1 };
    expected[10] = { 16'sd0,  -16'sd1 };
    expected[11] = { 16'sd1,  -16'sd1 };
    expected[12] = { 16'sd1,   16'sd0 };
    expected[13] = { 16'sd1,   16'sd0 };
    expected[14] = { 16'sd1,   16'sd0 };
    expected[15] = { 16'sd3,   16'sd1 };
end
endtask
    task automatic check_results;
    begin
        mismatches = 0;
        $display("\nAXI SYSTEM FFT OUTPUTS:");
        for (i = 0; i < N; i = i + 1) begin
            re = read_buf[i][31:16];
            im = read_buf[i][15:0];
            $display("MEM[%0d] = %0d + j%0d", i, re, im);

            if (read_buf[i] !== expected[i]) begin
                mismatches = mismatches + 1;
                $display("MISMATCH at %0d: got 0x%08h expected 0x%08h",
                         i, read_buf[i], expected[i]);
            end
        end

        if (mismatches == 0)
            $display("PASS: AXI-Lite control + AXI4 data path match expected FFT result.");
        else
            $display("FAIL: %0d mismatches found.", mismatches);
    end
    endtask

    // ------------------------------------------------------------
    // Stimulus
    // ------------------------------------------------------------
    initial begin
        clk  = 1'b0;
        rst_n = 1'b0;

        S_AXIL_AWADDR  = '0;
        S_AXIL_AWVALID = 1'b0;
        S_AXIL_WDATA   = '0;
        S_AXIL_WSTRB   = '0;
        S_AXIL_WVALID  = 1'b0;
        S_AXIL_BREADY  = 1'b0;
        S_AXIL_ARADDR  = '0;
        S_AXIL_ARVALID = 1'b0;
        S_AXIL_RREADY  = 1'b0;

        S_AXI_AWID     = '0;
        S_AXI_AWADDR   = '0;
        S_AXI_AWLEN    = '0;
        S_AXI_AWSIZE   = '0;
        S_AXI_AWBURST  = '0;
        S_AXI_AWVALID  = 1'b0;

        S_AXI_WDATA    = '0;
        S_AXI_WSTRB    = '0;
        S_AXI_WLAST    = 1'b0;
        S_AXI_WVALID   = 1'b0;

        S_AXI_BREADY   = 1'b0;

        S_AXI_ARID     = '0;
        S_AXI_ARADDR   = '0;
        S_AXI_ARLEN    = '0;
        S_AXI_ARSIZE   = '0;
        S_AXI_ARBURST  = '0;
        S_AXI_ARVALID  = 1'b0;

        S_AXI_RREADY   = 1'b0;

        init_expected();

        repeat (4) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        $display("[%0t] burst write start", $time);
        axi_burst_write_16();
        $display("[%0t] burst write done", $time);

        check_input_memory();

        @(posedge clk);

        $display("[%0t] ctrl start write", $time);
        axil_write(CTRL_ADDR, 32'h0000_0001);
        $display("[%0t] ctrl start write done", $time);

        status = 32'd0;
        poll_count = 0;
        $display("[%0t] polling status", $time);

        // wait until done=1 and busy=0
        while (((status[0] == 1'b0) || (status[1] == 1'b1)) && (poll_count < 1000)) begin
            axil_read(STATUS_ADDR, status);
            $display("[%0t] status = 0x%08h", $time, status);
            poll_count = poll_count + 1;
            @(posedge clk);
        end

        if ((status[0] != 1'b1) || (status[1] != 1'b0)) begin
            $display("ERROR: timeout waiting for done=1 and busy=0");
            $finish;
        end

        @(posedge clk);

        $display("[%0t] burst read start", $time);
        axi_burst_read_16();
        $display("[%0t] burst read done", $time);

        check_results();
        $finish;
    end

endmodule