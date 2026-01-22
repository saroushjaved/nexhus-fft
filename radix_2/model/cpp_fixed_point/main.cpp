#include "FFT_Radix2_Q15.hpp"
#include <cstdio>
#include <cstdint>

int main() {
    FFT_Radix2_Q15 fft;

    // Your sample input (Q15)
    Complex x[8] = {
        {(int16_t)0x0000, (int16_t)0x0000},
        {(int16_t)0x5A82, (int16_t)0x0000},
        {(int16_t)0x7FFF, (int16_t)0x0000},
        {(int16_t)0x5A82, (int16_t)0x0000},
        {(int16_t)0x0000, (int16_t)0x0000},
        {(int16_t)0xA57E, (int16_t)0x0000},
        {(int16_t)0x8000, (int16_t)0x0000},
        {(int16_t)0xA57E, (int16_t)0x0000}
    };

    // Same pipeline as your original code:
    fft.bit_reverse_reorder_incr(x, 8);

    // Stage 1: 2-point FFTs
    for (int i = 0; i < 8; i += 2) {
        fft.two_point_fft(&x[i]);
    }

    // Stage 2: 4-point FFTs
    for (int i = 0; i < 8; i += 4) {
        fft.four_point_fft_from_2pt_results(&x[i], fft.W4T());
    }

    // Stage 3: 8-point combine
    fft.eight_point_fft(x, fft.W8T());

    // Output (scaled by 1/8 overall)
    for (int i = 0; i < 8; ++i) {
        std::printf("X[%d] = 0x%04X + j0x%04X   (%.6f + j%.6f)\n",
                    i,
                    (uint16_t)x[i].real, (uint16_t)x[i].imag,
                    (float)x[i].real / 32768.0f,
                    (float)x[i].imag / 32768.0f);
    }

    return 0;
}
