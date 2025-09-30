"""Simple stream readers for compressed buffers."""

from .lz4 import LZ4StreamReader
from .zstd import ZSTDStreamReader


__all__ = (
    "LZ4StreamReader",
    "ZSTDStreamReader",
)
