from io import BufferedReader
from enum import Enum


class CompressionMethod(Enum):
    """List of compression codecs."""

    NONE = 0x02
    LZ4 = 0x82
    ZSTD = 0x90

    @property
    def method(self) -> str:
        """return selected method."""

        return self.name.lower()


def auto_detector(fileobj: BufferedReader) -> CompressionMethod:
    """Auto detect method section from file signature.
    Warning!!! Not work with stream objects!!!"""

    pos = fileobj.tell()
    signature = fileobj.read(4)
    fileobj.seek(pos)

    if signature == b"\x04\"M\x18":
        return CompressionMethod.LZ4
    if signature == b"(\xb5/\xfd":
        return CompressionMethod.ZSTD
    return CompressionMethod.NONE
