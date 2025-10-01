cdef class ZSTDDecompressor:

    cdef public object _dctx
    cdef public object eof
    cdef public object needs_input
    cdef public bytes unused_data
    cdef public bytes _unconsumed_data
    cdef public object _return_bytearray
    cdef public object _in_buffer
    cdef public object _input_buffer
    cdef public bytes _input_data

    cpdef void reset(self)
    cpdef bytes decompress(
        self,
        object data,
        long long max_length=*,
    )
