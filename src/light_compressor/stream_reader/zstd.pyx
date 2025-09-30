from zstandard._cffi import (
    ffi,
    lib,
)


cdef unsigned long DEFAULT_SIZE = 1048576


cdef class ZSTDStreamReader:
    """ZSTD reader for stream."""

    def __init__(
        self,
        object source,
    ):
        """Class initialization."""

        self._source = source
        self._dctx = lib.ZSTD_createDCtx()
        self._read_size = lib.ZSTD_DStreamInSize()
        self._read_across_frames = False
        self._closefd = True
        self._entered = False
        self._closed = False
        self._bytes_decompressed = 0
        self._finished_input = False
        self._finished_output = False
        self._in_buffer = ffi.new("ZSTD_inBuffer *")
        self._source_buffer = None

    def __enter__(self):
        """Enter context manager."""

        if self._entered:
            raise ValueError("cannot __enter__ multiple times")

        if self._closed:
            raise ValueError("stream is closed")

        self._entered = True
        return self

    def __exit__(self, exc_type, exc_value, exc_tb):
        """Exit context manager."""

        self._entered = False
        self._dctx = None
        self.close()
        self._source = None
        return False

    cpdef object readable(self):

        return True

    cpdef object writable(self):

        return False

    cpdef object seekable(self):

        return False

    cpdef object isatty(self):

        return False

    cpdef void close(self):

        if self._closed:
            return

        self._source.close()
        self._closed = True

    @property
    def closed(self):
        return self._closed

    cpdef unsigned long long tell(self):

        return self._bytes_decompressed

    cdef bytes readall(self):

        cdef list chunks = []

        while True:
            chunk = self.read(DEFAULT_SIZE)

            if not chunk:
                break

            chunks.append(chunk)

        return b"".join(chunks)

    cdef void _read_input(self):

        if self._in_buffer.pos < self._in_buffer.size:
            return

        if self._finished_input:
            return

        cdef bytes data = self._source.read(self._read_size)

        if not data:
            self._finished_input = True
            return

        self._source_buffer = ffi.from_buffer(data)
        self._in_buffer.src = self._source_buffer
        self._in_buffer.size = len(self._source_buffer)
        self._in_buffer.pos = 0

    cdef unsigned char _decompress_into_buffer(
        self,
        object out_buffer,
    ):
        """Decompress available input into an output buffer."""

        cdef unsigned long long zresult = lib.ZSTD_decompressStream(
            self._dctx, out_buffer, self._in_buffer
        )

        if self._in_buffer.pos == self._in_buffer.size:
            self._in_buffer.src = ffi.NULL
            self._in_buffer.pos = 0
            self._in_buffer.size = 0
            self._source_buffer = None

        if lib.ZSTD_isError(zresult):
            raise ValueError("zstd decompress error")

        return out_buffer.pos and (
                out_buffer.pos == out_buffer.size
                or zresult == 0
                and not self._read_across_frames
        )

    cpdef bytes read(
        self,
        long long size = -1,
    ):

        if self._closed:
            raise ValueError("stream is closed")

        if size < -1:
            raise ValueError("cannot read negative amounts less than -1")

        if size == -1:
            return self.readall()

        if self._finished_output or size == 0:
            return b""

        cdef object dst_buffer = ffi.new("char[]", size)
        cdef object out_buffer = ffi.new("ZSTD_outBuffer *")
        out_buffer.dst = dst_buffer
        out_buffer.size = size
        out_buffer.pos = 0

        self._read_input()
        if self._decompress_into_buffer(out_buffer):
            self._bytes_decompressed += out_buffer.pos
            return ffi.buffer(out_buffer.dst, out_buffer.pos)[:]

        while not self._finished_input:
            self._read_input()
            if self._decompress_into_buffer(out_buffer):
                self._bytes_decompressed += out_buffer.pos
                return ffi.buffer(out_buffer.dst, out_buffer.pos)[:]

        self._bytes_decompressed += out_buffer.pos
        return ffi.buffer(out_buffer.dst, out_buffer.pos)[:]
