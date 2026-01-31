module x_bank_64x32_bus (
    input  wire         clk,
    input  wire         rst_n,

    input  wire [64*32-1:0] x_in_bus,
    input  wire [63:0]      x_we,
    output wire [64*32-1:0] x_out_bus
);
    reg [64*32-1:0] mem;

    assign x_out_bus = mem;

    integer i;
    always @(posedge clk) begin
        if (!rst_n) begin
            mem <= {64*32{1'b0}};
        end else begin
            for (i=0; i<64; i=i+1) begin
                if (x_we[i]) begin
                    mem[i*32 +: 32] <= x_in_bus[i*32 +: 32];
                end
            end
        end
    end
endmodule