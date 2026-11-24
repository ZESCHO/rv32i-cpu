#!/usr/bin/env bash
# tools/schem.sh NAME: draw the module NAME from rtl/ as a circuit diagram.
#
# Reads every rtl/*.sv (so a module can use another, like adder uses full_adder),
# lets Yosys turn the code into a circuit (prep -top NAME), and has netlistsvg draw it.
# Output: build/schem/NAME.svg and build/schem/NAME.png (git ignores build/).
# The drawing is only Yosys's reading of the code: it proves nothing about behaviour,
# that's still the testbench's job.
set -u
export PATH="$HOME/.local/bin:$PATH"   # netlistsvg was installed with npm into ~/.local

root=$(cd "$(dirname "$0")/.." && pwd)
name=${1:-}
if [ -z "$name" ] || [ $# -ne 1 ]; then
    echo "usage: tools/schem.sh NAME   (draws module NAME from rtl/)"
    exit 2
fi

for tool in yosys netlistsvg rsvg-convert; do
    command -v "$tool" >/dev/null || { echo "MISSING TOOL: $tool"; exit 1; }
done

out=$root/build/schem
mkdir -p "$out" || exit 1
rm -f "$out/$name".{json,svg,png,log}

cd "$root" || exit 1
if ! yosys -q -l "$out/$name.log" \
        -p "read_verilog -sv rtl/*.sv; prep -top $name; write_json $out/$name.json" \
        >/dev/null 2>&1; then
    echo "YOSYS FAILED: rtl/ didn't read cleanly, or there is no module called $name"
    grep -E "ERROR|rror:" "$out/$name.log" | head -5
    exit 1
fi

netlistsvg "$out/$name.json" -o "$out/$name.svg" >/dev/null 2>&1 \
    || { echo "NETLISTSVG FAILED on $out/$name.json"; exit 1; }
rsvg-convert -b white -z 2 "$out/$name.svg" -o "$out/$name.png" \
    || { echo "PNG CONVERSION FAILED"; exit 1; }

echo "drew build/schem/$name.png (and .svg)"
