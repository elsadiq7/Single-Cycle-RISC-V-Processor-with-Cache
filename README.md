# Single Cycle RISC-V Processor with Cache

This project implements a single-cycle RISC-V processor with integrated cache memory, designed to enhance instruction execution efficiency and reduce memory access latency. 

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Microarchitecture Overview](#microarchitecture-overview)
- [Instructions Supported](#instructions-supported)
- [Cache Memory Summary](#cache-memory-summary)
- [Performance Analysis](#performance-analysis)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction

The RISC-V (Reduced Instruction Set Computing - Five) architecture is an open standard that provides a framework for designing processors. This project focuses on creating a single-cycle RISC-V processor that implements fundamental operations while integrating cache memory to optimize performance.

## Features

- Single-cycle execution for RISC-V instructions.
- Support for basic arithmetic and logical operations.
- Integration of cache memory for improved data retrieval speed.
- Comprehensive documentation of the microarchitecture and design decisions.

## Microarchitecture Overview

The microarchitecture of the processor is designed to efficiently handle RISC-V instructions. It consists of the following components:

- **Control Unit**: Generates control signals based on the opcode of the instruction.
- **Datapath**: Includes components such as the ALU (Arithmetic Logic Unit), registers, and memory.
- **Memory Interface**: Handles interaction with both cache and main memory.
  
### Control Signals

Key control signals include:
- `RegWrite`: Enables writing to the register file.
- `ALUSrc`: Determines the second operand for the ALU.
- `PCSrc`: Selects the next address for the program counter.

## Instructions Supported

The processor currently supports a subset of the RISC-V instruction set, including:

- **R-type Instructions**: Basic arithmetic and logical operations (e.g., add, sub).
- **I-type Instructions**: Immediate operations (e.g., addi).
- **J-type Instructions**: Jump operations (e.g., jal).

## Cache Memory Summary

Cache memory is integrated into the processor to reduce the time required for memory access. It stores frequently accessed data and instructions, significantly improving the overall execution speed of programs. The cache hierarchy optimizes data retrieval and allows for efficient instruction pipelining.

## Performance Analysis

The execution time of the processor is determined by the number of instructions and the critical path through which the instructions are processed. The cycle time is established based on the slowest instruction, ensuring synchronous operation across all components. 

### Example Performance Metrics

For a given program with 100 billion instructions, the total execution time can be calculated using the formula:

\[ \text{Execution Time} = \text{Number of Instructions} \times \text{Cycles per Instruction} \times \text{Cycle Time} \]


