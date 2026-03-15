#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include "FFT_Radix2_Q15.hpp"
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <cstdlib>


static bool write_fft_bins_hex(const char* path, const Complex* X, int N)
{
    FILE* f = std::fopen(path, "w");
    if (!f) {
        std::perror("fopen (output)");
        return false;
    }

    for (int k = 0; k < N; ++k) {
        // Cast to uint16_t for clean 4-hex-digit printing even for negatives
        uint16_t r = static_cast<uint16_t>(X[k].real);
        uint16_t i = static_cast<uint16_t>(X[k].imag);

        // k as decimal + real/imag as 16-bit hex, one bin per line
        std::fprintf(f, "%4d 0x%04X 0x%04X\n", k, r, i);
    }

    std::fclose(f);
    return true;
}


static inline bool within_lsb(int32_t d, int32_t tol) {
    return (d >= -tol) && (d <= tol);
}

static bool load_complex_q15_file(const char* path, Complex* x, int N)
{
    FILE* f = std::fopen(path, "r");
    if (!f) {
        std::perror("fopen");
        return false;
    }

    for (int n = 0; n < N; ++n) {
        unsigned int r = 0, i = 0;

        // Accepts "0x1234 0xABCD" or "1234 ABCD"
        int rc = std::fscanf(f, "%x %x", &r, &i);
        if (rc != 2) {
            std::fprintf(stderr, "Parse error in %s at line %d\n", path, n + 1);
            std::fclose(f);
            return false;
        }

        x[n].real = (int16_t)r;
        x[n].imag = (int16_t)i;
    }

    std::fclose(f);
    return true;
}

int main() {
    FFT_Radix2_Q15 fft;

    constexpr int N = 1024;
    Complex x[N];

    // Choose one file to test
    const char* in_file = "impulse_1024_input.txt";
    // const char* in_file = "impulse_1024_input.txt";
    // const char* in_file = "mixed_1024_input.txt";

    if (!load_complex_q15_file(in_file, x, N)) {
        return 1;
    }

  

    // Complete FFT
	fft.bit_reverse_reorder_incr(x, N);
    fft.FFT_Core_DIT(x, fft.W1024T_);

  

    for (int i = 0; i < 1024; ++i) {
        std::printf("X[%d] = (%6d, %6d)\n", i, x[i].real, x[i].imag);
    }

    const char* out_file = "cmodel_fft_out_impulse_1024.txt";
    if (!write_fft_bins_hex(out_file, x, N)) {
        return 1;
    }
    std::printf("\nWrote %d FFT bins to %s\n", N, out_file);


    return 0;
}
