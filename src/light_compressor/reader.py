"""Quick stream reader from compress file objects."""

from _compression import DecompressReader
from io import BufferedReader

from .compressor_method import (
    auto_detector,
    CompressionMethod,
)
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
        compressor_method = auto_detector(fileobj)

    if compressor_method is CompressionMethod.NONE:
        return fileobj

    if compressor_method is CompressionMethod.LZ4:
        decompressor = LZ4Decompressor
    elif compressor_method == CompressionMethod.ZSTD:
        decompressor = ZSTDDecompressor
    else:
        raise ValueError(f"Unsupported compression method {compressor_method}")

    raw = DecompressReader(fileobj, decompressor)
    return BufferedReader(raw)
