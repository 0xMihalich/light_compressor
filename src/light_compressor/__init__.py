from .compressor_method import CompressionMethod
from .reader import define_reader
from .stream_reader import (
    LZ4StreamReader,
    ZSTDStreamReader,
)


__all__ = (
    "define_reader",
    "CompressionMethod",
    "LZ4StreamReader",
    "ZSTDStreamReader",
)
