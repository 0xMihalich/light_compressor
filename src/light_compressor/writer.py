from collections.abc import Iterable
from typing import Generator

from .compressor_method import CompressionMethod
from .compressors import (
    LZ4Compressor,
    ZSTDCompressor,
)


def define_writer(
    bytes_data: Iterable[bytes],
    compressor_method: CompressionMethod = CompressionMethod.NONE,
) -> Generator[bytes, None, None]:
    """Select current method for stream object."""

    if compressor_method == CompressionMethod.NONE:
        return bytes_data
    if compressor_method == CompressionMethod.LZ4:
        return LZ4Compressor(bytes_data)
    if compressor_method == CompressionMethod.ZSTD:
        return ZSTDCompressor(bytes_data)

    raise ValueError(f"Unknown compression method {compressor_method}")
