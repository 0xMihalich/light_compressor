cdef class ZSTDCompressor:

    cdef public object context
    cdef public short compression_level
    cdef public unsigned long long decompressed_size
    cdef public object _out_buffer_struct
    cdef public object _in_buffer_struct
    cdef public object _dst_buffer
    cdef public object _src_buffer
    cdef public object _dst_capacity

    cdef void _setup_buffers(self, unsigned long long data_chunk_size)
    cdef unsigned long long _setup_input_buffer(self, bytes data_chunk)
    cdef list _compress_stream(self, object operation)
    cdef list _end_compression(self)
