cdef class ZSTDCompressor:

    cdef public object context
    cdef public object compression_level
    cdef public unsigned long long decompressed_size
