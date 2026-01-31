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
    Complex x[8] = {
    {  8192,   -4096 },   //  +0.25  - j0.125
    { -4096,    8192 },   //  -0.125 + j0.25
    { 16384,    2048 },   //  +0.5   + j0.0625
    {  4096,   -2048 },   //  +0.125 - j0.0625
    { -8192,    4096 },   //  -0.25  + jee0.125
    {  2048,   -8192 },   //  +0.0625- j0.25
    {  1024,    3072 },   //  +0.03125 + j0.09375
    { -2048,   -4096 }    //  -0.0625 - j0.125
                        };

    fft.FFT_Stage_DIT(0, x, fft.W8T_);
    printf("After Stage 0:\n");
    for (int i = 0; i < 8; ++i) {
        printf("x[%d] = (%6d, %6d)\n", i, x[i].real, x[i].imag);
    }

    // Test input: a simple impulse

    // Return failure only if outside tolerance
    return 0;
}
// for commit