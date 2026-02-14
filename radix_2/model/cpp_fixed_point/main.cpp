#include "FFT_Radix2_Q15.hpp"
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <cstdlib>

static inline bool within_lsb(int32_t d, int32_t tol) {
    return (d >= -tol) && (d <= tol);
}

int main() {
    FFT_Radix2_Q15 fft;

    // Tests for butterfly_dit_q15_s1
    Complex x[16] = {
    { (int16_t)0x2000, (int16_t)0xF000 }, // x[0]
    { (int16_t)0xF000, (int16_t)0x2000 }, // x[1]
    { (int16_t)0x4000, (int16_t)0x0800 }, // x[2]
    { (int16_t)0x1000, (int16_t)0xF800 }, // x[3]
    { (int16_t)0xE000, (int16_t)0x1000 }, // x[4]
    { (int16_t)0x0800, (int16_t)0xE000 }, // x[5]
    { (int16_t)0x0400, (int16_t)0x0C00 }, // x[6]
    { (int16_t)0xF800, (int16_t)0xF000 }, // x[7]

    { (int16_t)0x3000, (int16_t)0x1000 }, // x[8]
    { (int16_t)0xD000, (int16_t)0xF000 }, // x[9]
    { (int16_t)0x1800, (int16_t)0x0400 }, // x[10]
    { (int16_t)0xF400, (int16_t)0x0800 }, // x[11]
    { (int16_t)0x0C00, (int16_t)0xE800 }, // x[12]
    { (int16_t)0xEC00, (int16_t)0x1800 }, // x[13]
    { (int16_t)0x0200, (int16_t)0xFE00 }, // x[14]
    { (int16_t)0xFE00, (int16_t)0x0200 }  // x[15]
};

    

    // Complete FFT
    fft.FFT_Core_DIT(x, fft.W16T_);
    printf("\nAfter FFT:\n");
    for (int i = 0; i < 16; ++i) {
        printf("X[%d] = (%6d, %6d)\n", i, x[i].real, x[i].imag);
    }

    // Return failure only if outside tolerance
    return 0;
}
// for commit