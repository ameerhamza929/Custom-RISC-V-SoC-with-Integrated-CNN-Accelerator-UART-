# Custom RISC-V SoC with Integrated CNN Accelerator and UART

This repository contains the RTL design of a complete RISC-V-based System-on-Chip (SoC) that integrates a pipelined CPU core, on-chip memory, UART peripheral, and a hardware convolution engine (CNN accelerator). The project is implemented in Verilog/SystemVerilog with Tcl scripts used for build and tool automation.

## Project Overview

The goal of this project is to demonstrate a compact, synthesizable SoC design that couples a RISC-V processor pipeline with a specialized convolution accelerator to offload and speed up CNN inference workloads. The SoC also includes a simple UART for host communication and memory subsystems to store program code and data.

Key components:
- Pipelined RISC-V CPU core (RV32I subset compatible)
- On-chip memory (instruction and data memories)
- UART peripheral for serial I/O and debugging
- Convolution engine (CNN accelerator) for 2D convolution operations used in neural networks
- Top-level interconnect and bus logic to connect CPU, memory and peripherals

## Repository Composition

Primary languages used in this repository:
- Verilog
- SystemVerilog
- Tcl (tool/project scripts)

Expected repository structure (high-level):

- /rtl
  - cpu/            — RISC-V core RTL (pipeline stages, ALU, register file, control)
  - mem/            — RAM, ROM, memory wrappers
  - periph/         — UART and other peripheral RTL
  - cnn/            — Convolution engine RTL and support modules
  - top.sv          — Top-level SoC module connecting all components
- /tb
  - testbenches/    — Simulation testbenches for CPU, UART, CNN and integration tests
- /scripts
  - *.tcl           — Tool automation scripts (synthesis, simulation, board/project setup)
- /docs
  - design_notes.md — Design rationale, diagrams, and interface descriptions

Note: exact layout may differ — consult the repository tree for precise file locations.

## Getting Started

Prerequisites
- Verilog/SystemVerilog simulator (Icarus Verilog, ModelSim/QuestaSim, VCS, etc.)
- FPGA toolchain (if you plan to synthesize/implement for an FPGA) — e.g., Xilinx Vivado or Intel Quartus
- Make (optional) or a shell environment to run provided Tcl scripts

Quick simulation example (generic)

1. Open a shell at the repository root.
2. If a provided simulation script exists, run it. Example:

   ./scripts/run_sim.sh  # or check scripts/*.tcl for vendor-specific commands

3. Or run a simple Icarus Verilog flow (example):

   iverilog -g2012 -o build/sim.vvp $(find rtl -name "*.v" -o -name "*.sv") tb/testbench_top.sv
   vvp build/sim.vvp

4. Inspect waveforms with GTKWave (if produced):

   gtkwave build/wave.vcd

Synthesis / FPGA flow

- There are Tcl scripts under /scripts that can be used to create vendor projects and run synthesis/implementation. For Xilinx Vivado, a typical start would be:

  vivado -mode batch -source scripts/create_project.tcl

- Consult the scripts directory for exact command names and required arguments.

## CNN Accelerator Usage

The convolution engine is designed as a hardware module that accepts input feature maps, kernel weights, and outputs convolved results. Typical integration steps:
- Load kernel weights and input data into memory or provide them through a host interface
- Configure the accelerator control/status registers (CSRs) from the CPU
- Start the accelerator and poll/interrupt on completion

See the cnn module RTL and testbenches for example register maps and usage patterns.

## UART

The UART peripheral provides a basic serial console for printing debug messages and communicating with a host. Use a baud rate and pin mapping suitable for your target board. Check the periph/uart RTL and testbench for usage examples.

## Tests and Verification

- Unit-level testbenches for CPU pipeline stages, ALU and register file
- Integration testbench that boots a simple RISC-V program and exercises memory, UART and the CNN accelerator
- Use functional simulation to verify correctness before attempting synthesis

## Contributing

Contributions are welcome. Suggested ways to contribute:
- Bug fixes and correctness improvements
- Improved testbenches and coverage (add assertions and randomized tests)
- Documentation and design diagrams
- Performance optimizations for the CNN engine

Please open issues and pull requests with detailed descriptions of changes.

## License

If a license isn't present in the repository, add one (for example, MIT or Apache-2.0) to make reuse and contribution clear. If you want me to add a specific license file, tell me which license to use and I can create it.

## Contact

For questions or help, open an issue in this repository or contact the maintainer: @ameerhamza929

---

This README provides a concise introduction and instructions to get started. If you want, I can:
- Expand the Usage section with exact simulation and synthesis commands based on the repository's scripts
- Add block diagrams and example test vectors to /docs
- Create a LICENSE file (specify which license)
