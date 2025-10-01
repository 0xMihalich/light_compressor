from zstandard._cffi import (
    ffi,
    lib,
)


cdef class ZSTDDecompressor:
    """ZSTD frame cython decompressor."""

    def __init__(self):

        self._dctx = lib.ZSTD_createDCtx()

        if self._dctx == ffi.NULL:
            raise MemoryError("Unable to create ZSTD decompression context")
        
        self._dctx = ffi.gc(
            self._dctx, 
            lib.ZSTD_freeDCtx, 
            size=lib.ZSTD_sizeof_DCtx(self._dctx)
        )
        
        self.eof = False
        self.needs_input = True
        self.unused_data = b""
        self._unconsumed_data = b""
        self._return_bytearray = False
        self._in_buffer = ffi.new("ZSTD_inBuffer *")
        self._input_buffer = None
        self._input_data = None

    def __enter__(self):

        return self

    def __exit__(
        self,
        object exception_type,
        object exception,
        object traceback,
    ):

        self._dctx = None
        self.eof = None
        self.needs_input = None
        self.unused_data = None
        self._unconsumed_data = None
        self._return_bytearray = None
        self._input_buffer = None
        self._input_data = None

    cpdef void reset(self):
        """Reset the decompressor state."""

        cdef unsigned long long decompressed_size
        
        decompressed_size = lib.ZSTD_DCtx_reset(self._dctx, lib.ZSTD_reset_session_only)

        if lib.ZSTD_isError(decompressed_size):
            raise RuntimeError("Unable to reset ZSTD context")
        
        self.eof = False
        self.needs_input = True
        self.unused_data = None
        self._unconsumed_data = None
        self._in_buffer.pos = 0
        self._in_buffer.size = 0
        self._input_buffer = None
        self._input_data = None

    cpdef bytes decompress(
        self,
        object data,
        long long max_length = -1,
    ):
        """Decompresses part or all of ZSTD compressed data."""

        cdef object out_buffer, out_data, input_cdata
        cdef size_t output_size
        cdef unsigned long long decompressed_size
        
        if max_length == -1:
            output_size = lib.ZSTD_DStreamOutSize()
        else:
            if max_length > 0:
                output_size = max_length
            else:
                output_size = lib.ZSTD_DStreamOutSize()

        out_data = ffi.new("char[]", output_size)
        out_buffer = ffi.new("ZSTD_outBuffer *")
        out_buffer.dst = out_data
        out_buffer.size = output_size
        out_buffer.pos = 0

        if data.__class__ not in (bytes, bytearray):
            data = memoryview(data).tobytes()

        if self._unconsumed_data:
            data = self._unconsumed_data + data
            self._unconsumed_data = b""

        if data:
            self._input_data = data
            input_cdata = ffi.from_buffer(self._input_data)
            self._in_buffer.src = input_cdata
            self._in_buffer.size = len(data)
            self._in_buffer.pos = 0
        else:
            self._in_buffer.src = ffi.NULL
            self._in_buffer.size = 0
            self._in_buffer.pos = 0
            self._input_data = None

        decompressed_size = lib.ZSTD_decompressStream(
            self._dctx,
            out_buffer,
            self._in_buffer,
        )
        
        if lib.ZSTD_isError(decompressed_size):
            raise RuntimeError("ZSTD decompression error")

        if self._in_buffer.pos < self._in_buffer.size:
            if data:
                remaining_data = data[self._in_buffer.pos:]
            else:
                remaining_data = b""

            if decompressed_size == 0:
                self.unused_data = remaining_data
                self._unconsumed_data = b""
            else:
                self._unconsumed_data = remaining_data
                self.unused_data = b""

            self.needs_input = False
        else:
            self._unconsumed_data = b""
            self.unused_data = b""
            self.needs_input = True

        self.eof = (decompressed_size == 0)
        return ffi.buffer(out_data, out_buffer.pos)[:]
