# PMU v2 Architecture Notes

## What this file is for

This file is just to keep track of the architectural decisions made so far for PMU v2.
Not trying to overdo it or write about stuff that has not been built yet. The idea is
to document what is already decided so the RTL stays consistent as the project grows.

## Overall direction

PMU v1 was more of a fixed counter block. Each counter was tied to one event signal,
and the main goal was proving the counting logic worked.

PMU v2 is being built more like a real reusable hardware block. The point now is not
just counting events, but letting a user configure what gets counted and later read
those counts back through registers.

So the main direction right now is:

- programmable event selection
- memory-mapped control/readback
- cleaner module split
- better documentation as the project grows

## Main architectural decision so far

The biggest change from v1 is that counters are not supposed to be hardwired forever
to one event signal anymore.

Instead, the PMU will take in a bigger set of raw event signals, and each counter will
have a select value that decides which one of those events it listens to.

That decision is really the center of PMU v2.

## package.sv

The first file made for v2 was [`package.sv`](/Users/skasinad/Desktop/PMUproj/rtl/package.sv).

This file holds the common definitions that other PMU files will share. Right now it
has the basic parameter values, a few typedefs, and the first pass of register address
definitions.

The current defaults in the package are:

- `tevents = 16`
- `ncntrs = 4`
- `cdepth = 16`
- `apb_dw = 32`
- `apb_aw = 8`

These are default values, not hard limits. The idea is that the PMU should stay scalable,
but we still need some starting numbers to build around.

### Why these values

`tevents = 16`
- gives the PMU a more realistic number of possible event sources
- makes programmable event selection actually matter

`ncntrs = 4`
- keeps the design manageable
- also creates the more realistic case where there are more possible events than counters

`cdepth = 16`
- keeps the first version of v2 simple for now
- this can still be changed later if a wider counter makes more sense

`apb_dw = 32`
- makes sense for a register interface
- easy for control and readback registers

`apb_aw = 8`
- enough address space for a small PMU register map
- simpler and less random than using something bigger than we need

## mux.sv

The next file made was [`mux.sv`](/Users/skasinad/Desktop/PMUproj/rtl/mux.sv).

This module is the event selection block. Its job is simple:

- take in all raw event signals
- take in one select value per counter
- output one routed event bit per counter

So if a counter select value says `3`, then that counter sees `sigs[3]`.

This is the first actual RTL block that shows PMU v2 is different from v1.

## Why the design is being split up

Instead of putting everything into one top module immediately, the PMU is being broken
into smaller blocks.

So far, that split looks like this:

- `package.sv` for shared definitions
- `mux.sv` for event selection

Later blocks like the counter bank and APB register block will connect around this,
but those are not documented here yet because they are not built yet.

## Register direction so far

The package file already has a first pass of register names and addresses. This does
not mean the full register map is finalized yet, but it does show the direction:

- one control register
- event-select registers
- counter read registers

That lines up with the PMU v2 goal of being configurable and readable like a real
peripheral instead of only being watched from a waveform.

## What is not locked yet

A few things are still open and should not be treated as finalized architecture yet:

- final APB block behavior
- exact register field definitions
- whether counter width stays 16 or changes later
- exact top-level module structure
- testbench structure for the APB version

So this file is only capturing the parts that are already decided and in motion.
