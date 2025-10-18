"""Library for read compressed stream and write compressed chunks."""

from .compressor_method import (
    auto_detector,
    CompressionMethod,
)
from .compressors import (
    LZ4Compressor,
    ZSTDCompressor,
)
from .decompressors import (
    LZ4Decompressor,
    ZSTDDecompressor,
)
from .reader import define_reader
from .writer import define_writer


__all__ = (
    "auto_detector",
    "define_reader",
    "define_writer",
    "CompressionMethod",
    "LZ4Compressor",
    "LZ4Decompressor",
    "ZSTDCompressor",
    "ZSTDDecompressor",
)
__version__ = "0.0.1.8"
