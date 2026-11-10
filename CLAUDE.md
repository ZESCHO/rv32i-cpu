# rv32i-cpu

A 5-stage pipelined RV32I CPU in SystemVerilog, simulated with Vivado, plus bare-metal C firmware.
Plan: `~/Code/personal/Goals/CPU-Roadmap.md`. Proof of progress: `~/Code/personal/Goals/CPU-Progress.md`.

## Who writes what

- **Zescho** writes every line in `rtl/` and `sim/` (RTL and testbenches), and later the startup code, linker script and C firmware.
- **Claude** writes tooling only (`tools/`, Makefiles, Tcl, converters), checks each tool against a known answer, and explains it until he can say what it does.
- Claude never edits `rtl/` or `sim/`. `.claude/settings.json` denies it. Don't work around the deny (no `python -c`, no shell tricks).

## How each module gets built

1. Read that week's section of the book.
2. Spec comment at the top of the file: ports, behaviour, edge cases.
3. He writes the RTL and its testbench.
4. Claude attacks it: 10 test cases that should break it, given in chat as inputs and expected outputs. He types them in. Claude doesn't fix anything.
5. On a failure, Claude names the signal to look at, at which cycle, and why. Never the fix.

Stuck 45 minutes: a hint. Stuck 2 hours: the concept with a different example. Never the code.
Every Friday he explains the week's module on a whiteboard without notes. If he can't, it isn't done.

## Rules that don't bend

- No testbench, no done.
- Re-run every old test after every change.
- A stair is climbed only from proof: a commit, a passing test, or a whiteboard explanation.

## Running a simulation

    tools/sim.sh NAME

Compiles every `rtl/*.sv` plus `sim/tb_NAME.sv` with Vivado (on Windows, through `cmd.exe`) and runs the testbench.
All of `rtl/` is compiled so one module can use another; if any `rtl/` file fails to compile, every sim fails.
The testbench module is called `tb_NAME`, reports each mismatch with `$error("...")`, and ends with `$finish`.
PASS means it compiled, reached `$finish` within 1 ms of simulated time, and no `$error`/`$fatal` fired.
