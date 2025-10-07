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

    if compressor_method is CompressionMethod.NONE:
        return bytes_data

    if compressor_method is CompressionMethod.LZ4:
        compressor = LZ4Compressor()
    elif compressor_method is CompressionMethod.ZSTD:
        compressor = ZSTDCompressor()
    else:
        raise ValueError(f"Unsupported compression method {compressor_method}")

    return compressor.send_chunks(bytes_data)
