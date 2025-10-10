from collections.abc import Generator
from typing import Iterable


class ZSTDCompressor:
    """ZSTD data_chunk compressor."""

    def __init__(
        self,
        compression_level: int = 3,
    ) -> None:
        """Class inialization."""

        self.context: object
        self.compression_level: int
        self.decompressed_size: int
        self._out_buffer_struct: object
        self._in_buffer_struct: object
        self._dst_buffer: object
        self._src_buffer: object
        self._dst_capacity: int
        ...

    def send_chunks(
        self,
        bytes_data: Iterable[bytes],
    ) -> Generator[bytes, None, None]:
        """Generate compressed chunks from bytes chunks."""

        ...
