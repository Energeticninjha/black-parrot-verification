# 🚀 FIFO Tracker: Active Functional Verification Report

**Contributor:** Dharshini Sree (Infosys Intern | 6th Sem ECE | CGPA: 8.18)
**Target Module:** bsg_fifo_tracker.sv (BaseJump STL / BlackParrot)
**Environment:** Verilator 5.0+ on WSL2 (Ubuntu 24.04)

## 1. The Challenge: Passive vs. Active Monitoring
- **Passive Design:** bsg_fifo_tracker is area-optimized but does not check protocol compliance.
- **Silent Failure:** In test_before.sv, an illegal Enqueue was forced while full_o was high; hardware stayed silent.
- **Risk:** Silent overflows in BlackParrot SoC cause hard-to-debug data corruption.

## 2. The Solution: UVM-Inspired Golden Model
- **Active Suite:** Created robust verification in test_after.sv.
- **Golden Model:** Built reference model using SV queue (shadow_queue[$]).
- **Active Monitor:** Compares RTL flags with golden model every clock cycle.

## 3. Key Technical Findings
- **Synchronous Reset Latency:** Found tracker needs 1 clock cycle after reset de-assertion to clear registers.
- **Stress Testing:** Ran 20+ cycles of random Enq/Deq timing with zero pointer drift.

## 4. Execution Trace Summary
- **Reset Startup:** SUCCESS
- **Timing:** PASS (1-cycle latency validated)
- **Randomization:** PASS
- **Forced Overflow:** CAUGHT at Time 175.

## 5. Future Work
- Parameterize scoreboard for variable depths.
- Apply template to bsg_fifo_1r1w_large.
