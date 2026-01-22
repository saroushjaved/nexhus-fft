# NEXHUS IP — `FFT`
## STATUS: UNDER DEVELOPMENT

> **Fixed-point FFT Implementations IP with C++ and Octave reference model, Synthesizable Verilog RTL and Test Benches**

---

## Overview

This repository contains the **`FFT`** block developed as part of the **NEXHUS** open-source hardware project.

The IP is designed following a **spec → model → software → RTL → verification** flow:

1. Mathematical reference model (Octave)
2. Bit-accurate fixed-point software model (C/C++/Octave)
3. Synthesizable RTL

This IP can be:

* used standalone
* integrated into the NEXHUS SoC
* reused in external projects

---

## Features

* Fixed-point implementation (Q-format: Q1.15)
* Deterministic rounding and saturation
* Bit-accurate across MATLAB, C, and RTL
* Parameterizable (size / width / stages, if applicable)
* Fully verifiable with golden vectors
---

## Repository Structure

```
|___radix_2/
|   ├── spec/                             # IP specification and interface definitions
|   ├── model/
|   │   └── octave/                       # Reference model + vector generation
|   │   └── cpp_fixed_point/              # Reference model + vector generation
|   ├── sw/
|   │   ├── include/          # Public headers
|   │   ├── src/              # Implementation
|   │   ├── tests/            # Unit tests vs golden vectors
|   │   └── examples/         # Usage examples
|   ├── rtl/
|   │   └── src/              # Synthesizable RTL
|   ├── dv/
|   │   ├── testbench/        # Verification environment
|   │   └── tests/            # Directed and random tests
|   ├── vectors/
|   │   ├── golden/           # Frozen reference vectors (versioned)
|   │   └── generated/        # Auto-generated (ignored)
|   ├── tools/                # Helper scripts
|   └── .github/workflows/    # CI
|___radix_3
```

---

## Specifications

Key design parameters are defined in:

* `spec/FFT_spec.md`
* `spec/fixed_point.md`

These documents define:

* input/output formats
* internal scaling rules
* rounding and saturation behavior
* latency and throughput
* interfaces and timing assumptions
---

## Fixed-Point Conventions

This IP follows the *The Following Conventions*

See `spec/fixed_point.md` for details.

---


## License

## Contributing

## Contact

Email: saroushjaved@gmail.com
