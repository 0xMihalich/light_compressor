"""Simple stream readers for compressed buffers."""

from .lz4 import LZ4Decompressor
from .zstd import ZSTDDecompressor


__all__ = (
    "LZ4Decompressor",
    "ZSTDDecompressor",
)
