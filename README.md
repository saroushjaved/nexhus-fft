# NEXHUS IP — `FFT`
## STATUS: UNDER DEVELOPMENT

> **Fixed-point Radix-2 FFT IP with C reference model, MATLAB golden vectors, and synthesizable RTL**

---

## Overview

This repository contains the **`FFT`** block developed as part of the **NEXHUS** open-source hardware project.

The IP is designed following a **spec → model → software → RTL → verification** flow:

1. Mathematical reference model (MATLAB)
2. Bit-accurate fixed-point software model (C/C++)
3. Synthesizable RTL
4. Verification against frozen golden vectors

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
|   ├── spec/                 # IP specification and interface definitions
|   ├── model/
|   │   └── matlab/           # Reference model + vector generation
|   │   └── cpp/              # Reference model + vector generation
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

## Integration into NEXHUS

This IP is integrated into the main **`nexhus`** repository as a **git submodule**, pinned to a specific release.

Example:

```bash
git submodule add <repo-url> ip/<ip_name>
```

---

## License


## Contributing

Contributions are welcome.

Please:

* follow the coding style
* update tests and vectors if behavior changes
* run CI locally before submitting

See `CONTRIBUTING.md` for details.

---

## Status

| Component      | Status |
| -------------- | ------ |
| Spec           | ✅      |
| MATLAB model   | ✅      |
| Software model | 🚧     |
| RTL            | 🚧     |
| Verification   | 🚧     |

---

## Contact

Maintained as part of the **NEXHUS** open-source project.

---

### 🔒 Final recommendation (important)

