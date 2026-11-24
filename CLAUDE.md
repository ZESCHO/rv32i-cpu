# rv32i-cpu

A 5-stage pipelined RV32I CPU in SystemVerilog, simulated with Vivado, plus bare-metal C firmware.
Plan: `~/Code/personal/Goals/CPU-Roadmap.md`. Proof of progress: `~/Code/personal/Goals/CPU-Progress.md`.

## Who writes what

- **Zescho** writes every line in `rtl/` and `sim/` (RTL and testbenches), and later the startup code, linker script and C firmware.
- **Claude** writes tooling only (`tools/`, Makefiles, Tcl, converters), checks each tool against a known answer, and explains it until he can say what it does.
- Claude never edits `rtl/` or `sim/`. `.claude/settings.json` denies it. Don't work around the deny (no `python -c`, no shell tricks).

## How each module gets built

1. Read that week's section of the book.
2. He writes the RTL and its testbench.
3. Claude attacks it: 10 test cases that should break it, given in chat as inputs and expected outputs. He types them in. Claude doesn't fix anything.
4. On a failure, Claude names the signal to look at, at which cycle, and why. Never the fix.
5. Once every test passes, before the commit: spec comment at the top of the file (ports, behaviour, edge cases). Optional for stair 2's small modules (his call, 2026-11-15); required again from stair 3 (ALU, control), where the behaviour isn't obvious from the code.

Stuck 45 minutes: a hint. Stuck 2 hours: the concept with a different example. Never the code.
Every Friday he explains the week's module on a whiteboard without notes. If he can't, it isn't done.

## Rules that don't bend

- No testbench, no done.
- Re-run every old test after every change.
- A testbench counts only after it has caught a bug: plant one in the design once when the testbench is new or its checks change, see FAIL, restore. Not needed when only the design changes.
- The planted bug must be the sneakiest wrong design that still compiles, not an easy one. Before writing the tests, ask "what wrong version would still pass?" and plant that. Examples: a flip-flop with no memory (`assign q = d`), an enable flip-flop that ignores enable, a counter that wraps one step early. Catching `q <= ~d` proves little: on 2026-11-17, `tb_dff` caught that but also passed `assign q = d`.
- A stair is climbed only from proof: a commit, a passing test, or a whiteboard explanation.

## Running a simulation

    tools/sim.sh NAME

Compiles every `rtl/*.sv` plus `sim/tb_NAME.sv` with Vivado (on Windows, through `cmd.exe`) and runs the testbench.
All of `rtl/` is compiled so one module can use another; if any `rtl/` file fails to compile, every sim fails.
The testbench module is called `tb_NAME`, reports each mismatch with `$error("...")`, and ends with `$finish`.
PASS means it compiled, reached `$finish` within 1 ms of simulated time, and no `$error`/`$fatal` fired.

## Drawing a module

    tools/schem.sh NAME

Reads every `rtl/*.sv`, lets Yosys turn module NAME into a circuit, and draws it with netlistsvg into `build/schem/NAME.png` (and `.svg`). Takes about a second.
In a mux, the top input is chosen when the select is 0, the bottom one when it's 1.
A drawing shows how the code was read, not that it works: the testbench still decides that.
Vivado can draw the same module (`synth_design -rtl`, then `write_schematic`), but only in GUI mode and in about 50 s.
