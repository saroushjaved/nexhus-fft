import math

N = 1024


def float_to_q15_hex(x):

    if x >= 0.999969:
        x = 0.999969
    if x < -1:
        x = -1

    val = int(round(x * 32768))

    if val < 0:
        val = (1 << 16) + val

    return f"0x{val:04X}"


def write_complex_file(filename, real, imag):

    with open(filename, "w") as f:
        for r, i in zip(real, imag):
            f.write(f"{float_to_q15_hex(r)} {float_to_q15_hex(i)}\n")

    print("Generated:", filename)


# # ------------------------------------------------
# # 1️⃣ Sinusoid
# # ------------------------------------------------

# k = 37
# A = 0.7

# real = []
# imag = []

# for n in range(N):
#     val = A * math.cos(2 * math.pi * k * n / N)
#     real.append(val)
#     imag.append(0.0)

# write_complex_file("sinusoid_16_input.txt", real, imag)


# # # ------------------------------------------------
# # # 2️⃣ Impulse
# # # ------------------------------------------------

# real = [0.0] * N
# imag = [0.0] * N

# real[0] = 0.9

# write_complex_file("impulse_1024_input.txt", real, imag)


# ------------------------------------------------
# 3️⃣ Mixed tones
# ------------------------------------------------

k1 = 13
k2 = 121
k3 = 333

A1 = 0.55
A2 = 0.30
A3 = 0.20

real = []
imag = []

for n in range(N):

    val = (
        A1 * math.cos(2 * math.pi * k1 * n / N) +
        A2 * math.cos(2 * math.pi * k2 * n / N) +
        A3 * math.cos(2 * math.pi * k3 * n / N)
    )

    real.append(val)
    imag.append(0.0)

write_complex_file("mixed_1024_input.txt", real, imag)


print("\nAll FFT test vectors generated.")