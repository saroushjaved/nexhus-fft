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

    // Input (Q15)
    Complex x_in[8] = {
        { 32767, 0 },
        { 23170,-23170 },
        {     0,-32767 },
        {-23170,-23170 },
        {-32767, 0 },
        {-23170, 23170 },
        {     0, 32767 },
        { 23170, 23170 }
    };

    // Copies for both paths
    Complex x_ref[8];
    Complex x_gen[8];
    std::memcpy(x_ref, x_in, sizeof(x_in));
    std::memcpy(x_gen, x_in, sizeof(x_in));

    // -------------------------------------------------
    // Reference pipeline (original hand-written stages)
    // -------------------------------------------------
    fft.bit_reverse_reorder_incr(x_ref, 8);

    for (int i = 0; i < 8; i += 2)
        fft.two_point_fft(&x_ref[i]);

    for (int i = 0; i < 8; i += 4)
        fft.four_point_fft_from_2pt_results(&x_ref[i], fft.W4T());

    fft.eight_point_fft(x_ref, fft.W8T());

    // -------------------------------------------------
    // Generalized radix-2 DIT FFT core
    // -------------------------------------------------
    fft.bit_reverse_reorder_incr(x_gen, 8);
    fft.FFT_Core_DIT(x_gen, fft.W8T());

    // -------------------------------------------------
    // Compare results
    // -------------------------------------------------
    bool exact_match = true;
    bool tol_match   = true;

    std::printf(
        "Idx | REF (hex)        | GEN (hex)        | dRe  dIm | Result\n"
        "-----------------------------------------------------------------------\n"
    );

    for (int i = 0; i < 8; ++i) {
        int32_t dre = (int32_t)x_ref[i].real - (int32_t)x_gen[i].real;
        int32_t dim = (int32_t)x_ref[i].imag - (int32_t)x_gen[i].imag;

        bool exact = (dre == 0) && (dim == 0);
        bool tol1  = within_lsb(dre, 1) && within_lsb(dim, 1);

        exact_match &= exact;
        tol_match   &= tol1;

        std::printf(
            " %2d | 0x%04X + j0x%04X | 0x%04X + j0x%04X | %4ld %4ld | %s\n",
            i,
            (uint16_t)x_ref[i].real, (uint16_t)x_ref[i].imag,
            (uint16_t)x_gen[i].real, (uint16_t)x_gen[i].imag,
            (long)dre, (long)dim,
            exact ? "EXACT" : (tol1 ? "±1 LSB OK" : "DIFF")
        );
    }

    std::printf("-----------------------------------------------------------------------\n");
    std::printf("Exact match : %s\n", exact_match ? "YES" : "NO");
    std::printf("±1 LSB match: %s\n", tol_match   ? "YES (ACCEPTED)" : "NO (ERROR)");

    // Return failure only if outside tolerance
    return tol_match ? 0 : 1;
}