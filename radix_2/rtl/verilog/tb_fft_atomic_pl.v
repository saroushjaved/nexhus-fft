`timescale 1ns/1ps

module tb_fft_atomic_p1;

  // ----------------------------
  // Clock + Reset
  // ----------------------------
  reg clk;
  reg rst_n;

  initial begin
    clk = 0;
    forever #5 clk = ~clk;   // 100 MHz clock
  end

  initial begin
    rst_n = 0;
    #20 rst_n = 1;
  end

  // ----------------------------
  // DUT Inputs
  // ----------------------------
  reg in_valid;

  reg signed [15:0] a_real, a_imag;
  reg signed [15:0] b_real, b_imag;
  reg signed [15:0] W_real, W_imag;

  // ----------------------------
  // DUT Outputs
  // ----------------------------
  wire signed [15:0] a_real_out, a_imag_out;
  wire signed [15:0] b_real_out, b_imag_out;
  wire out_valid;

  // ----------------------------
  // Instantiate DUT
  // ----------------------------
  fft_atomic_p1 dut (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),

    .a_real(a_real),
    .a_imag(a_imag),
    .b_real(b_real),
    .b_imag(b_imag),

    .W_real(W_real),
    .W_imag(W_imag),

    .a_real_out(a_real_out),
    .a_imag_out(a_imag_out),
    .b_real_out(b_real_out),
    .b_imag_out(b_imag_out),

    .out_valid(out_valid)
  );

  // ----------------------------
  // Test vectors (10 cases)
  // ----------------------------
  localparam integer NCASES = 10;

  reg signed [15:0] A_R [0:NCASES-1];
  reg signed [15:0] A_I [0:NCASES-1];
  reg signed [15:0] B_R [0:NCASES-1];
  reg signed [15:0] B_I [0:NCASES-1];
  reg signed [15:0] W_R [0:NCASES-1];
  reg signed [15:0] W_I [0:NCASES-1];

  reg signed [15:0] EXP_Y0_R [0:NCASES-1];
  reg signed [15:0] EXP_Y0_I [0:NCASES-1];
  reg signed [15:0] EXP_Y1_R [0:NCASES-1];
  reg signed [15:0] EXP_Y1_I [0:NCASES-1];

  // ----------------------------
  // Helper: apply one case + check
  // ----------------------------
  task automatic run_case(
    input integer idx
  );
    integer cyc;
    reg pass;
    begin
      // drive inputs
      a_real = A_R[idx];
      a_imag = A_I[idx];
      b_real = B_R[idx];
      b_imag = B_I[idx];
      W_real = W_R[idx];
      W_imag = W_I[idx];

      // pulse valid for 1 cycle
      in_valid = 1;
      @(posedge clk);
      in_valid = 0;

      // wait for out_valid with timeout (prevents hangs)
      cyc = 0;
      while (out_valid !== 1'b1 && cyc < 200) begin
        @(posedge clk);
        cyc = cyc + 1;
      end

      if (out_valid !== 1'b1) begin
        $display("CASE %0d FAIL: out_valid timeout (waited %0d cycles)", idx, cyc);
      end else begin
        // sample on next clock edge (cleaner if outputs registered)
        @(posedge clk);

        pass =
          (a_real_out === EXP_Y0_R[idx]) &&
          (a_imag_out === EXP_Y0_I[idx]) &&
          (b_real_out === EXP_Y1_R[idx]) &&
          (b_imag_out === EXP_Y1_I[idx]);

        if (pass) begin
          $display("CASE %0d PASS | y0=(%0d,%0d) y1=(%0d,%0d)",
            idx, a_real_out, a_imag_out, b_real_out, b_imag_out);
        end else begin
          $display("CASE %0d FAIL", idx);
          $display("  IN : a=(%0d,%0d) b=(%0d,%0d) W=(%0d,%0d)",
            A_R[idx], A_I[idx], B_R[idx], B_I[idx], W_R[idx], W_I[idx]);
          $display("  EXP: y0=(%0d,%0d) y1=(%0d,%0d)",
            EXP_Y0_R[idx], EXP_Y0_I[idx], EXP_Y1_R[idx], EXP_Y1_I[idx]);
          $display("  GOT: y0=(%0d,%0d) y1=(%0d,%0d)",
            a_real_out, a_imag_out, b_real_out, b_imag_out);
        end
      end

      // small gap between cases
      repeat (2) @(posedge clk);
    end
  endtask

  // ----------------------------
  // Init vectors + run all
  // ----------------------------
  integer i;

  initial begin
    // defaults
    in_valid = 0;
    a_real = 0; a_imag = 0;
    b_real = 0; b_imag = 0;
    W_real = 0; W_imag = 0;

    // ---- Fill testcases ----
    // Case 0: given
    A_R[0]=16'sd16384; A_I[0]=16'sd16384; B_R[0]=16'sd16384; B_I[0]=-16'sd16384; W_R[0]=16'sd23170; W_I[0]=-16'sd23170;
    EXP_Y0_R[0]=16'sd8192;  EXP_Y0_I[0]=-16'sd3393;  EXP_Y1_R[0]=16'sd8192;  EXP_Y1_I[0]=16'sd19777;

    // Case 1: W = 1 + j0
    A_R[1]=16'sd16384; A_I[1]=16'sd16384; B_R[1]=16'sd16384; B_I[1]=-16'sd16384; W_R[1]=16'sd32767; W_I[1]=16'sd0;
    EXP_Y0_R[1]=16'sd16384; EXP_Y0_I[1]=16'sd0;      EXP_Y1_R[1]=16'sd0;      EXP_Y1_I[1]=16'sd16383;

    // Case 2: W = -1
    A_R[2]=16'sd10000; A_I[2]=-16'sd20000; B_R[2]=-16'sd15000; B_I[2]=16'sd5000; W_R[2]=-16'sd32768; W_I[2]=16'sd0;
    EXP_Y0_R[2]=16'sd12500; EXP_Y0_I[2]=-16'sd12500; EXP_Y1_R[2]=-16'sd2500;  EXP_Y1_I[2]=-16'sd7500;

    // Case 3: W = +j
    A_R[3]=16'sd20000; A_I[3]=16'sd10000; B_R[3]=16'sd12000; B_I[3]=-16'sd8000; W_R[3]=16'sd0; W_I[3]=16'sd32767;
    EXP_Y0_R[3]=16'sd14000; EXP_Y0_I[3]=16'sd11000; EXP_Y1_R[3]=16'sd6000;  EXP_Y1_I[3]=-16'sd1000;

    // Case 4: W = -j
    A_R[4]=-16'sd20000; A_I[4]=16'sd25000; B_R[4]=16'sd15000; B_I[4]=16'sd16000; W_R[4]=16'sd0; W_I[4]=-16'sd32768;
    EXP_Y0_R[4]=-16'sd2000; EXP_Y0_I[4]=16'sd5000;  EXP_Y1_R[4]=-16'sd18000; EXP_Y1_I[4]=16'sd20000;

    // Case 5: near saturation on add
    A_R[5]=16'sd32767; A_I[5]=16'sd32767; B_R[5]=16'sd32767; B_I[5]=16'sd32767; W_R[5]=16'sd32767; W_I[5]=16'sd0;
    EXP_Y0_R[5]=16'sd32766; EXP_Y0_I[5]=16'sd32766; EXP_Y1_R[5]=16'sd0;      EXP_Y1_I[5]=16'sd0;

    // Case 6: large negative a
    A_R[6]=-16'sd32768; A_I[6]=-16'sd32768; B_R[6]=16'sd32767; B_I[6]=16'sd0; W_R[6]=16'sd32767; W_I[6]=16'sd0;
    EXP_Y0_R[6]=-16'sd1;     EXP_Y0_I[6]=-16'sd16384; EXP_Y1_R[6]=-16'sd32767; EXP_Y1_I[6]=-16'sd16384;

    // Case 7: mixed with W = -j
    A_R[7]=16'sd12345; A_I[7]=-16'sd23456; B_R[7]=-16'sd22222; B_I[7]=16'sd11111; W_R[7]=16'sd0; W_I[7]=-16'sd32768;
    EXP_Y0_R[7]=16'sd11728; EXP_Y0_I[7]=-16'sd617;  EXP_Y1_R[7]=16'sd617;   EXP_Y1_I[7]=-16'sd22839;

    // Case 8: W ? exp(-j*pi/3) = 0.5 - j0.866
    A_R[8]=-16'sd11111; A_I[8]=16'sd22222; B_R[8]=16'sd30000; B_I[8]=-16'sd10000; W_R[8]=16'sd16384; W_I[8]=-16'sd28378;
    EXP_Y0_R[8]=-16'sd2386; EXP_Y0_I[8]=-16'sd4380; EXP_Y1_R[8]=-16'sd8726; EXP_Y1_I[8]=16'sd26601;

    // Case 9: b = 0
    A_R[9]=16'sd30000; A_I[9]=-16'sd30000; B_R[9]=16'sd0; B_I[9]=16'sd0; W_R[9]=16'sd23170; W_I[9]=-16'sd23170;
    EXP_Y0_R[9]=16'sd15000; EXP_Y0_I[9]=-16'sd15000; EXP_Y1_R[9]=16'sd15000; EXP_Y1_I[9]=-16'sd15000;

    // ---- Run ----
    @(posedge rst_n);
    repeat (2) @(posedge clk);

    for (i = 0; i < NCASES; i = i + 1) begin
      run_case(i);
    end

    $display("All cases done.");
    #20;
    $finish;
  end

endmodule