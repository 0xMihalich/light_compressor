from lz4.frame._frame import (
    create_decompression_context,
    decompress_chunk,
    reset_decompression_context,
)


cdef class LZ4Decompressor:
    """LZ4 frame cython decompressor."""

    def __init__(self):

        self._context = create_decompression_context()
        self.eof = False
        self.needs_input = True
        self.unused_data = b""
        self._unconsumed_data = b""
        self._return_bytearray = False

    def __enter__(self):

        return self

    def __exit__(
        self,
        object exception_type,
        object exception,
        object traceback,
    ):

        self._context = None
        self.eof = None
        self.needs_input = None
        self.unused_data = None
        self._unconsumed_data = None
        self._return_bytearray = None

    cpdef void reset(self):
        """Reset the decompressor state."""

        reset_decompression_context(self._context)
        self.eof = False
        self.needs_input = True
        self.unused_data = None
        self._unconsumed_data = None

    cpdef bytes decompress(
        self,
        object data,
        long long max_length = -1,
    ):
        """Decompresses part or all of an LZ4 frame of compressed data."""

        cdef bytes decompressed
        cdef long long bytes_read
        cdef object eoframe

        if not isinstance(data, (bytes, bytearray)):
            data = memoryview(data).tobytes()

        if self._unconsumed_data:
            data = self._unconsumed_data + data

        decompressed, bytes_read, eoframe = decompress_chunk(
            self._context,
            data,
            max_length=max_length,
            return_bytearray=self._return_bytearray,
        )

        if bytes_read < len(data):
            if eoframe:
                self.unused_data = data[bytes_read:]
            else:
                self._unconsumed_data = data[bytes_read:]
                self.needs_input = False
        else:
            self._unconsumed_data = b""
            self.needs_input = True
            self.unused_data = b""

        self.eof = eoframe

        return decompressed
