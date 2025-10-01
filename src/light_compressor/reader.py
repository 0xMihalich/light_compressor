"""Quick stream reader from compress file objects."""

from _compression import DecompressReader
from io import BufferedReader

from .compressor_method import CompressionMethod
from .decompressors import (
    LZ4Decompressor,
    ZSTDDecompressor,
)


def define_reader(
    fileobj: BufferedReader,
    compressor_method: CompressionMethod | None = None,
) -> BufferedReader:
    """Select current method for stream object."""

    if not compressor_method:
        """Auto detect method section from file signature.
        Warning!!! Not work with stream objects!!!"""

        pos = fileobj.tell()
        signature = fileobj.read(4)
        fileobj.seek(pos)

        if signature == b"\x04\"M\x18":
            compressor_method = CompressionMethod.LZ4
        elif signature == b"(\xb5/\xfd":
            compressor_method = CompressionMethod.ZSTD
        else:
            compressor_method = CompressionMethod.NONE

    if compressor_method == CompressionMethod.NONE:
        return fileobj

    if compressor_method == CompressionMethod.LZ4:
        decompressor = LZ4Decompressor
    elif compressor_method == CompressionMethod.ZSTD:
        decompressor = ZSTDDecompressor
    else:
        raise ValueError(f"Unsupported compression method {compressor_method}")

    raw = DecompressReader(fileobj, decompressor)
    return BufferedReader(raw)
