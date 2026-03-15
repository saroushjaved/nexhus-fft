# NEXHUS IP — `FFT`

> **Fixed-point FFT Implementations IP with C++ and Octave reference model, Synthesizable Verilog RTL and Test Benches**

# nexhus-fft

**nexhus-fft** is a hardware implementation of a fixed-point Fast Fourier Transform (FFT) accelerator written in SystemVerilog. The design targets FPGA/ASIC environments and provides a modular radix-2 FFT architecture with AXI-based interfaces for control and memory access.

The accelerator operates on complex samples in **Q1.15 fixed-point format** and performs staged butterfly computations using a configurable pipeline architecture. Twiddle factors are stored in ROM and accessed during each stage of the FFT computation.

The project is structured to separate **control logic, memory interfaces, and FFT processing cores**, allowing the design to be easily integrated into larger SoC systems.

## Key Features

- Radix-2 FFT architecture
- Q1.15 fixed-point complex arithmetic
- Modular SystemVerilog design
- AXI4-Lite control interface
- AXI memory interface for sample loading and retrieval
- Twiddle ROM for efficient coefficient access
- Stage-based FFT processing pipeline

## Repository Structure

nexhus-fft/
│
├── model/
│   └── radix_2/
│       └── (Contains the C model)
│
├── rtl/
│   └── radix_2/
│       ├── source/        (Contains design files)
│       ├── simulation/    (Contains the testbenches)
│       └── memory/        (Contains memory files)
│
├── specs/
│   └── (Detailed markdown document containing the specifications)
│
├── vectors/
│   └── radix_2/
│       ├── golden/            (Golden input vectors)
│       ├── vector_generator/  (Python scripts used to generate additional golden vectors)
│       └── results/           (Simulation result summaries and comparison files)
│
└── documentation/
    └── architecture/
        └── (Detailed documentation of the architecture)

