from io import BytesIO
from random import (
    randbytes,
    randint,
)
from light_compressor import (
    define_reader,
    define_writer,
    CompressionMethod,
    LZ4Compressor,
    ZSTDCompressor,
)


fileobj = BytesIO()

bytes_data = [
    randbytes(randint(10, 40))  # noqa: S311
    for _ in range(100)
] * 10


def decompress(compression_method: CompressionMethod) -> None:

    fileobj.seek(0)
    full_data = b"".join(bytes_data)
    decompressed_size = len(full_data)
    stream = define_reader(fileobj, compression_method)
    assert full_data == stream.read(decompressed_size)  # noqa: S101


def test_file() -> None:

    for compression_method in (
        CompressionMethod.LZ4,
        CompressionMethod.ZSTD,
    ):
        fileobj.seek(0)
        fileobj.truncate()
        full_data = b"".join(bytes_data)
        decompressed_size = len(full_data)
        print(f"start check for {compression_method.name}")

        if compression_method == CompressionMethod.LZ4:
            compressor = LZ4Compressor()
        elif compression_method == CompressionMethod.ZSTD:
            compressor = ZSTDCompressor()

        for data in compressor.send_chunks(bytes_data):
            fileobj.write(data)

        assert decompressed_size == compressor.decompressed_size  # noqa: S101

        decompress(compression_method)


def test_stream() -> None:

    for compression_method in (
        CompressionMethod.LZ4,
        CompressionMethod.ZSTD,
    ):

        fileobj.seek(0)
        fileobj.seek(0)
        fileobj.truncate()

        for data in define_writer(bytes_data, compression_method):
            fileobj.write(data)

        decompress(compression_method)
