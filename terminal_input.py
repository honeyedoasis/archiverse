"""
Single-key reads for interactive TUI menus (Windows + POSIX: Linux, macOS).

Uses msvcrt on Windows and raw tty mode on POSIX. Arrow keys and Escape are
handled without blocking when the user presses a bare Escape (common on Unix).
"""
from __future__ import annotations

import os
import sys

try:
    import msvcrt
except ImportError:
    msvcrt = None


def get_key() -> str | None:
    """Read one logical key and return a normalised token (e.g. 'up', 'enter')."""
    if msvcrt:
        return _get_key_windows()
    return _get_key_posix()


def _get_key_windows() -> str | None:
    ch = msvcrt.getch()
    if ch in (b"\x00", b"\xe0"):
        ch = msvcrt.getch()
        return {b"H": "up", b"P": "down", b"K": "left", b"M": "right"}.get(ch)
    if ch == b"\r":
        return "enter"
    if ch == b" ":
        return "space"
    if ch == b"\x1b":
        return "quit"
    try:
        return ch.decode("utf-8").lower()
    except Exception:
        return None


def _get_key_posix() -> str | None:
    import select
    import termios
    import time
    import tty

    fd = sys.stdin.fileno()
    if not os.isatty(fd):
        return None

    def _read_one_within(deadline: float) -> str:
        """Read one byte from stdin before deadline (monotonic). macOS terminals
        often deliver ESC and the rest of a CSI sequence a few ms apart; a single
        short select() frequently times out and was misread as bare Escape -> quit."""
        while True:
            left = deadline - time.monotonic()
            if left <= 0:
                return ""
            timeout = min(0.05, left)
            ready, _, _ = select.select([sys.stdin], [], [], timeout)
            if ready:
                c = sys.stdin.read(1)
                return c if c else ""
            # keep polling until deadline (not a single short select)

    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
        if not ch:
            return None
        if ch == "\x1b":
            # Arrow keys: ESC [ A/B/C/D or SS3 ESC O A. Bare ESC: nothing more within window.
            d1 = time.monotonic() + 0.45
            ch2 = _read_one_within(d1)
            if not ch2:
                return "quit"
            if ch2 == "[":
                d2 = time.monotonic() + 0.2
                ch3 = _read_one_within(d2)
                return {"A": "up", "B": "down", "C": "right", "D": "left"}.get(ch3)
            if ch2 == "O":
                d2 = time.monotonic() + 0.2
                ch3 = _read_one_within(d2)
                return {"A": "up", "B": "down", "C": "right", "D": "left"}.get(ch3)
            return None
        if ch in ("\r", "\n"):
            return "enter"
        if ch == " ":
            return "space"
        if ch == "\x03":  # Ctrl+C in raw mode
            return "quit"
        if ch == "\x7f":
            return "backspace"
        return ch.lower()
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
