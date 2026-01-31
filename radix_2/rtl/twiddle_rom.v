

module twiddle_rom (
    input  wire [2:0] waddr_0,
    input  wire [2:0] waddr_1,
    input  wire [2:0] waddr_2,
    input  wire [2:0] waddr_3,


    output wire signed [31:0] wout_0,
    output wire signed [31:0] wout_1,
    output wire signed [31:0] wout_2,
    output wire signed [31:0] wout_3
);

  
   function automatic [31:0] tw_lut;
        input [4:0] a;
        begin
            case (a)
              3'd0: tw_lut = 32'h7FFF0000; //  1.0  + j0.0
              3'd1: tw_lut = 32'h5A82A57E; //  0.7071 - j0.7071
              3'd2: tw_lut = 32'h00008000; //  0.0    - j1.0
              3'd3: tw_lut = 32'hA57EA57E; // -0.7071 - j0.7071

               default: tw_lut = 32'h00000000;

            endcase
        end
    endfunction

    assign wout_0 = tw_lut(waddr_0);
    assign wout_1 = tw_lut(waddr_1);
    assign wout_2 = tw_lut(waddr_2);
    assign wout_3 = tw_lut(waddr_3);

    
endmodule
