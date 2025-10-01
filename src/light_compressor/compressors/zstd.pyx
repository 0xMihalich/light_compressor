from zstandard._cffi import (
    ffi,
    lib,
)


cdef class ZSTDCompressor:
    """ZSTD data_chunk compressor."""

    cdef object context
    cdef object compression_level

    def __init__(
        self,
        int compression_level = 3,
    ):
        """Class inialization."""

        self.context = lib.ZSTD_createCCtx()
        self.compression_level = compression_level

        if self.context == ffi.NULL:
            raise MemoryError("Failed to create compression context")

        lib.ZSTD_CCtx_setParameter(
            self.context,
            lib.ZSTD_c_compressionLevel,
            self.compression_level,
        )

    def send_chunks(
        self,
        object bytes_data,
    ):
        """Generate compressed chunks from bytes chunks."""

        cdef list compressed_chunks = []
        cdef bytes data_chunk, compressed
        cdef object src_buffer, dst_capacity
        cdef object dst_buffer, out_buffer, in_buffer

        for data_chunk in bytes_data:
            if len(compressed_chunks) > 1024:
                yield b"".join(compressed_chunks)
                compressed_chunks.clear()

            src_buffer = ffi.from_buffer(data_chunk)
            dst_capacity = lib.ZSTD_compressBound(len(data_chunk))
            dst_buffer = ffi.new("char[]", dst_capacity)
            out_buffer = ffi.new(
                "ZSTD_outBuffer *",
                {"dst": dst_buffer, "size": dst_capacity, "pos": 0},
            )
            in_buffer = ffi.new(
                "ZSTD_inBuffer *",
                {"src": src_buffer, "size": len(data_chunk), "pos": 0},
            )

            while in_buffer.pos < in_buffer.size:
                remaining = lib.ZSTD_compressStream2(
                    self.context,
                    out_buffer,
                    in_buffer,
                    lib.ZSTD_e_continue,
                )

                if lib.ZSTD_isError(remaining):
                    error_name = ffi.string(lib.ZSTD_getErrorName(remaining))
                    raise Exception(f"Compression error: {error_name}")

                if out_buffer.pos > 0:
                    compressed = bytes(
                        ffi.buffer(out_buffer.dst, out_buffer.pos)
                    )
                    compressed_chunks.append(compressed)
                    out_buffer.pos = 0

        dst_capacity = lib.ZSTD_compressBound(0)
        dst_buffer = ffi.new("char[]", dst_capacity)
        out_buffer = ffi.new(
            "ZSTD_outBuffer *",
            {"dst": dst_buffer, "size": dst_capacity, "pos": 0},
        )
        in_buffer = ffi.new(
            "ZSTD_inBuffer *",
            {"src": ffi.NULL, "size": 0, "pos": 0},
        )

        while 1:
            remaining = lib.ZSTD_compressStream2(
                self.context,
                out_buffer,
                in_buffer,
                lib.ZSTD_e_end,
            )

            if lib.ZSTD_isError(remaining):
                error_name = ffi.string(lib.ZSTD_getErrorName(remaining))
                raise Exception(f"Compression end error: {error_name}")

            if out_buffer.pos > 0:
                compressed = bytes(ffi.buffer(out_buffer.dst, out_buffer.pos))
                compressed_chunks.append(compressed)
                out_buffer.pos = 0

            if remaining == 0:
                break

        yield b"".join(compressed_chunks)
        lib.ZSTD_freeCCtx(self.context)
