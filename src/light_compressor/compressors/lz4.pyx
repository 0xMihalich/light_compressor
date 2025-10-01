from lz4.frame._frame import (
    create_compression_context,
    compress_begin,
    compress_chunk,
    compress_flush,
)


cdef class LZ4Compressor:
    """LZ4 chunk compressor."""

    def __init__(self):
        """Class inialization."""

        self.context = create_compression_context()
        self.decompressed_size = 0

    def send_chunks(
        self,
        object bytes_data,
    ):
        """Generate compressed chunks from bytes chunks."""

        cdef list compressed_chunks = []
        cdef bytes data_chunk, compressed
        self.decompressed_size = 0

        compressed = compress_begin(self.context)
        compressed_chunks.append(compressed)

        for data_chunk in bytes_data:
            if len(compressed_chunks) > 128:
                yield b"".join(compressed_chunks)
                compressed_chunks.clear()

            self.decompressed_size += len(data_chunk)
            compressed = compress_chunk(self.context, data_chunk)

            if compressed:
                compressed_chunks.append(compressed)

        compressed = compress_flush(self.context)

        if compressed:
            compressed_chunks.append(compressed)

        if compressed_chunks:
            yield b"".join(compressed_chunks)
