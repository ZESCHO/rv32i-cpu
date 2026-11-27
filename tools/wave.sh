#!/bin/bash
# tools/wave.sh NAME
#
# Runs sim/tb_NAME.sv the same way sim.sh does, records every signal declared in the
# testbench, and draws them as a timing diagram:
#     build/wave/NAME.png   (open it in VS Code)
#     build/wave/NAME.svg
# In the picture: dashed blue lines = rising clock edges, numbered 1, 2, 3...;
# red lines = moments when a $error fired. It also prints PASS/FAIL like sim.sh.
# Quiz mode: WAVE_HIDE=q tools/wave.sh dff_en draws q as a blank "?" row.
# Needs: Vivado (Windows), python3, rsvg-convert.

name=${1:?usage: tools/wave.sh NAME   (e.g. tools/wave.sh dff_rst)}
[[ $name =~ ^[A-Za-z0-9_]+$ ]] || { echo "NAME must be letters, digits or _ (got '$name')"; exit 1; }
root=$(cd "$(dirname "$0")/.." && pwd)
tb=sim/tb_$name.sv
[ -f "$root/rtl/$name.sv" ] || { echo "no such file: rtl/$name.sv"; exit 1; }
[ -f "$root/$tb" ] || { echo "no such file: $tb (a timing diagram needs a testbench)"; exit 1; }

build=$root/build/wave/$name
rm -rf "$build" && mkdir -p "$build" || exit 1
win=$(wslpath -w "$build")
V='C:\Xilinx\2026.1\Vivado\bin'

# Same helpers as sim.sh: run a Vivado tool inside $build, output to TOOL.txt.
viv() {
    local tool=$1; shift
    cmd.exe /c "pushd $win && call $V\\$tool.bat $*" 2>&1 < /dev/null | tr -d '\r' > "$build/$tool.txt"
    return "${PIPESTATUS[0]}"
}
short() { sed -E 's#[A-Z]:/[^ ]*/((rtl|sim)/[^] :]+)#\1#g'; }
toollog() {
    if [ -f "$build/$1.log" ]; then tr -d '\r' < "$build/$1.log"; else cat "$build/$1.txt"; fi
}

files=""
for f in "$root"/rtl/*.sv; do files="$files ../../../rtl/$(basename "$f")"; done
files="$files ../../../$tb"
if ! viv xvlog --sv $files; then
    toollog xvlog | grep -E '^(ERROR|WARNING)' | short; echo "COMPILE FAILED"; exit 1
fi
# -debug typical lets the simulator record signal values.
if ! viv xelab "tb_$name" -debug typical -s snap; then
    toollog xelab | grep -E '^(ERROR|WARNING)' | short
    echo "ELABORATE FAILED (is the testbench module called tb_$name?)"; exit 1
fi

# Record every signal in the testbench module into wave.vcd while it runs.
printf 'open_vcd wave.vcd\nlog_vcd [get_objects /tb_%s/*]\nrun 1 ms\nclose_vcd\nquit\n' "$name" > "$build/run.tcl"
viv xsim snap -tclbatch run.tcl
log=$build/xsim.txt
[ -s "$build/wave.vcd" ] || { echo "no wave.vcd was written; see $log"; exit 1; }

# $error lines look like "Error: ... Time: 18 ns  Iteration: ..."; keep the times.
grep -E '^(Error|Fatal|ERROR|FATAL)' -A2 "$log" | grep -oE 'Time: [0-9]+ [a-z]+' > "$build/errors.txt"

finish=$(grep -oE '\$finish called at time : [0-9]+ ns' "$log" | grep -oE '[0-9]+' | head -1)
out=$root/build/wave
python3 -I "$root/tools/wave.py" "$build/wave.vcd" "$build/errors.txt" "tb_$name" "$finish" "$WAVE_HIDE" > "$out/$name.svg" || exit 1
rsvg-convert -b white "$out/$name.svg" -o "$out/$name.png" || exit 1

sed -n '/^## run 1 ms/,/^## close_vcd/p' "$log" | grep -v '^## ' | short
errors=$(grep -cE '^(Error|Fatal|ERROR|FATAL)' "$log")
if [ "$errors" -gt 0 ]; then echo "FAIL ($errors error lines)"
elif ! grep -q '\$finish called' "$log"; then echo "FAIL (never reached \$finish within 1 ms)"
else echo "PASS"; fi
echo "picture: build/wave/$name.png"
