module fft_ram_8x32 (
    input  wire        clk,
    input  wire        rst_n,

    // Write Enables
    input  wire [7:0]  x_we,

    // Write Data Inputs
    input  wire [31:0] x_in_0,
    input  wire [31:0] x_in_1,
    input  wire [31:0] x_in_2,
    input  wire [31:0] x_in_3,
    input  wire [31:0] x_in_4,
    input  wire [31:0] x_in_5,
    input  wire [31:0] x_in_6,
    input  wire [31:0] x_in_7,

    // Read Data Outputs
    output wire [31:0] x_out_0,
    output wire [31:0] x_out_1,
    output wire [31:0] x_out_2,
    output wire [31:0] x_out_3,
    output wire [31:0] x_out_4,
    output wire [31:0] x_out_5,
    output wire [31:0] x_out_6,
    output wire [31:0] x_out_7
);

    // ----------------------------
    // Internal Memory: 8 x 32-bit
    // ----------------------------
    reg [31:0] mem [0:7];

    // ----------------------------
    // Synchronous Write
    // ----------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem[0] <= 32'd0;
            mem[1] <= 32'd0;
            mem[2] <= 32'd0;
            mem[3] <= 32'd0;
            mem[4] <= 32'd0;
            mem[5] <= 32'd0;
            mem[6] <= 32'd0;
            mem[7] <= 32'd0;
        end
        else begin
            if (x_we[0]) mem[0] <= x_in_0;
            if (x_we[1]) mem[1] <= x_in_1;
            if (x_we[2]) mem[2] <= x_in_2;
            if (x_we[3]) mem[3] <= x_in_3;
            if (x_we[4]) mem[4] <= x_in_4;
            if (x_we[5]) mem[5] <= x_in_5;
            if (x_we[6]) mem[6] <= x_in_6;
            if (x_we[7]) mem[7] <= x_in_7;
        end
    end

    // ----------------------------
    // Combinational Read Outputs
    // ----------------------------
    assign x_out_0 = mem[0];
    assign x_out_1 = mem[1];
    assign x_out_2 = mem[2];
    assign x_out_3 = mem[3];
    assign x_out_4 = mem[4];
    assign x_out_5 = mem[5];
    assign x_out_6 = mem[6];
    assign x_out_7 = mem[7];

endmodule