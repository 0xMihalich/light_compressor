cdef class ZSTDStreamReader:

    cdef public object _source
    cdef public object _dctx
    cdef public unsigned long long _read_size
    cdef public object _read_across_frames
    cdef public object _closefd
    cdef public object _entered
    cdef public object _closed
    cdef public unsigned long long _bytes_decompressed
    cdef public object _finished_input
    cdef public object _finished_output
    cdef public object _in_buffer
    cdef public object _source_buffer

    cpdef object readable(self)
    cpdef object writable(self)
    cpdef object seekable(self)
    cpdef object isatty(self)
    cpdef void close(self)
    cpdef unsigned long long tell(self)
    cdef bytes readall(self)
    cdef void _read_input(self)
    cdef unsigned char _decompress_into_buffer(
        self,
        object out_buffer,
    )
    cpdef bytes read(
        self,
        long long size=*,
    )
