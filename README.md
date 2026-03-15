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
```
nexhus-fft/
│
├── model/
│   └── radix_2/
│       └── (Contains the C model)
│   └── visual_studio/
│       └── (Contains the C model and Visual Studio Project)
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

```

## Hardware Architecture

The **nexhus-fft** hardware architecture implements a radix-2 Fast Fourier Transform (FFT) accelerator designed using SystemVerilog. The architecture follows a staged butterfly computation model where complex input samples are processed through multiple FFT stages to produce the frequency-domain output.

The design is organized into modular components responsible for control, memory access, and FFT computation. This separation allows the FFT engine to be easily integrated into larger hardware systems.

### Core Architecture Components

The architecture is composed of the following major components:

**FFT Control Interface**

The control block provides the software interface used to configure and trigger the FFT computation. Control registers allow the host system to start the accelerator and monitor its execution status.

**Memory Interface**

Input samples and output results are stored in an internal memory structure accessible through the memory interface. This interface allows external software or testbenches to load input vectors and retrieve FFT results.

**FFT Processing Core**

The FFT core performs the radix-2 butterfly computations across multiple stages. Each stage processes pairs of samples using twiddle factors and produces intermediate results that are written back to memory.

**Butterfly Arithmetic Units**

The butterfly unit performs the core mathematical operations required by the FFT algorithm, including:

* complex multiplication with twiddle factors
* addition and subtraction operations
* fixed-point scaling and saturation

These operations are implemented using dedicated arithmetic modules to maintain modularity and reusability.

**Twiddle Factor Storage**

Twiddle factors required for the FFT computation are stored in a ROM module. The FFT stages access these coefficients during butterfly computations.

### Execution Flow

1. Input samples are loaded into memory.
2. The control interface starts the FFT computation.
3. The FFT core iterates through each stage of the radix-2 algorithm.
4. Butterfly operations are executed using twiddle factors from ROM.
5. Intermediate results are written back to memory after each stage.
6. Once all stages are complete, the final FFT results are available in memory.

This staged architecture allows the FFT accelerator to efficiently compute the transform while maintaining a clear separation between control logic, data storage, and computation units.

## Module Hierarchy

The RTL implementation of the radix-2 FFT accelerator is organized as a hierarchy of modules, where the top-level FFT controller manages stage execution and memory access while lower-level modules implement the butterfly arithmetic operations.

The module hierarchy is shown below.

```
fft_accel_fft_top
│
├── fft_ctrl_axil
│
├── fft_mem_axi4_slave
│
├── fft_loadstore_wrapper
│   └── fft_top
│       │
│       └── fft_stage_core_controller
│           │
│           ├── fft_stage_core
│           │   └── fft_atomic_p1
│           │       ├── cmulq15
│           │       └── add_sub_sat_s1_q15
│           │
│           └── twiddle_rom
```

### Description

**fft_accel_fft_top**
Top-level integration module that connects the FFT processing core, memory interface, and control interface.

**fft_ctrl_axil**
Implements the AXI4-Lite control interface used to start the FFT operation and monitor its status.

**fft_mem_axi4_slave**
Provides an AXI4 memory-mapped interface for reading and writing FFT data memory.

**fft_loadstore_wrapper**
Handles memory transactions between the AXI memory interface and the FFT processing core.

**fft_top**
Top-level controller for the FFT engine. It sequences the FFT stages and coordinates execution of the stage controller.

**fft_stage_core_controller**
Manages the execution of a single FFT stage and controls access to the internal sample memory.

**fft_stage_core**
Implements the logic required to perform butterfly computations for one FFT stage.

**fft_atomic_p1**
Atomic butterfly processing unit that performs the core radix-2 butterfly operation.

**cmulq15**
Performs complex multiplication using Q1.15 fixed-point arithmetic.

**add_sub_sat_s1_q15**
Performs the butterfly addition and subtraction with fixed-point scaling and saturation.

**twiddle_rom**
ROM containing the twiddle factors used during FFT stage computations.
