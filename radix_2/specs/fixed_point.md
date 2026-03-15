
# Fixed-Point Specification (Radix-2 FFT, Q15)

## Data Format
- Complex samples use **Q1.15 signed fixed-point**
- Type:
```
int16_t real, imag
```
- Range: −1.0 to +0.99997

## Twiddle Factors
- Precomputed constants in **Q1.15**
- Stored as `constexpr` tables
- No runtime generation or dynamic memory

## Arithmetic
- Internal accumulations use **32-bit**
- Results are **saturated to 16-bit**

### Multiply
- Q15 × Q15 → Q30
- Rounded, then shifted right by 15
- Saturated to Q15

### Add / Subtract
- `(a ± b) >> 1` (1-bit stage scaling)
- Saturated to Q15

## Scaling Strategy
- **1-bit right shift per FFT stage**
- For N=8 (3 stages): overall scale = **1/8**
- Prevents overflow at all stages

## FFT Structure
- Radix-2 Decimation-in-Time
- In-place computation
- Bit-reversed input ordering

## Purpose
- Bit-accurate software reference
- Golden model for RTL and verification
---

