# Single Cycle RISC-V Processor with Cache

This project implements a single-cycle RISC-V processor with integrated cache memory, designed to enhance instruction execution efficiency and reduce memory access latency. 

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Microarchitecture Overview](#microarchitecture-overview)
- [Supported Instructions](#supported-instructions)
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

## Supported Instructions

The processor currently supports the following RISC-V instructions:

| **op**      | **funct3** | **funct7** | **Type** | **Instruction** | **Description**                         | **Operation**                           |
|-------------|------------|------------|----------|----------------|-----------------------------------------|-----------------------------------------|
| 0000011     | 000        | -          | I        | lb             | load byte                               | rd = SignExt([Address]7:0)            |
| 0000011     | 001        | -          | I        | lh             | load half                               | rd = SignExt([Address]15:0)           |
| 0000011     | 010        | -          | I        | lw             | load word                               | rd = [Address]31:0                     |
| 0000011     | 100        | -          | I        | lbu            | load byte unsigned                      | rd = ZeroExt([Address]7:0)            |
| 0000011     | 101        | -          | I        | lhu            | load half unsigned                      | rd = ZeroExt([Address]15:0)           |
| 0010011     | 000        | -          | I        | addi           | add immediate                           | rd = rs1 + SignExt(imm)                |
| 0010011     | 001        | 0000000*   | I        | slli           | shift left logical immediate            | rd = rs1 << uimm                       |
| 0010011     | 010        | -          | I        | slti           | set less than immediate                 | rd = (rs1 < SignExt(imm))              |
| 0010011     | 011        | -          | I        | sltiu          | set less than immediate unsigned        | rd = (rs1 < SignExt(imm))              |
| 0010011     | 100        | -          | I        | xori           | xor immediate                           | rd = rs1 ^ SignExt(imm)                |
| 0010011     | 101        | 0000000*   | I        | srli           | shift right logical immediate           | rd = rs1 >> uimm                       |
| 0010011     | 101        | 0100000*   | I        | srai           | shift right arithmetic immediate        | rd = rs1 >>> uimm                      |
| 0010011     | 110        | -          | I        | ori            | or immediate                            | rd = rs1 | SignExt(imm)                  |
| 0010011     | 111        | -          | I        | andi           | and immediate                           | rd = rs1 & SignExt(imm)                |
| 0010111     | -          | -          | U        | auipc          | add upper immediate to PC               | rd = {upimm, 12'b0} + PC               |
| 0100011     | 000        | -          | S        | sb             | store byte                              | [Address]7:0 = rs2[7:0]                |
| 0100011     | 001        | -          | S        | sh             | store half                              | [Address]15:0 = rs2[15:0]              |
| 0100011     | 010        | -          | S        | sw             | store word                              | [Address]31:0 = rs2                     |
| 0110011     | 000        | 0000000    | R        | add            | add                                     | rd = rs1 + rs2                         |
| 0110011     | 000        | 0100000    | R        | sub            | subtract                                | rd = rs1 - rs2                         |
| 0110011     | 001        | 0000000    | R        | sll            | shift left logical                      | rd = rs1 << rs2[4:0]                   |
| 0110011     | 010        | 0000000    | R        | slt            | set less than                           | rd = (rs1 < rs2)                       |
| 0110011     | 011        | 0000000    | R        | sltu           | set less than unsigned                  | rd = (rs1 < rs2)                       |
| 0110011     | 100        | 0000000    | R        | xor            | xor                                     | rd = rs1 ^ rs2                         |
| 0110011     | 101        | 0000000    | R        | srl            | shift right logical                     | rd = rs1 >> rs2[4:0]                   |
| 0110011     | 101        | 0100000    | R        | sra            | shift right arithmetic                  | rd = rs1 >>> rs2[4:0]                  |
| 0110011     | 110        | 0000000    | R        | or             | or                                      | rd = rs1 | rs2                          |
| 0110011     | 111        | 0000000    | R        | and            | and                                     | rd = rs1 & rs2                          |
| 0110111     | -          | -          | U        | lui            | load upper immediate                    | rd = {upimm, 12'b0}                     |
| 1100011     | 000        | -          | B        | beq            | branch if equal                         | if (rs1 == rs2) PC = BTA               |
| 1100011     | 001        | -          | B        | bne            | branch if not equal                     | if (rs1 ≠ rs2) PC = BTA                 |
| 1100011     | 100        | -          | B        | blt            | branch if less than                    | if (rs1 < rs2) PC = BTA                 |
| 1100011     | 101        | -          | B        | bge            | branch if greater than or equal        | if (rs1 ≥ rs2) PC = BTA                 |
| 1100011     | 110        | -          | B        | bltu           | branch if less than unsigned           | if (rs1 < rs2) PC = BTA                 |
| 1100011     | 111        | -          | B        | bgeu           | branch if greater than or equal unsigned | if (rs1 ≥ rs2) PC = BTA                 |
| 1100111     | 000        | -          | I        | jalr           | jump and link register                  | PC = rs1 + SignExt(imm), rd = PC + 4   |
| 1101111     | -          | -          | J        | jal            | jump and link                           | PC = JTA, rd = PC + 4                   |

## Cache Memory Summary

Cache memory is integrated into the processor to reduce the time required for memory access. It stores frequently accessed data and instructions, significantly improving the overall execution speed of programs. The cache hierarchy optimizes data retrieval and allows for efficient instruction pipelining.

## Performance Analysis

The execution time of the processor is determined by the number of instructions and the critical path through which the instructions are processed. The cycle time is established based on the slowest instruction, ensuring synchronous operation across all components. 

## Performance Analysis

The execution time of the processor is determined by the number of instructions and the critical path through which the instructions are processed. The cycle time is established based on the slowest instruction, ensuring synchronous operation across all components. 

### Example Performance Metrics

For a given program with 100 billion instructions, the total execution time can be calculated using the formula:

\[ \text{Execution Time} = \text{Number of Instructions} \times \text{Cycles per Instruction} \times \text{Cycle Time} \]


