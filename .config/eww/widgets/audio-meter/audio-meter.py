#!/usr/bin/env python3
"""Stream a fixed-width stereo audio meter as Pango markup for Eww."""

import array
import math
import os
import select
import signal
import subprocess
import sys
import time

COLORS = (
    "#75c88a", "#85cb7c", "#a0ce6b", "#becd60", "#dbc75a",
    "#e8b652", "#efa04f", "#f18754", "#ee6d5b", "#eb5757",
)


def render_channel(level, reverse=False):
    """Render ten colored cells, optionally ordered from outside to center."""
    cells = []
    active_cells = max(0, min(len(COLORS), math.ceil(level)))
    for index, color in enumerate(COLORS):
        glyph = "█" if index < active_cells else " "
        cells.append(f'<span foreground="{color}">{glyph}</span>')
    return "".join(reversed(cells) if reverse else cells)


def emit(left, right):
    """Print one markup update with a stationary central separator."""
    print(f'{render_channel(left, True)}<span foreground="#8A795D">│</span>{render_channel(right)}', flush=True)


def stop(signum, frame):
    """Exit on termination so the capture process is cleaned up."""
    raise SystemExit(0)


def main():
    """Display stereo peaks at 40 Hz over a -60 to 0 dBFS range."""
    signal.signal(signal.SIGTERM, stop)
    emit(0, 0)
    while True:
        capture = subprocess.Popen(
            ["parec", "--device=@DEFAULT_MONITOR@", "--format=s16le", "--rate=24000",
             "--channels=2", "--channel-map=front-left,front-right",
             "--latency-msec=10", "--process-time-msec=10"],
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
        )
        levels = [0.0, 0.0]
        peaks = [0.0, 0.0]
        pending = b""
        received = False
        deadline = time.monotonic() + .025
        try:
            while True:
                readable, _, _ = select.select(
                    [capture.stdout], [], [], max(0, deadline - time.monotonic())
                )
                if readable:
                    chunk = os.read(capture.stdout.fileno(), 65536)
                    if not chunk:
                        break
                    pending += chunk
                    size = len(pending) // 4 * 4
                    if size:
                        samples = array.array("h", pending[:size])
                        pending = pending[size:]
                        if sys.byteorder != "little":
                            samples.byteswap()
                        for channel in range(2):
                            peak = max(abs(sample) for sample in samples[channel::2]) / 32768
                            peaks[channel] = max(peaks[channel], peak)
                        received = True
                now = time.monotonic()
                if now >= deadline:
                    if received:
                        levels = [max(0, min(10, (20 * math.log10(max(p, 1e-9)) + 60) / 6)) for p in peaks]
                    else:
                        levels = [0.0, 0.0]
                    emit(*levels)
                    peaks = [0.0, 0.0]
                    received = False
                    deadline += .025
                    if deadline <= now:
                        deadline = now + .025
        finally:
            capture.terminate()
            capture.wait()
            capture.stdout.close()
        emit(0, 0)
        time.sleep(2)


if __name__ == "__main__":
    try:
        main()
    except (BrokenPipeError, KeyboardInterrupt):
        pass
