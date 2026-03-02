import math

def q15(x: float) -> int:
    v = int(round(x * 32768.0))
    v = min(32767, max(-32768, v))
    return v & 0xFFFF  # 16-bit two's complement

def print_twiddle_table(N=1024, pad_to_n=True):
    half = N // 2

    # Print actual twiddle factors
    for k in range(half):
        re = q15(math.cos(2 * math.pi * k / N))
        im = q15(-math.sin(2 * math.pi * k / N))  # imag = -sin
        print(f"{re:04X}{im:04X}")

    # Optional zero padding to N entries
    if pad_to_n:
        for _ in range(N - half):
            print("00000000")

print_twiddle_table(1024)