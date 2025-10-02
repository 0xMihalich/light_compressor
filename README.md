# Light Compressor

This library is designed to provide optimal decompression and compression speed for data streams from databases and files.
My project requires maximum-speed processing of byte streams and transferring compressed data to another stream.
After testing all available solutions, I found their speed unsatisfactory, so I optimized the existing implementation to achieve better performance.

The stream reader use direct sequential reading from the stream with explicit size indication.
This meets all requirements for my project.
Supported compression formats: **LZ4** and **ZSTD** only.

## Examples

### File detect compression only

```python
from light_compressor import auto_detector
fileobj = open("some_path_to_file.bin", "rb")
compressor_method = auto_detector(fileobj)
```

### File reading

When reading from files, automatic compression format detection is available (checks for LZ4/ZSTD signatures or no compression):

```python
from light_compressor import define_reader
fileobj = open("some_path_to_file.bin", "rb")
decompressed_stream = define_reader(fileobj)
```

### File writing

```python
from light_compressor import (
    LZ4Compressor,
    ZSTDCompressor,
)
# some data in bytes
bytes_data: list[bytes]
# for example we using ZSTDCompressor
compressor = ZSTDCompressor()
fileobj = open("some_path_to_file.bin", "wb")

for data in compressor.send_chunks(bytes_data):
    fileobj.write(data)

print("Original size is:", compressor.decompressed_size)
print("Compressed size is:", fileobj.tell())

fileobj.close()
```

### Stream reading

For stream processing, the compression method must be explicitly specified

```python
from light_compressor import (
    define_reader,
    CompressionMethod,
)
compressed_stream: urllib3.response.HTTPResponse
# Get decompressed file-like object from ZSTD-compressed stream
decompressed_stream = define_reader(compressed_stream, CompressionMethod.ZSTD)
```

### Stream writing

```python
from light_compressor import (
    define_writer,
    CompressionMethod,
)
# some data in bytes
bytes_data: list[bytes]
# Get generator yielding ZSTD-compressed byte chunks
compressed_stream = define_writer(bytes_data, CompressionMethod.ZSTD)
```

## Installation

From pip

```bash
pip install light-compressor
```

From local directory

```bash
pip install .
```

From git

```bash
pip install git+https://github.com/0xMihalich/light_compressor
```
