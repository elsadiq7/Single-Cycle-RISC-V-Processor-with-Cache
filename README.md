# Cache Controller Implementation with Write-Through Policy

- **Data Memory**: Only the data memory will be cached; instruction memory remains unaffected.
- **Cache Level**: The system will implement only one level of caching.
- **Main Memory Capacity**: 4 Kbytes (word addressable with 10 bits or byte addressable with 12 bits).
- **Access Time**: Main memory access (for read or write) takes 4 clock cycles.
- **Cache Geometry**: Data cache specifications are (512, 16, 1), which implies:
  - Total cache capacity: 512 bytes
  - Each cache block: 16 bytes
  - Total blocks: 32
  - Cache mapping: Direct mapping
- **Write Policy**: Implements write-through and write-around policies for write hit and miss handling; no write buffers exist.
  - SW instructions will stall the processor.
  - LW instructions stall only on a miss.

To construct the caching system, the data memory in the single-cycle implementation is replaced with a new memory system module that includes:
- Cache memory module
- Cache controller module
- Data memory module

### Control Signal
The memory system features a stall control signal that temporarily halts the processor when necessary. The stall signal remains asserted until the processor can resume normal execution.

## Cache Controller Functionality
The cache controller manages the tags, valid bits, and uses the index and tag parts of the memory address to determine hits or misses. It generates the stall control signal and controls the cache and memory modules in four scenarios:

1. **Read Hit (LW Instruction)**:
   - No stall; data is read from the cache.

2. **Read Miss (LW Instruction)**:
   - Stall is asserted; data is fetched from the data memory. The data memory provides a block of data, and the cache controller fills the cache and deasserts the stall signal once the data is ready.

3. **Write Hit (SW Instruction)**:
   - Data is written to both cache memory and data memory (due to write-through policy). The stall signal is asserted until the memory confirms the write via its ready signal.

4. **Write Miss (SW Instruction)**:
   - Data is written only in the data memory (due to write-around policy), and the stall signal is asserted until the memory completes the operation.

## Implementation Details
- The cache controller requires the index and tag of the accessed address, along with access to the valid bits and tags corresponding to the cache blocks.
- The valid bits array is initialized to zeros for a cold cache start using a reset signal.
- Both the valid and tag arrays are updated when a new block is cached.

### Finite State Machine
The cache controller operates on the opposite clock edge from the PC and implements a finite state machine with three states: idle, reading, and writing:
- **Idle**: Initial state.
- **Reading**: Activated on a read miss.
- **Writing**: Activated on any write operation.
- The controller returns to the idle state once the operation is complete, ensuring correct timing for the stall signal.

## Deliverables
- Integrated code implementing the cache system.
- Testbench for various LW/SW program cases.
- Diagram of the implemented finite state machine.
