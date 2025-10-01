"""Simple stream readers for compressed buffers."""

from .lz4 import LZ4Compressor
from .zstd import ZSTDCompressor


__all__ = (
    "LZ4Compressor",
    "ZSTDCompressor",
)
