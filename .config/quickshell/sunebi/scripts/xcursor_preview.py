#!/usr/bin/env python3
"""Lists the cursor themes of the user and writes a PNG of the arrow of each one.

Qt cannot read the Xcursor format, so the picker of the shell shows these PNGs.
Prints the name of every theme whose arrow could be drawn, one per line, once its PNG is in the output directory.
Standard library only.

Usage: xcursor_preview.py OUTPUT_DIRECTORY
"""

import os
import struct
import sys
import zlib

IMAGE_CHUNK = 0xFFFD0002
# An arrow of this size is sharp on a card of the picker and still small to store
WANTED_SIZE = 64
ARROW_NAMES = ("left_ptr", "default", "arrow", "top_left_arrow")


def icon_directories():
    home = os.path.expanduser("~")
    yield os.path.join(home, ".local", "share", "icons")
    yield os.path.join(home, ".icons")
    for data_directory in os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(":"):
        yield os.path.join(data_directory, "icons")


def read_arrow(path):
    """The (width, height, premultiplied ARGB pixels) of the chunk closest to WANTED_SIZE, the first frame of an animation."""
    with open(path, "rb") as file:
        data = file.read()
    if data[:4] != b"Xcur":
        return None
    table_size = struct.unpack_from("<I", data, 12)[0]
    best = None
    for index in range(table_size):
        kind, size, position = struct.unpack_from("<III", data, 16 + 12 * index)
        if kind != IMAGE_CHUNK:
            continue
        if best is None or abs(size - WANTED_SIZE) < abs(best[0] - WANTED_SIZE):
            best = (size, position)
    if best is None:
        return None
    width, height = struct.unpack_from("<II", data, best[1] + 16)
    pixels = data[best[1] + 36 : best[1] + 36 + 4 * width * height]
    return width, height, pixels


def png_bytes(width, height, argb):
    """A PNG from little endian premultiplied ARGB pixels."""
    rows = bytearray()
    for y in range(height):
        rows.append(0)
        for x in range(width):
            offset = 4 * (y * width + x)
            blue, green, red, alpha = argb[offset : offset + 4]
            if 0 < alpha < 255:
                red, green, blue = (min(255, channel * 255 // alpha) for channel in (red, green, blue))
            rows += bytes((red, green, blue, alpha))

    def chunk(name, body):
        return struct.pack(">I", len(body)) + name + body + struct.pack(">I", zlib.crc32(name + body))

    header = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) + chunk(b"IDAT", zlib.compress(bytes(rows))) + chunk(b"IEND", b"")


def main():
    output = sys.argv[1]
    os.makedirs(output, exist_ok=True)
    seen = set()
    for directory in icon_directories():
        if not os.path.isdir(directory):
            continue
        for theme in sorted(os.listdir(directory)):
            cursors = os.path.join(directory, theme, "cursors")
            if theme in seen or not os.path.isdir(cursors):
                continue
            source = next((os.path.join(cursors, name) for name in ARROW_NAMES if os.path.exists(os.path.join(cursors, name))), None)
            if source is None:
                continue
            target = os.path.join(output, theme + ".png")
            # A theme that was changed after its preview is drawn again
            if not os.path.exists(target) or os.path.getmtime(target) < os.path.getmtime(os.path.realpath(source)):
                arrow = read_arrow(source)
                if arrow is None:
                    continue
                with open(target, "wb") as file:
                    file.write(png_bytes(*arrow))
            seen.add(theme)
            print(theme, flush=True)


main()
