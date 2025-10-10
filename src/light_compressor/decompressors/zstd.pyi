

class ZSTDDecompressor:
    """ZSTD frame cython decompressor."""

    def __init__(self) -> None:
        """Class inialization."""

        self._dctx: object
        self.eof: bool
        self.needs_input: bool
        self.unused_data: bytes
        self._unconsumed_data: bytes
        self._return_bytearray: bool
        self._in_buffer: object
        self._input_buffer: object
        self._input_data: object
        ...

    def __enter__(self) -> "ZSTDDecompressor":
        """Enter context manager."""

        ...

    def __exit__(
        self,
        exception_type,
        exception,
        traceback,
    ) -> None:
        """Exit context manager."""

        ...

    def reset(self) -> None:
        """Reset the decompressor state."""

        ...

    def decompress(
        self,
        data: bytes | bytearray,
        max_length: int = -1,
    ) -> bytes:
        """Decompresses part or all of an ZSTD frame of compressed data."""

        ...
