cdef class LZ4Compressor:

    cdef public object context
    cdef public unsigned long long decompressed_size
