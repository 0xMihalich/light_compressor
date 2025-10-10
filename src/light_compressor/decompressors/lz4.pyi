

class LZ4Decompressor:
    """LZ4 frame cython decompressor."""

    def __init__(self) -> None:
        """Class inialization."""

        self._context: object
        self.eof: bool
        self.needs_input: bool
        self.unused_data: bytes
        self._unconsumed_data: bytes
        self._return_bytearray: bool
        ...

    def __enter__(self) -> "LZ4Decompressor":
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
        """Decompresses part or all of an LZ4 frame of compressed data."""

        ...
