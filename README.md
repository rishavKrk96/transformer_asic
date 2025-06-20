# Dual-Core Machine Learning Accelerator for Attention Mechanism

**Date:** March 24, 2023

---

## Summary 

ASIC design from RTL to GDSII for a Low Power Dual Core Machine Learning Accelerator for Attention Mechanism in Transformers using a 1D Vector Processor Based Architecture. Developed the RTL for the accelerator in Verilog, synthesized the design on Synopsis Design Compiler, followed by floor planning, placement, clock tree synthesis, and routing on Cadence Innovus. Implemented techniques like pipelining in the MAC array to improve throughput, multicycle paths on long latency operations like fixed point divider to ease timing closure, a 4 phase req-ack handshake protocol for CDC between the two asynchronous cores, and Clock Gating to reduce dynamic power consumption.


## 1. Baseline Design

We implemented a dual-core machine learning accelerator for attention mechanisms using a 1D vector processor-based architecture. Each core features two MAC arrays for matrix multiplication and an SFP normalizer to normalize the output.

The baseline design enables a single core to compute the product of an R×8 Q matrix and an 8×8 K matrix, producing an R×8 output. Partial sums are written to a FIFO (OFIFO), then transferred to PMEM memory. The testbench loads QMEM and KMEM, controls MAC execution, and streams outputs to the SFP normalizer for normalization. The SFP normalizer accumulates input values and normalizes the data based on a divider triggered by a control pulse.

---

## 2. Key Optimizations

### 2.1 Pipelining
We added pipeline registers after multipliers and between adders in the MAC array to break timing-critical paths and improve performance.

### 2.2 Multicycle Path
To handle the latency of fixed-point division, we added a multicycle path constraint of 6 cycles to the divider in the SFP normalizer. This was essential to meet timing at a 1 GHz clock.

### 2.3 Handshake Protocol
A 4-phase handshake protocol was implemented to coordinate communication between the two cores, which operate asynchronously. This lightweight approach was chosen over asynchronous FIFOs to reduce power, as data transfer between cores only occurs once every 50–60 cycles.

### 2.4 Clock Gating
We introduced latch-based clock gating for the memories and MAC array. Clock gating is driven by enable signals and reduces dynamic power. Additionally, unused MAC array columns are gated based on the active width of the K matrix.

### 2.5 MAC Array Controller
A synthesizable controller was added to each core to manage MAC operations, memory access, and data flow to OFIFO. This replaces the testbench logic used in the baseline.

### 2.6 Reconfigurable Mode Operation
Our core supports multiple data formats:
- 4-bit signed QMEM × 4-bit unsigned KMEM
- 4-bit signed QMEM × 8-bit unsigned KMEM

In 4b/8b mode, partial sums from even and odd MAC columns are combined as:

Psum_final(n) = Psum_odd(n−1) + (Psum_even(n) << 4)


### 2.7 Thorough Verification
We developed a Python script to randomly generate Q and K matrices for thorough verification of various configurations. This improved test coverage and allowed flexible input dimensions.

---

## 3. Results and Observations

- **Timing:**  
  - Pipelining improved WNS (from -620ps to -1ps), but did not fully meet timing at 1 GHz.  
  - Final merged design had a worst-case slack of -37ps.

- **Power:**  
  - Bitwidth reduction to 4 bits in reconfigurable mode reduced total power by ~50%.  
  - Clock gating led to an 81% reduction in power consumption (VCD-based PnR simulation in Innovus).

- **Simulation:**  
  - Gate-level simulations passed at 500 MHz.  
  - Timing violations occurred at 1 GHz due to divider path.

- **DRC:**  
  - Final merged layout had 10 DRC violations (8 short circuits, 2 wiring).

---

## 4. Challenges Faced

### 4.1 X-Propagation in Gate-Level Simulation
Initially, we observed X-propagation due to uninitialized flip-flops in hierarchical synthesis. We temporarily used manual initialization scripts in Xcelium. Eventually, we switched to flattened synthesis, resolving the issue cleanly.

### 4.2 Power Analysis Discrepancies
Post-PnR power analysis showed a 10× drop compared to post-synthesis numbers, likely due to missing or incorrectly modeled clock power. We suspect the SDC needs additional constraints to account for clock gating effects.

### 4.3 SDC File Updates
We updated our SDC files to handle clock domain crossings and multicycle paths, particularly for handshake logic and the SFP normalizer divider.

---

## 5. Deliverables

We provided all relevant files for each part of the project:

- Part 1: Baseline RTL, gate-level simulation, and layout  
- Part 2: Optimized RTL with bitwidth and power improvements  
- Part 3: MAC Array Controller integration  
- Part 4: Divider and SFP normalizer  
- Final Merged: Integrated dual-core design with all optimizations  

Each part includes RTL, simulation VCDs, PnR reports (timing, power, area), and layout files.
