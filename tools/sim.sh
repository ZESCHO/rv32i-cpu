#!/bin/bash
# tools/sim.sh NAME
#
# Compiles every rtl/*.sv file (and sim/tb_NAME.sv, if it exists) with Vivado's simulator,
# runs the testbench, and prints PASS or FAIL. Vivado lives on Windows, so each
# tool runs through cmd.exe; the code stays here in WSL.
#
# All of rtl/ is compiled, not only rtl/NAME.sv, so a module can use another one
# (e.g. adder.sv using full_adder.sv). The catch: if any file in rtl/ doesn't
# compile, every simulation fails until it does.
#
# Testbench rules:
#   - the testbench module is called tb_NAME
#   - every mismatch is reported with $error("...")
#   - it ends with $finish
# PASS means: it compiled, it reached $finish within 1 ms of simulated time,
# and no $error or $fatal fired. Exit code: 0 on PASS, 1 otherwise.
# Build files go to build/NAME/ (git ignores build/).

name=${1:?usage: tools/sim.sh NAME   (e.g. tools/sim.sh adder)}
[[ $name =~ ^[A-Za-z0-9_]+$ ]] || { echo "NAME must be letters, digits or _ (got '$name')"; exit 1; }
root=$(cd "$(dirname "$0")/.." && pwd)
rtl=rtl/$name.sv
tb=sim/tb_$name.sv
[ -f "$root/$rtl" ] || { echo "no such file: $rtl"; exit 1; }

# Start from an empty build folder every time, so nothing compiled in an earlier run can leak in.
build=$root/build/$name
rm -rf "$build" && mkdir -p "$build" || exit 1
win=$(wslpath -w "$build")
V='C:\Xilinx\2026.1\Vivado\bin'

# viv TOOL ARGS...: run one Vivado tool inside build/NAME, its output saved to build/NAME/TOOL.txt
# (Windows line endings removed). pushd gives the WSL folder a temporary drive letter,
# because cmd.exe can't cd into a \\wsl$ path. Returns the tool's own exit code.
viv() {
    local tool=$1; shift
    cmd.exe /c "pushd $win && call $V\\$tool.bat $*" 2>&1 < /dev/null | tr -d '\r' > "$build/$tool.txt"
    return "${PIPESTATUS[0]}"
}

# Vivado prints paths like Z:/home/zescho/.../rtl/adder.sv; shorten them to rtl/adder.sv.
short() { sed -E 's#[A-Z]:/[^ ]*/((rtl|sim)/[^] :]+)#\1#g'; }

# 1. Compile (syntax and types): all of rtl/, then the testbench.
files=""
for f in "$root"/rtl/*.sv; do files="$files ../../rtl/$(basename "$f")"; done
[ -f "$root/$tb" ] && files="$files ../../$tb"
if ! viv xvlog --sv $files; then
    grep -E '^(ERROR|WARNING)' "$build/xvlog.txt" | short
    echo "COMPILE FAILED"
    exit 1
fi
grep -E '^WARNING' "$build/xvlog.txt" | short

if [ ! -f "$root/$tb" ]; then
    echo "compiled OK ($rtl). No testbench yet: $tb"
    exit 0
fi

# 2. Elaborate: connect the modules, starting from tb_NAME.
if ! viv xelab "tb_$name" -s snap; then
    grep -E '^(ERROR|WARNING)' "$build/xelab.txt" | short
    echo "ELABORATE FAILED (is the testbench module called tb_$name?)"
    exit 1
fi

# 3. Simulate for at most 1 ms of simulated time.
printf 'run 1 ms\nquit\n' > "$build/run.tcl"
viv xsim snap -tclbatch run.tcl
log=$build/xsim.txt

# Show what the testbench printed: everything between "## run 1 ms" and "## quit".
sed -n '/^## run 1 ms/,/^## quit/p' "$log" | grep -v '^## ' | short

errors=$(grep -cE '^(Error|Fatal|ERROR|FATAL)' "$log")
if [ "$errors" -gt 0 ]; then
    echo "FAIL ($errors error lines)"
    exit 1
fi
if ! grep -q '\$finish called' "$log"; then
    echo "FAIL (the testbench never reached \$finish within 1 ms of simulated time)"
    exit 1
fi
echo "PASS"
