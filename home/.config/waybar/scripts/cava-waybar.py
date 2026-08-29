#!/usr/bin/env python3
import signal, subprocess, time
from pathlib import Path

GLYPHS = "▁▂▃▄▅▆▇█"
CONFIG_PATH = Path.home() / ".config/cava/waybar.conf"
STATUS_INTERVAL = 1.0

stop_requested = False

def request_stop(_signum, _frame):
    global stop_requested
    stop_requested = True

def is_playing() -> bool:
    try:
        result = subprocess.run(
            ["playerctl", "status"],
            capture_output=True, text=True, timeout=1,
        )
        return result.stdout.strip() == "Playing"
    except (subprocess.SubprocessError, OSError):
        return False

def main() -> int:
    signal.signal(signal.SIGTERM, request_stop)
    signal.signal(signal.SIGINT, request_stop)

    process = subprocess.Popen(
        ["cava", "-p", str(CONFIG_PATH)],
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
        text=True, encoding="utf-8", bufsize=1,
    )

    last_printed = None
    playing = False
    last_check = 0.0

    try:
        if process.stdout is None:
            return 1

        for line in process.stdout:
            if stop_requested:
                break

            now = time.monotonic()
            if now - last_check >= STATUS_INTERVAL:
                playing = is_playing()
                last_check = now

            if not playing:
                output = ""
            else:
                levels = []
                for value in line.strip().split(";"):
                    if not value:
                        continue
                    try:
                        level = int(value)
                    except ValueError:
                        level = 0
                    levels.append(max(0, min(level, len(GLYPHS) - 1)))
                output = "".join(GLYPHS[l] for l in levels) if levels else ""

            if output != last_printed:
                print(output, flush=True)
                last_printed = output

    except BrokenPipeError:
        pass
    finally:
        if process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=2)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
