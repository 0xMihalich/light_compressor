from collections.abc import Generator
from typing import Iterable


class LZ4Compressor:
    """LZ4 chunk compressor."""

    def __init__(self) -> None:
        """Class inialization."""

        self.context: object
        self.decompressed_size: int
        ...

    def send_chunks(
        self,
        bytes_data: Iterable[bytes],
    ) -> Generator[bytes, None, None]:
        """Generate compressed chunks from bytes chunks."""

        ...
