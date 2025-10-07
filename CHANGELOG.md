# Version History

## 0.0.1.6

* Refactor functions check: replace == to is

## 0.0.1.5

* Add MANIFEST.in
* Add CHANGELOG.md to pip package
* Improve pyproject.toml license file approve

## 0.0.1.4

* Add auto_detector(fileobj) function to detect compression from file
* Update README.md

## 0.0.1.3

* Refactor ZSTDCompressor
* Add test auto compression detection
* Rename tests/tests.py to tests/test_all.py
* Update README.md

## 0.0.1.2

* Add MIT License
* Update depends in pyproject.toml

## 0.0.1.1

* Fix & Refactor define_writer
* Add cffi to requirements.txt
* Add tests
* Add attribute decompressed_size for LZ4Compressor & ZSTDCompressor
* Change error message for define_reader & define_writer
* Change chunk size to 128 items in list of compressed_chunks
* Translate README.md to english and add more examples
* Development Status change to 4 (Beta)
* Revision python versions

## 0.0.1.0

* Improve dependencies in pyproject.toml
* Change compression method select from method_type to CompressionMethod
* Add compressors
* Add define_writer
* Update README.md

## 0.0.0.1

First version of the library

* Light versions of lz4 and zstandard streams for read only objects
