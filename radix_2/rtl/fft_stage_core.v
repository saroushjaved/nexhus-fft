


module fft_stage_core #(
	parameter BW = 32 // butterflies per cycle
	parameter N = 1024,
)
(
	input wire clk,
	input wire rst_n,
	input wire start,
	input wire [3:0] stage, // for N=1024, stages 0..9 fits in 4 bits


	// Handshake
	output reg done,


	// Address outputs for RAM (you will use these to read/write)
	output reg [9:0] a_addr [0:BW-1], // log2(1024)=10
	output reg [9:0] b_addr [0:BW-1],
	output reg rd_en,


	output reg [9:0] y0_addr[0:BW-1],
	output reg [9:0] y1_addr[0:BW-1],
	output reg wr_en,


	// Data in from RAM (32 lanes)
	input wire signed [15:0] a_real_in [0:BW-1],
	input wire signed [15:0] a_imag_in [0:BW-1],
	input wire signed [15:0] b_real_in [0:BW-1],
	input wire signed [15:0] b_imag_in [0:BW-1],


	// Twiddle in (32 lanes) from ROM
	input wire signed [15:0] W_real_in [0:BW-1],
	input wire signed [15:0] W_imag_in [0:BW-1],


	// Data out to RAM (32 lanes)
	output wire signed [15:0] y0_real_out[0:BW-1],
	output wire signed [15:0] y0_imag_out[0:BW-1],
	output wire signed [15:0] y1_real_out[0:BW-1],
	output wire signed [15:0] y1_imag_out[0:BW-1]
);



	// Generating Variables for 
	
	



endmodule 