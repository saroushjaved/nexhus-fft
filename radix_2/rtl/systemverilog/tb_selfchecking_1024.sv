`timescale 1ns/1ps

module tb_selfchecking_1024;

    localparam integer N           = 1024;
    localparam integer CORE_CYCLES = 2;

    logic                   clk;
    logic                   rst_n;
    logic                   start;
    logic [N*32-1:0]        fft_data_in;
    logic [N*32-1:0]        fft_data_out;
    logic                   done;
    logic signed [15:0]     re, im;

    integer i;
    integer mismatches;
    integer fd_cmp;
    integer exact_match;
    integer within_tol1;
    integer within_tol2;
    integer within_tol3;
    integer over_tol3;
    integer abs_re_err;
    integer abs_im_err;
    integer max_err;
    integer fd_report;
    
    
    logic signed [15:0] ref_r_scaled;
     logic signed [15:0] ref_i_scaled;
        

    fft_top #(
        .N(N),
        .CORE_CYCLES(CORE_CYCLES),
        .TW_FILE("twiddle1024.mem")
    ) dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .start       (start),
        .fft_data_in (fft_data_in),
        .fft_data_out(fft_data_out),
        .done        (done)
    );

    // file vars
    integer fd;
    integer rc;
    int unsigned r, ii;
    logic signed [15:0] in_real [0:N-1];
    logic signed [15:0] in_imag [0:N-1];

    integer fd2;
    integer rc2;
    int index;
    int unsigned real_res, imag_res;
    logic signed [15:0] ref_real [0:N-1];
    logic signed [15:0] ref_imag [0:N-1];

    // clock: 100 MHz
    always #5 clk = ~clk;

    initial begin
        clk        = 0;
        rst_n      = 0;
        start      = 0;
        fft_data_in = 0;
        mismatches = 0;
        exact_match = 0;
        within_tol1 = 0;
        within_tol2 = 0;
        within_tol3 = 0;
        over_tol3   = 0;
        max_err     = 0;

        // reset
        #20;
        rst_n = 1;

        // ----------------------------
        // read input data file
        // format per line: <real_hex> <imag_hex>
        // ----------------------------
        fd = $fopen("mixed_1024_input.txt", "r");
        if (fd == 0) begin
            $display("ERROR: cannot open input file");
            $finish;
        end

        for (i = 0; i < N; i = i + 1) begin
            rc = $fscanf(fd, "%h %h\n", r, ii);
            if (rc != 2) begin
                $display("ERROR: parse error in input file at line %0d", i);
                $finish;
            end
            in_real[i] = r[15:0];
            in_imag[i] = ii[15:0];
        end
        $fclose(fd);

        // ----------------------------
        // read reference output file
        // format per line: <index_dec> <real_hex> <imag_hex>
        // ----------------------------
        fd2 = $fopen("cmodel_fft_out_mixed_1024.txt", "r");
        if (fd2 == 0) begin
            $display("ERROR: cannot open reference file");
            $finish;
        end

        for (i = 0; i < N; i = i + 1) begin
            rc2 = $fscanf(fd2, "%d %h %h\n", index, real_res, imag_res);
            if (rc2 != 3) begin
                $display("ERROR: parse error in reference file at line %0d", i);
                $finish;
            end

            if (index != i) begin
                $display("ERROR: reference index mismatch at line %0d: got %0d", i, index);
                $finish;
            end

            ref_real[i] = real_res[15:0];
            ref_imag[i] = imag_res[15:0];
        end
        $fclose(fd2);

        // ----------------------------
        // pack input data exactly like working TB
        // x[i] = {real, imag}
        // ----------------------------
        for (i = 0; i < N; i = i + 1) begin
            fft_data_in[(N-1-i)*32 + 31 -: 16] = in_real[i];
            fft_data_in[(N-1-i)*32 + 15 -: 16] = in_imag[i];
        end

        // start pulse (1 clock) - same pattern as working TB
        #10;
        start = 1;
        #10;
        start = 0;

        // wait for completion of FULL FFT
        wait (done);
        #20;

        fd_cmp = $fopen("fft_comparison.txt","w");
        if (fd_cmp == 0) begin
            $display("ERROR: cannot open comparison output file");
            $finish;
        end
        
        // Comparsion Report Generation 
    
             for (i = 0; i < N; i = i + 1) begin
            re = fft_data_out[(N-1-i)*32 + 31 -: 16];
            im = fft_data_out[(N-1-i)*32 + 15 -: 16];

            abs_re_err = re - ref_real[i];
            if (abs_re_err < 0) abs_re_err = -abs_re_err;

            abs_im_err = im - ref_imag[i];
            if (abs_im_err < 0) abs_im_err = -abs_im_err;

            if (abs_re_err > max_err) max_err = abs_re_err;
            if (abs_im_err > max_err) max_err = abs_im_err;

            if ((abs_re_err == 0) && (abs_im_err == 0)) begin
                exact_match = exact_match + 1;
            end
            if ((abs_re_err <= 1) && (abs_im_err <= 1)) begin
                within_tol1 = within_tol1 + 1;
            end
            if ((abs_re_err <= 2) && (abs_im_err <= 2)) begin
                within_tol2 = within_tol2 + 1;
            end
            if ((abs_re_err <= 3) && (abs_im_err <= 3)) begin
                within_tol3 = within_tol3 + 1;
            end
            else begin
                over_tol3 = over_tol3 + 1;
            end

            if ((abs_re_err > 3) || (abs_im_err > 3)) begin
                mismatches = mismatches + 1;
                $display("MISMATCH [%0d] DUT=(%0d,%0d) REF=(%0d,%0d)", i, re, im, ref_real[i], ref_imag[i]);
                $fdisplay(fd_cmp, "MISMATCH [%0d] DUT=(%0d,%0d) REF=(%0d,%0d)", i, re, im, ref_real[i], ref_imag[i]);
            end
            else begin
                $fdisplay(fd_cmp, "MATCH [%0d] DUT=(%0d,%0d) REF=(%0d,%0d)", i, re, im, ref_real[i], ref_imag[i]);
            end
        end
        

        $fclose(fd_cmp);

        if (mismatches == 0)
            $display("PASS: DUT matches reference for all %0d bins", N);
        else
            $display("FAIL: %0d mismatches found", mismatches);
            
            
                fd_report = $fopen("fft_summary_report.txt", "w");
        if (fd_report == 0) begin
            $display("ERROR: cannot open report file");
            $finish;
        end

        $fdisplay(fd_report, "==========================================");
        $fdisplay(fd_report, "FFT 1024 Simulation Summary Report");
        $fdisplay(fd_report, "==========================================");
        $fdisplay(fd_report, "Total bins                : %0d", N);
        $fdisplay(fd_report, "Exact matches             : %0d", exact_match);
        $fdisplay(fd_report, "Within +/-1 tolerance     : %0d", within_tol1);
        $fdisplay(fd_report, "Within +/-2 tolerance     : %0d", within_tol2);
        $fdisplay(fd_report, "Within +/-3 tolerance     : %0d", within_tol3);
        $fdisplay(fd_report, "Outside +/-3 tolerance    : %0d", over_tol3);
        $fdisplay(fd_report, "Reported mismatches       : %0d", mismatches);
        $fdisplay(fd_report, "Maximum absolute error    : %0d", max_err);
        $fdisplay(fd_report, "");

        if (mismatches == 0)
            $fdisplay(fd_report, "Overall Result            : PASS");
        else
            $fdisplay(fd_report, "Overall Result            : FAIL");

        $fdisplay(fd_report, "==========================================");
        $fclose(fd_report);

        $display("Done.");
        $finish;
    end

endmodule