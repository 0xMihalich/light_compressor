from zstandard._cffi import (
    ffi,
    lib,
)


cdef class ZSTDCompressor:
    """ZSTD data_chunk compressor."""

    def __init__(
        self,
        short compression_level = 3,
    ):
        """Class inialization."""

        self.context = lib.ZSTD_createCCtx()
        self.compression_level = compression_level
        self.decompressed_size = 0
        self._out_buffer_struct = ffi.new("ZSTD_outBuffer *", {
            "dst": ffi.NULL,
            "size": 0,
            "pos": 0
        })
        self._in_buffer_struct = ffi.new("ZSTD_inBuffer *", {
            "src": ffi.NULL,
            "size": 0, 
            "pos": 0
        })
        self._dst_buffer = None
        self._src_buffer = None
        self._dst_capacity = 0

        if self.context == ffi.NULL:
            raise MemoryError("Failed to create compression context")

        lib.ZSTD_CCtx_setParameter(
            self.context,
            lib.ZSTD_c_compressionLevel,
            self.compression_level,
        )

    cdef void _setup_buffers(self, unsigned long long data_chunk_size):

        cdef object dst_capacity = lib.ZSTD_compressBound(data_chunk_size)

        if dst_capacity > self._dst_capacity:
            self._dst_buffer = ffi.new("char[]", dst_capacity)
            self._dst_capacity = dst_capacity

        self._out_buffer_struct.dst = self._dst_buffer
        self._out_buffer_struct.size = self._dst_capacity
        self._out_buffer_struct.pos = 0
        
    cdef unsigned long long _setup_input_buffer(self, bytes data_chunk):

        cdef unsigned long long data_chunk_size = len(data_chunk)
        self._src_buffer = ffi.from_buffer(data_chunk)
        self._in_buffer_struct.src = self._src_buffer
        self._in_buffer_struct.size = data_chunk_size
        self._in_buffer_struct.pos = 0
        
        return data_chunk_size

    cdef list _compress_stream(self, object operation):

        cdef list compressed_chunks = []
        cdef object remaining, error_name
        cdef bytes compressed

        while self._in_buffer_struct.pos < self._in_buffer_struct.size:
            remaining = lib.ZSTD_compressStream2(
                self.context,
                self._out_buffer_struct,
                self._in_buffer_struct,
                operation,
            )

            if lib.ZSTD_isError(remaining):
                error_name = ffi.string(lib.ZSTD_getErrorName(remaining))
                raise ValueError(f"Compression error: {error_name}")

            if self._out_buffer_struct.pos > 0:
                compressed = bytes(ffi.buffer(
                    self._out_buffer_struct.dst,
                    self._out_buffer_struct.pos,
                ))
                compressed_chunks.append(compressed)
                self._out_buffer_struct.pos = 0

        return compressed_chunks

    cdef list _end_compression(self):

        cdef list compressed_chunks = []
        cdef object remaining, error_name
        cdef bytes compressed

        self._in_buffer_struct.src = ffi.NULL
        self._in_buffer_struct.size = 0
        self._in_buffer_struct.pos = 0
        self._out_buffer_struct.pos = 0

        while 1:
            remaining = lib.ZSTD_compressStream2(
                self.context,
                self._out_buffer_struct,
                self._in_buffer_struct,
                lib.ZSTD_e_end,
            )

            if lib.ZSTD_isError(remaining):
                error_name = ffi.string(lib.ZSTD_getErrorName(remaining))
                raise ValueError(f"Compression end error: {error_name}")

            if self._out_buffer_struct.pos > 0:
                compressed = bytes(ffi.buffer(
                    self._out_buffer_struct.dst,
                    self._out_buffer_struct.pos,
                ))
                compressed_chunks.append(compressed)
                self._out_buffer_struct.pos = 0

            if remaining == 0:
                break

        return compressed_chunks

    def send_chunks(
        self,
        object bytes_data,
    ):
        """Generate compressed chunks from bytes chunks."""

        cdef list chunk_result, end_result, compressed_chunks = []
        cdef bytes data_chunk
        cdef unsigned long long data_chunk_size

        self.decompressed_size = 0

        for data_chunk in bytes_data:
            if len(compressed_chunks) > 128:
                yield b"".join(compressed_chunks)
                compressed_chunks.clear()

            data_chunk_size = self._setup_input_buffer(data_chunk)
            self.decompressed_size += data_chunk_size
            self._setup_buffers(data_chunk_size)
            chunk_result = self._compress_stream(lib.ZSTD_e_continue)
            compressed_chunks.extend(chunk_result)

        end_result = self._end_compression()
        compressed_chunks.extend(end_result)

        yield b"".join(compressed_chunks)
        lib.ZSTD_freeCCtx(self.context)
