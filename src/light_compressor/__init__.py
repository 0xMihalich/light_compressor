"""Library for read compressed stream and write compressed chunks."""

from .compressor_method import CompressionMethod
from .reader import define_reader
from .decompressors import (
    LZ4Decompressor,
    ZSTDDecompressor,
)


__all__ = (
    "define_reader",
    "CompressionMethod",
    "LZ4Decompressor",
    "ZSTDDecompressor",
)
__version__ = "0.0.0.1"
