#include "FFT_Radix2_Q15.hpp"
#include <algorithm> // std::swap

// Provide storage (safe for many toolchains)
constexpr Complex FFT_Radix2_Q15::W4_TW_[4];
constexpr Complex FFT_Radix2_Q15::W8_TW_[8];
constexpr Complex FFT_Radix2_Q15::W16_TW_[16];

FFT_Radix2_Q15::FFT_Radix2_Q15()
    : W4T_{ 4, W4_TW_ },
    W8T_{ 8, W8_TW_ },
    W16T_{ 16, W16_TW_ },
    W1024T_{ 1024, W1024_TW_ }
{
}

// -----------------------------
// Helpers
// -----------------------------
int16_t FFT_Radix2_Q15::sat16(int32_t x) {
    if (x > 32767) return  32767;
    if (x < -32768) return -32768;
    return (int16_t)x;
}

int16_t FFT_Radix2_Q15::add_sat_s1(int16_t a, int16_t b) {
    return sat16(((int32_t)a + (int32_t)b) >> 1);
}

int16_t FFT_Radix2_Q15::sub_sat_s1(int16_t a, int16_t b) {
    return sat16(((int32_t)a - (int32_t)b) >> 1);
}

int16_t FFT_Radix2_Q15::q15_mul_rnd_sat(int16_t a, int16_t b) {
    int32_t p = (int32_t)a * (int32_t)b;  // Q30
    p += (1 << 14);                       // round
    p >>= 15;                             // back to Q15
    return sat16(p);
}

Complex FFT_Radix2_Q15::cmul_q15(Complex a, Complex b) {
    int32_t arbr = (int32_t)a.real * (int32_t)b.real;
    int32_t aibi = (int32_t)a.imag * (int32_t)b.imag;
    int32_t arbi = (int32_t)a.real * (int32_t)b.imag;
    int32_t aibr = (int32_t)a.imag * (int32_t)b.real;

    int32_t real_q15 = (arbr - aibi + (1 << 14)) >> 15;
    int32_t imag_q15 = (arbi + aibr + (1 << 14)) >> 15;

    Complex y;
    y.real = sat16(real_q15);
    y.imag = sat16(imag_q15);
    return y;
}

// -----------------------------
// Bit reversal
// -----------------------------
void FFT_Radix2_Q15::bit_reverse_reorder_incr(Complex* x, uint32_t N) const {
    uint32_t j = 0;
    for (uint32_t i = 0; i < N; ++i) {
        if (i < j) std::swap(x[i], x[j]);

        uint32_t bit = N >> 1;
        while (j & bit) {
            j ^= bit;
            bit >>= 1;
        }
        j ^= bit;
    }
}

// -----------------------------
// FFT stages
// -----------------------------
void FFT_Radix2_Q15::two_point_fft(Complex* x) const {
    Complex a = x[0];
    Complex b = x[1];

    x[0].real = add_sat_s1(a.real, b.real);
    x[0].imag = add_sat_s1(a.imag, b.imag);
    x[1].real = sub_sat_s1(a.real, b.real);
    x[1].imag = sub_sat_s1(a.imag, b.imag);
}

void FFT_Radix2_Q15::four_point_fft_from_2pt_results(Complex* x, const Twiddle_Factor_Table& W4T) const {
    Complex E0 = x[0];
    Complex E1 = x[1];
    Complex O0 = x[2];
    Complex O1 = x[3];

    Complex W0 = W4T.Twiddle_Factors[0]; // 1
    Complex W1 = W4T.Twiddle_Factors[1]; // -j

    Complex t0 = cmul_q15(O0, W0);
    Complex t1 = cmul_q15(O1, W1);

    x[0].real = add_sat_s1(E0.real, t0.real);
    x[0].imag = add_sat_s1(E0.imag, t0.imag);

    x[2].real = sub_sat_s1(E0.real, t0.real);
    x[2].imag = sub_sat_s1(E0.imag, t0.imag);

    x[1].real = add_sat_s1(E1.real, t1.real);
    x[1].imag = add_sat_s1(E1.imag, t1.imag);

    x[3].real = sub_sat_s1(E1.real, t1.real);
    x[3].imag = sub_sat_s1(E1.imag, t1.imag);
}

void FFT_Radix2_Q15::eight_point_fft(Complex* x, const Twiddle_Factor_Table& W8T) const {
    Complex E[4], O[4];
    for (int k = 0; k < 4; ++k) {
        E[k] = x[k];
        O[k] = x[k + 4];
    }

    for (int k = 0; k < 4; ++k) {
        Complex Wk = W8T.Twiddle_Factors[k];
        Complex t = cmul_q15(O[k], Wk);

        x[k].real = add_sat_s1(E[k].real, t.real);
        x[k].imag = add_sat_s1(E[k].imag, t.imag);
        x[k + 4].real = sub_sat_s1(E[k].real, t.real);
        x[k + 4].imag = sub_sat_s1(E[k].imag, t.imag);
    }
}

// Atomic radix-2 DIT butterfly (Q15)
// y0 = a + W*b
// y1 = a - W*b
// Scaling: +/− stage results are scaled by 1 (>>1) via add_sat_s1/sub_sat_s1
inline void FFT_Radix2_Q15::butterfly_dit_q15_s1(
    const Complex& a,
    const Complex& b,
    const Complex& W,
    Complex& y0,
    Complex& y1
) const {
    // t = W * b (Q15)
    Complex t = cmul_q15(b, W);

    // y0 = a + t, y1 = a - t (each scaled by 1 bit with saturation)
    y0.real = add_sat_s1(a.real, t.real);
    y0.imag = add_sat_s1(a.imag, t.imag);

    y1.real = sub_sat_s1(a.real, t.real);
    y1.imag = sub_sat_s1(a.imag, t.imag);
}

// Assumes:
// - N and LOG2N are compile-time constants (e.g., static constexpr int N=...; LOG2N=...)
// - Wt.Twiddle_Factors has at least N/2 entries for an N-point FFT
// - butterfly_dit_q15_s1(a,b,W,y0,y1) exists

void FFT_Radix2_Q15::FFT_Stage_DIT(int stage, Complex* x, const Twiddle_Factor_Table& Wt) const {
    const int m = 1 << (stage + 1); // group size
    const int half_m = m >> 1;
    const int step = N / m;            // twiddle step for this stage

    for (int k = 0; k < N; k += m) { // k m = basically what point FFT is being taken in the stage 
        for (int j = 0; j < half_m; ++j) { // butterfly within the group used iterativly for comptuing the m point FFT
            const int i0 = k + j;
            const int i1 = i0 + half_m;

            const Complex a = x[i0];
            const Complex b = x[i1];
            const Complex W = Wt.Twiddle_Factors[j * step];

            Complex y0, y1;
            butterfly_dit_q15_s1(a, b, W, y0, y1);

            x[i0] = y0;
            x[i1] = y1;
        }
    }
}


void FFT_Radix2_Q15::FFT_Core_DIT(Complex* x, const Twiddle_Factor_Table& Wt) const {
    for (int stage = 0; stage < LOG2N; ++stage) {
        FFT_Stage_DIT(stage, x, Wt);
    }


}