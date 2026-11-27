#!/usr/bin/env python3
"""wave.py VCD ERRORS TITLE FINISH_NS > out.svg

Draws a timing diagram (SVG) from the VCD file that tools/wave.sh records.
Called by tools/wave.sh; you don't need to run it yourself.

  VCD     the recorded signal values (xsim writes it)
  ERRORS  text file with one "Time: N ns" line per $error that fired
  TITLE   heading for the picture (the testbench name)
  FINISH_NS  time of $finish in ns, or "" if it wasn't reached
  HIDE    optional: comma-separated signal names to draw as blank "?" rows (for quizzes)

Only the standard library is used, so there is nothing to install.
"""
import re
import sys
from html import escape

UNIT_NS = {"s": 1e9, "ms": 1e6, "us": 1e3, "ns": 1.0, "ps": 1e-3, "fs": 1e-6}


def read_vcd(path):
    """Return (signals, end_ns). signals = list of [name, width, [(time_ns, value), ...]]."""
    text = open(path).read()
    head, _, body = text.partition("$enddefinitions")
    m = re.search(r"\$timescale\s+(\d+)\s*([a-z]+)\s+\$end", head)
    scale = int(m.group(1)) * UNIT_NS[m.group(2)] if m else 1e-3
    by_code, order = {}, []
    for code_m in re.finditer(r"\$var\s+\S+\s+(\d+)\s+(\S+)\s+(\S+)(?:\s+\[[^\]]*\])?\s+\$end", head):
        width, code, name = int(code_m.group(1)), code_m.group(2), code_m.group(3)
        if code not in by_code:
            by_code[code] = [name, width, []]
            order.append(code)
    now = 0.0
    tokens = body.split()
    i = 0
    while i < len(tokens):
        tok = tokens[i]
        if tok.startswith("#"):
            now = int(tok[1:]) * scale
        elif tok[0] in "bB":
            val, code = tok[1:].lower(), tokens[i + 1]
            i += 1
            if code in by_code:
                w = by_code[code][1]
                pad = val[0] if val[0] in "xz" else "0"   # VCD drops leading zeros
                by_code[code][2].append((now, val.rjust(w, pad)))
        elif tok[0] in "01xzXZ" and len(tok) > 1:
            code = tok[1:]
            if code in by_code:
                by_code[code][2].append((now, tok[0].lower()))
        i += 1
    signals = [by_code[c] for c in order]
    # inputs first (clk, rst, en, d), then the rest in the order the testbench declares them
    first = ["clk", "rst", "en", "d"]
    signals.sort(key=lambda s: first.index(s[0]) if s[0] in first else len(first))
    return signals, now


def segments(changes, end):
    """Turn [(t, v), ...] into [(t0, t1, v), ...], keeping only real changes."""
    out = []
    for t, v in changes:
        if out and out[-1][2] == v:
            continue
        if out and out[-1][0] == t:
            out[-1] = (t, None, v)
            continue
        out.append((t, None, v))
    return [(t0, out[k + 1][0] if k + 1 < len(out) else end, v) for k, (t0, _, v) in enumerate(out)]


def main():
    vcd, errfile, title, finish = sys.argv[1:5]
    hide = sys.argv[5] if len(sys.argv) > 5 else ""
    signals, end = read_vcd(vcd)
    if end <= 0 or not signals:
        sys.exit("wave.py: the VCD has no signal changes")
    # draw up to $finish (the last change can come a little before it)
    if finish:
        end = max(end, float(finish))
    errors = []
    for line in open(errfile):
        m = re.search(r"Time:\s*(\d+)\s*([a-z]+)", line)
        if m:
            errors.append(int(m.group(1)) * UNIT_NS[m.group(2)])

    ppn = max(8.0, min(50.0, 1300.0 / end))   # pixels per ns
    left, top, row, amp = 100, 56, 48, 26
    width = int(left + end * ppn + 40)
    height = top + row * len(signals) + 60
    x = lambda t: left + t * ppn
    svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
           f'font-family="DejaVu Sans Mono, monospace" font-size="13">',
           f'<rect width="100%" height="100%" fill="white"/>',
           f'<text x="10" y="20" font-size="15" font-weight="bold">{escape(title)}</text>']

    # numbered rising clock edges: dashed blue lines through every row
    clk = next((s for s in signals if s[0] == "clk"), None)
    if clk:
        prev, n = None, 0
        for t, v in clk[2]:
            if v == "1" and prev != "1" and t > 0:
                n += 1
                svg.append(f'<line x1="{x(t)}" y1="{top - 14}" x2="{x(t)}" y2="{top + row * len(signals)}" '
                           f'stroke="#3b6fd8" stroke-dasharray="4,4"/>')
                svg.append(f'<text x="{x(t)}" y="{top - 18}" text-anchor="middle" fill="#3b6fd8">edge {n}</text>')
            prev = v

    hidden = set(hide.split(",")) if hide else set()
    for r, (name, w, changes) in enumerate(signals):
        hi, lo = top + r * row + 8, top + r * row + 8 + amp
        mid = (hi + lo) / 2
        label = name if w == 1 else f"{name}[{w - 1}:0]"
        svg.append(f'<text x="{left - 10}" y="{mid + 5}" text-anchor="end" font-weight="bold">{escape(label)}</text>')
        if name in hidden:   # a quiz row: the signal is there, its values are not
            svg.append(f'<rect x="{left}" y="{hi}" width="{x(end) - left}" height="{amp}" fill="#f4f4f4" stroke="#bbb" stroke-dasharray="3,3"/>')
            svg.append(f'<text x="{(left + x(end)) / 2}" y="{mid + 5}" text-anchor="middle" fill="#888">? (you fill this in)</text>')
            continue
        segs = segments(changes, end)
        if w == 1:
            path, last_y = [], None
            for t0, t1, v in segs:
                if v in "xz":
                    svg.append(f'<rect x="{x(t0)}" y="{hi}" width="{x(t1) - x(t0)}" height="{amp}" '
                               f'fill="#fbd5d5" stroke="#d33"/>')
                    if x(t1) - x(t0) > 14:
                        svg.append(f'<text x="{(x(t0) + x(t1)) / 2}" y="{mid + 5}" text-anchor="middle" fill="#d33">{v}</text>')
                    last_y = None
                    continue
                y = hi if v == "1" else lo
                if last_y is not None and last_y != y:
                    path.append(f'L{x(t0)},{y}')
                elif last_y is None:
                    path.append(f'M{x(t0)},{y}')
                path.append(f'L{x(t1)},{y}')
                last_y = y
                if name != "clk" and x(t1) - x(t0) > 14:
                    svg.append(f'<text x="{(x(t0) + x(t1)) / 2}" y="{lo - 4 if v == "1" else hi + 14}" '
                               f'text-anchor="middle" fill="#888" font-size="11">{v}</text>')
            if path:
                svg.append(f'<path d="{" ".join(path)}" fill="none" stroke="#111" stroke-width="2"/>')
        else:
            for t0, t1, v in segs:
                a, b, s = x(t0), x(t1), min(4, (x(t1) - x(t0)) / 2)
                bad = any(c in "xz" for c in v)
                svg.append(f'<polygon points="{a},{mid} {a + s},{hi} {b - s},{hi} {b},{mid} {b - s},{lo} {a + s},{lo}" '
                           f'fill="{"#fbd5d5" if bad else "#eef3ee"}" stroke="{"#d33" if bad else "#111"}" stroke-width="1.5"/>')
                if b - a > 8 * len(v) + 6:
                    svg.append(f'<text x="{(a + b) / 2}" y="{mid + 5}" text-anchor="middle">{v}</text>')

    # time axis
    axis_y = top + row * len(signals) + 14
    step = 1 if end <= 30 else 5 if end <= 100 else 10
    every = 1 if step * ppn >= 28 else 2
    svg.append(f'<line x1="{left}" y1="{axis_y}" x2="{x(end)}" y2="{axis_y}" stroke="#555"/>')
    k = 0
    while k * step <= end + 1e-9:
        t = k * step
        svg.append(f'<line x1="{x(t)}" y1="{axis_y}" x2="{x(t)}" y2="{axis_y + 5}" stroke="#555"/>')
        if k % every == 0:
            svg.append(f'<text x="{x(t)}" y="{axis_y + 18}" text-anchor="middle" fill="#555" font-size="11">{t:g}</text>')
        k += 1
    svg.append(f'<text x="{left - 10}" y="{axis_y + 18}" text-anchor="end" fill="#555" font-size="11">ns</text>')

    # moments a $error fired
    for t in errors:
        svg.append(f'<line x1="{x(t)}" y1="{top - 8}" x2="{x(t)}" y2="{axis_y}" stroke="#d33" stroke-width="2"/>')
        svg.append(f'<text x="{x(t)}" y="{axis_y + 34}" text-anchor="middle" fill="#d33" font-weight="bold">$error {t:g} ns</text>')

    svg.append("</svg>")
    print("\n".join(svg))


if __name__ == "__main__":
    main()
