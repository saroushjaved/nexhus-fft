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
                    (In case you need to change Twiddle Memeory File Change it in this Module)
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

## Specifications

The following table summarizes the key specifications and design characteristics of the **nexhus-fft radix-2 FFT accelerator**.

| Parameter               | Description                                                                                |
| ----------------------- | ------------------------------------------------------------------------------------------ |
| FFT Algorithm           | Radix-2 Decimation-in-Time (DIT) FFT                                                       |
| Implementation Language | SystemVerilog                                                                              |
| Numeric Format          | Signed fixed-point **Q1.15** for real and imaginary components                             |
| Complex Sample Width    | 32 bits (16-bit real + 16-bit imaginary)                                                   |
| Arithmetic Precision    | 16-bit signed fixed-point                                                                  |
| Multiplication          | 16×16 signed fixed-point complex multiplication                                            |
| Scaling Strategy        | Per-stage scaling using arithmetic right shift to control overflow                         |
| Butterfly Operation     | Radix-2 butterfly with complex twiddle multiplication                                      |
| Twiddle Storage         | Precomputed twiddle factors stored in ROM                                                  |
| Twiddle Format          | Q1.15 complex values                                                                       |
| Memory Organization     | Internal memory used to store input samples, intermediate stage results, and final outputs |
| Architecture Type       | Stage-based FFT architecture                                                               |
| Processing Unit         | Butterfly processing unit with complex multiplier and add/sub stage                        |
| Memory Access           | External interface allows loading input vectors and reading FFT results                    |
| Control Interface       | Control logic used to start FFT execution and monitor completion                           |
| Verification Method     | RTL simulation compared against C reference model                                          |
| Test Vectors            | Golden vectors generated from the reference model                                          |
| Result Validation       | Simulation results compared against golden outputs                                         |
| N                       | Current Implementation if done for 1024 Points FFT                                         |



## Configurable Parameters

The top-level FFT accelerator is parameterized to allow changes in FFT length and AXI interface sizing without modifying the module internals.

| Parameter    | Description                                                                                                           |
| ------------ | --------------------------------------------------------------------------------------------------------------------- |
| `N`          | Number of FFT points. This defines the transform size and the number of complex samples processed by the accelerator. |
| `AXI_ADDR_W` | Width of the AXI address bus in bits. This determines the addressable range seen by the AXI interfaces.               |
| `AXI_DATA_W` | Width of the AXI data bus in bits. This defines the size of each AXI data transfer word.                              |
| `AXI_ID_W`   | Width of the AXI transaction ID field. This is used for AXI transaction tagging and response matching.                |

### Default Parameter Values

| Parameter    | Default Value |
| ------------ | ------------- |
| `N`          | `1024`        |
| `AXI_ADDR_W` | `16`          |
| `AXI_DATA_W` | `32`          |
| `AXI_ID_W`   | `4`           |

### Notes

* `N` should be a power of two for radix-2 FFT operation.
* Increasing `N` increases the number of FFT stages.
* `AXI_ADDR_W`, `AXI_DATA_W`, and `AXI_ID_W` allow the accelerator to be adapted to different system bus configurations.

## External Interfaces

| Interface | Purpose                      |
| --------- | ---------------------------- |
| AXI4-Lite | Control and status registers |
| AXI4      | Sample memory access         |



## Supported FFT Sizes

The FFT accelerator is designed to support **power-of-two transform sizes** using a radix-2 Decimation-in-Time (DIT) algorithm. The FFT length is controlled by the top-level parameter `N`.

| Parameter             | Description                                       |
| --------------------- | ------------------------------------------------- |
| `N`                   | Number of FFT points processed by the accelerator |
| Constraint            | `N` must be a power of two                        |
| Number of Stages      | `log₂(N)`                                         |
| Butterflies per Stage | `N / 2`                                           |

Changing `N` automatically changes the number of stages executed by the FFT controller.

Typical supported sizes include:

| FFT Size (N) | Stages |
| ------------ | ------ |
| 16           | 4      |
| 64           | 6      |
| 256          | 8      |
| 1024         | 10     |

The current configuration of the design uses **N = 1024**.

---

## Numeric Representation

The FFT datapath uses **signed fixed-point arithmetic**.

| Parameter            | Value             |
| -------------------- | ----------------- |
| Format               | Q1.15 fixed-point |
| Real width           | 16 bits           |
| Imaginary width      | 16 bits           |
| Complex sample width | 32 bits           |

### Complex Sample Packing

Complex samples are stored as a packed 32-bit value:

| Bits      | Content             |
| --------- | ------------------- |
| `[31:16]` | Real component      |
| `[15:0]`  | Imaginary component |

### Arithmetic Behavior

FFT butterfly operations involve:

* complex multiplication
* addition
* subtraction
* arithmetic right shifting for scaling

Intermediate values may temporarily expand in width during multiplication or addition, after which results are scaled and truncated back to **16-bit Q1.15 format**.

---

## Scaling

The FFT datapath uses **Q1.15 fixed-point arithmetic**, where each real and imaginary component is represented using 16-bit signed values with 15 fractional bits.

During complex multiplication, the intermediate products expand in precision:

* `Q1.15 × Q1.15 → Q2.30`

This occurs because each 16-bit fixed-point multiplication produces a **32-bit result with 30 fractional bits**.

### Rescaling to Q1.15

To return the result to Q1.15 format, the accumulator outputs are shifted right by 15 bits:

| Operation        | Expression               |
| ---------------- | ------------------------ |
| Real accumulator | `real_acc = arbr - aibi` |
| Imag accumulator | `imag_acc = arbi + aibr` |

Before shifting, a rounding offset is applied:

| Step     | Expression                            |
| -------- | ------------------------------------- |
| Rounding | `real_acc_rnd = real_acc + (1 << 14)` |
|          | `imag_acc_rnd = imag_acc + (1 << 14)` |
| Rescale  | `real_q15 = real_acc_rnd >>> 15`      |
|          | `imag_q15 = imag_acc_rnd >>> 15`      |

This rounding improves numeric accuracy compared to simple truncation.

### Saturation

After rescaling, the results are **saturated to the signed 16-bit range**:

| Range   | Value    |
| ------- | -------- |
| Maximum | `+32767` |
| Minimum | `-32768` |

The final outputs are therefore valid **Q1.15 complex values** that can be used directly by the butterfly arithmetic units.


## Memory Layout

The FFT uses an internal memory structure to store:

* input samples
* intermediate stage results
* final FFT outputs

Samples are stored sequentially in memory.

| Address | Content    |
| ------- | ---------- |
| `0`     | Sample 0   |
| `1`     | Sample 1   |
| `2`     | Sample 2   |
| ...     | ...        |
| `N-1`   | Sample N-1 |

Each memory entry stores **one complex sample** packed into 32 bits.

The FFT computation operates **in-place**, meaning intermediate results overwrite previous stage data within the same memory array.

---

## FFT Execution Flow

The FFT accelerator executes the transform in a sequence of stages controlled by the FFT controller.

### Execution Steps

1. **Load Input Samples**
   Input vectors are written into the internal sample memory.

2. **Start FFT**
   A start signal is issued through the control interface.

3. **Stage Iteration**
   The controller iterates through `log₂(N)` stages.

4. **Butterfly Computation**
   Each stage performs `N/2` butterfly operations.

5. **Memory Update**
   Results from each butterfly overwrite the previous data in memory.

6. **Completion**
   After the final stage completes, the FFT output samples are available in memory.

---

## Radix-2 Butterfly Operation

The radix-2 butterfly is the fundamental computational unit of the FFT.

Given two complex inputs:

```
A
B
```

and a twiddle factor `W`, the butterfly performs:

```
T = B × W
X = A + T
Y = A − T
```

Where:

* `T` is the complex multiplication result
* `X` and `Y` are the butterfly outputs

These outputs replace the original inputs in memory during stage processing.

---

## Twiddle Factor Storage

Twiddle factors are the complex exponential coefficients required during FFT stage computations.

They are defined as:

```
W_N^k = e^{-j2πk/N}
```

where:

| Symbol | Meaning       |
| ------ | ------------- |
| `N`    | FFT size      |
| `k`    | Twiddle index |

### Storage

Twiddle factors are stored in a **ROM module** within the design.

| Property     | Description                       |
| ------------ | --------------------------------- |
| Storage type | Read-only memory                  |
| Format       | Q1.15 complex values              |
| Access       | Addressed by the stage controller |

The stage controller generates the appropriate twiddle address for each butterfly operation.

---

## Verification Flow

Verification of the FFT accelerator is performed using a **reference model and golden vectors**.

### Verification Process

1. **Reference Model**
   A C implementation of the radix-2 FFT generates reference outputs.

2. **Golden Vector Generation**
   The reference model produces input vectors and corresponding expected FFT results.

3. **RTL Simulation**
   The SystemVerilog testbench feeds the golden inputs to the RTL design.

4. **Result Comparison**
   Simulation outputs are compared against the golden results.

5. **Summary Generation**
   Comparison results are stored and summarized in the `vectors/results` directory.

### Verification Flow

```
C Model
   │
   ▼
Golden Vectors
   │
   ▼
RTL Simulation
   │
   ▼
Result Comparison
```
