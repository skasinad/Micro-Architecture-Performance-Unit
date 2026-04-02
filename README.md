# Micro-Architecture Performance Monitor (PMU) v2

## Project Overview

This project is the second version of my Micro-Architecture Performance Monitor (PMU), written in SystemVerilog. The first version of the PMU was focused on the basic idea: taking in a set of event signals and counting how often each one happens using separate counters. That version helped me build the core RTL and verification flow.

For version 2, the goal is to move beyond a simple fixed counter block and make the PMU look more like a real hardware peripheral that could fit into a larger processor or SoC-style design.

Instead of permanently wiring one event to one counter, PMU v2 is being built so the user can choose which event each counter should track. On top of that, the PMU will also include a memory-mapped register interface so software, firmware, or a verification testbench can configure it and read back results through registers instead of only looking at internal signals directly.

So overall, PMU v2 is about turning the original idea into something more configurable, more realistic, and more useful as an integration project.

---

## Purpose of the Project

The purpose of this version is to keep building stronger RTL and verification skills while also getting closer to the type of hardware block that would actually be used in a bigger digital system.

This version is meant to help me work on:

- modular RTL design
- cleaner block partitioning
- programmable hardware behavior instead of fixed wiring
- memory-mapped peripheral design
- APB-style register interface design
- register planning and documentation
- more realistic verification structure
- writing project documentation in a more complete hardware-IP style

The bigger reason for this project is that PMUs are not just counters for the sake of counters. They are observation logic. In real systems, being able to select events, configure monitoring behavior, and read counts through registers is what makes performance-monitoring hardware practical.

---

## What Changes in PMU v2

Compared to version 1, this new version is planned with several major upgrades.

### 1. Programmable event selection

In PMU v1, each counter was hardwired to one specific event signal. For example, event 0 always went to counter 0, event 1 always went to counter 1, and so on.

In PMU v2, that is changing. Each counter will be able to select which event signal it listens to. This means the PMU is no longer fixed to one permanent signal-to-counter mapping.

This makes the block more flexible and more reusable because the same hardware can now monitor different things depending on how it is configured.

### 2. Memory-mapped register interface

PMU v2 will expose registers at specific addresses through an APB-style interface. That means the PMU can be controlled like a normal hardware peripheral.

Instead of only driving raw RTL control signals in a testbench, the user will be able to:

- write configuration values into registers
- choose which events each counter monitors
- enable or disable PMU behavior through control registers
- read back counter values through the register interface

This is a major step toward making the PMU feel like a real subsystem instead of just a standalone RTL exercise.

### 3. Counter control registers

Version 2 will include control registers that define the PMU behavior. These registers will likely be used for things such as:

- global enable control
- possible clear or reset-style control
- per-counter event select configuration
- reading the current counter values

This makes the design software-visible and easier to integrate into a larger design flow.

### 4. Better documentation and integration support

Version 2 is also being organized with more documentation, including a register map and an integration guide.

That means the project is not only about writing RTL, but also about explaining how someone else would connect the block, configure it, and use it correctly.

---

## PMU v2 High-Level Function

At a high level, PMU v2 will still monitor event activity using counters, but now with a more flexible path.

The expected flow is:

1. a set of raw event signals comes into the PMU
2. configuration registers decide which event each counter should observe
3. the selected event for each counter is routed through an event-mux stage
4. the counters increment when their chosen event occurs and counting is enabled
5. software or the testbench can read the counter values through the register interface

So the counting idea stays the same, but the control and access method become much more advanced than in v1.

---

## Planned Design Features

PMU v2 is planned to include the following features:

- parameterizable number of event inputs
- parameterizable number of counters
- parameterizable counter width
- programmable event-to-counter mapping
- one selectable event source per counter
- APB-based memory-mapped register interface
- control and configuration registers
- readable counter registers
- modular RTL hierarchy
- basic integration and register documentation

Depending on implementation details, parts of the v1 counter behavior such as saturation may be kept as-is or lightly updated.

---

## Planned File Structure

The current planned project structure for PMU v2 is:

```text
PMU_v2/
├── rtl/
│   ├── counter.sv
│   ├── pmu_event_mux.sv
│   ├── pmu_counter_bank.sv
│   ├── pmu_regblock_apb.sv
│   ├── pmu_top.sv
│   └── pmu_pkg.sv
│
├── tb/
│   ├── pmu_tb_apb.sv
│   └── apb_tasks.svh
│
├── docs/
│   ├── integration_guide.md
│   └── register_map.md
│
├── old/
│   ├── pmu_v1.sv
│   └── pmu_tb_v1.sv
│
└── README.md
```

---

## Planned RTL Blocks

### `rtl/counter.sv`

This is the reusable counter module from version 1. It will probably stay in the design, with only light edits if needed. Its job is still to count event occurrences.

### `rtl/pmu_event_mux.sv`

This module will handle event selection. Based on configuration settings, it will choose which incoming event signal gets connected to each counter.

### `rtl/pmu_counter_bank.sv`

This module will group the counters together into one cleaner block. Instead of managing all counters directly at the top level, the design can treat the counter array as its own subsystem.

### `rtl/pmu_regblock_apb.sv`

This module will implement the memory-mapped APB register interface. It will decode addresses, handle reads and writes, and store PMU configuration values.

### `rtl/pmu_top.sv`

This will be the new main top-level PMU module. It will connect together the APB register block, the event mux logic, and the counter bank.

### `rtl/pmu_pkg.sv`

This file is optional but recommended. It can hold shared parameters, typedefs, address definitions, or other constants used across the PMU modules.

---

## Planned Verification Files

### `tb/pmu_tb_apb.sv`

This will be the new main testbench for PMU v2. Instead of only checking direct signal behavior, it will verify configuration and readback through the APB interface.

### `tb/apb_tasks.svh`

This optional helper file can hold common APB read/write tasks so the testbench stays cleaner and easier to extend.

---

## Planned Documentation Files

### `docs/integration_guide.md`

This document will explain how to hook the PMU into a larger design, what signals it expects, and how someone should use it from a system point of view.

### `docs/register_map.md`

This document will describe the PMU registers, their addresses, what each field means, and how the software-visible interface is supposed to work.

---

## Why This Version Matters More

The first PMU version was useful because it proved the basic counting logic worked. It showed that multiple event signals could be counted independently, and it gave a solid starting point for RTL structure and testbench development.

But PMU v2 matters more from a system-design perspective because it starts to answer more realistic questions:

- how does software configure the PMU?
- how does the PMU expose results back to the system?
- how can the same hardware block be reused for different event choices?
- how should the PMU be organized so it is easier to integrate and verify?

So this version is not just "more features." It is a shift from a fixed demonstration block toward a configurable hardware IP block.

---

## Current Development Direction

At this stage, PMU v2 is being planned around four main goals:

1. programmable event selection
2. memory-mapped register access
3. counter control through registers
4. better documentation and integration support

The original PMU v1 design still matters because it provides the counter foundation and the first verified behavior model. But the active direction now is to build the second version as a more complete and realistic PMU architecture.

---

## Summary

PMU v2 is a configurable performance-monitoring block written in SystemVerilog. It builds on the first version by adding selectable event routing, a register-based control interface, and a structure that is closer to a real hardware peripheral.

The main idea is no longer just "count events." The goal now is:

- choose what to count
- control the PMU through registers
- read results back through a standard interface
- document the design clearly enough for integration

That is what this version of the project is trying to achieve.
