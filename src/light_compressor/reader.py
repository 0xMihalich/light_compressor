from io import BufferedReader


from .stream_reader import (
    LZ4StreamReader,
    ZSTDStreamReader,
)


def define_reader(
    fileobj: BufferedReader,
    method_value: int = 0,
) -> LZ4StreamReader | ZSTDStreamReader | BufferedReader:
    """Select current method for stream object."""

    if not method_value:
        """Auto detect method section from file signature.
        Warning!!! Not work with stream objects!!!"""

        pos = fileobj.tell()
        signature = fileobj.read(4)
        fileobj.seek(pos)

        if signature == b"\x04\"M\x18":  # LZ4
            method_value = 0x82
        elif signature == b"(\xb5/\xfd":  # ZSTD
            method_value = 0x90
        else:
            method_value = 0x02

    if method_value == 0x02:
        return fileobj
    if method_value == 0x82:
        return LZ4StreamReader(fileobj)
    if method_value == 0x90:
        return ZSTDStreamReader(fileobj)

    raise ValueError(f"Unknown compression method {method_value}")
