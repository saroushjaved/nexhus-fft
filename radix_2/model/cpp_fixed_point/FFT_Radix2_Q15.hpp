#pragma once

#include <cstdint>


// Compile time constants
static constexpr int N      = 8/* power of two */;
static constexpr int LOG2N  = 3/* log2(N) */;

// -----------------------------
// Q15 Complex + helpers
// -----------------------------
struct Complex {
    int16_t real;
    int16_t imag;
};

// -----------------------------
// Twiddle tables (no new/delete)
// -----------------------------
struct Twiddle_Factor_Table {
    int N;
    const Complex* Twiddle_Factors;
};

class FFT_Radix2_Q15 {
public:
    FFT_Radix2_Q15(); // sets up W4T and W8T to point at internal tables

    // Accessors for twiddle tables (so main can keep same calls)
    const Twiddle_Factor_Table& W4T() const { return W4T_; }
    const Twiddle_Factor_Table& W8T() const { return W8T_; }

    // Keep your pipeline calls the same, but as class methods:
    void bit_reverse_reorder_incr(Complex* x, uint32_t N) const;

    void two_point_fft(Complex* x) const;
    void four_point_fft_from_2pt_results(Complex* x, const Twiddle_Factor_Table& W4T) const;
    void eight_point_fft(Complex* x, const Twiddle_Factor_Table& W8T) const;
      // Atomic radix-2 DIT butterfly core (Q15, scaled by 1 bit)
    void butterfly_dit_q15_s1(
        const Complex& a,
        const Complex& b,
        const Complex& W,
        Complex& y0,
        Complex& y1
    ) const;

    Twiddle_Factor_Table W4T_;
    Twiddle_Factor_Table W8T_;

      void FFT_Stage_DIT(
        int stage,
        Complex* x,
        const Twiddle_Factor_Table& Wt
    ) const;


    void FFT_Core_DIT(
        Complex* x,
        const Twiddle_Factor_Table& Wt
    ) const;


private:
    // helpers
    static int16_t sat16(int32_t x);
    static int16_t add_sat_s1(int16_t a, int16_t b);
    static int16_t sub_sat_s1(int16_t a, int16_t b);

    static int16_t q15_mul_rnd_sat(int16_t a, int16_t b);
    static Complex cmul_q15(Complex a, Complex b);

private:
    // Twiddle tables as class-owned constants
    static constexpr Complex W4_TW_[4] = {
        { (int16_t)0x7FFF, (int16_t)0x0000 }, //  1 + j0
        { (int16_t)0x0000, (int16_t)0x8000 }, //  0 - j1  (-j)
        { (int16_t)0x8000, (int16_t)0x0000 }, // -1 + j0
        { (int16_t)0x0000, (int16_t)0x7FFF }  //  0 + j1  (+j)
    };

    static constexpr Complex W8_TW_[8] = {
        { (int16_t)0x7FFF, (int16_t)0x0000 }, // +1.0 + 0.0j
        { (int16_t)0x5A82, (int16_t)0xA57E }, // +0.7071 - 0.7071j
        { (int16_t)0x0000, (int16_t)0x8000 }, // +0.0   - 1.0j
        { (int16_t)0xA57E, (int16_t)0xA57E }, // -0.7071 - 0.7071j
        { (int16_t)0x8000, (int16_t)0x0000 }, // -1.0 + 0.0j
        { (int16_t)0xA57E, (int16_t)0x5A82 }, // -0.7071 + 0.7071j
        { (int16_t)0x0000, (int16_t)0x7FFF }, // +0.0   + 1.0j
        { (int16_t)0x5A82, (int16_t)0x5A82 }  // +0.7071 + 0.7071j
    };



};

  