module axi_burst_buffer #(
    parameter int ADDR_W = 12,
    parameter int DATA_W = 32,
    parameter int ID_W   = 4,
    parameter int DEPTH  = 1024
)(
    input  logic                  ACLK,
    input  logic                  ARESETn,

    // Write address channel
    input  logic [ID_W-1:0]       S_AXI_AWID,
    input  logic [ADDR_W-1:0]     S_AXI_AWADDR,
    input  logic [7:0]            S_AXI_AWLEN,
    input  logic [2:0]            S_AXI_AWSIZE,
    input  logic [1:0]            S_AXI_AWBURST,
    input  logic                  S_AXI_AWVALID,
    output logic                  S_AXI_AWREADY,

    // Write data channel
    input  logic [DATA_W-1:0]     S_AXI_WDATA,
    input  logic [DATA_W/8-1:0]   S_AXI_WSTRB,
    input  logic                  S_AXI_WLAST,
    input  logic                  S_AXI_WVALID,
    output logic                  S_AXI_WREADY,

    // Write response channel
    output logic [ID_W-1:0]       S_AXI_BID,
    output logic [1:0]            S_AXI_BRESP,
    output logic                  S_AXI_BVALID,
    input  logic                  S_AXI_BREADY,

    // Read address channel
    input  logic [ID_W-1:0]       S_AXI_ARID,
    input  logic [ADDR_W-1:0]     S_AXI_ARADDR,
    input  logic [7:0]            S_AXI_ARLEN,
    input  logic [2:0]            S_AXI_ARSIZE,
    input  logic [1:0]            S_AXI_ARBURST,
    input  logic                  S_AXI_ARVALID,
    output logic                  S_AXI_ARREADY,

    // Read data channel
    output logic [ID_W-1:0]       S_AXI_RID,
    output logic [DATA_W-1:0]     S_AXI_RDATA,
    output logic [1:0]            S_AXI_RRESP,
    output logic                  S_AXI_RLAST,
    output logic                  S_AXI_RVALID,
    input  logic                  S_AXI_RREADY
);


endmodule 