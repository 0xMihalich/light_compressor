from setuptools import (
    Extension,
    setup,
)
from Cython.Build import cythonize


extensions = [
    Extension(
        "light_compressor.compressors.lz4",
        ["src/light_compressor/compressors/lz4.pyx"],
    ),
    Extension(
        "light_compressor.compressors.zstd",
        ["src/light_compressor/compressors/zstd.pyx"],
    ),
    Extension(
        "light_compressor.decompressors.lz4",
        ["src/light_compressor/decompressors/lz4.pyx"],
    ),
    Extension(
        "light_compressor.decompressors.zstd",
        ["src/light_compressor/decompressors/zstd.pyx"],
    ),
]

setup(
    name="light_compressor",
    package_dir={"": "src"},
    ext_modules=cythonize(extensions, language_level="3"),
    packages=[
        "light_compressor.decompressors",
    ],
    package_data={
        "light_compressor": [
            "**/*.pyx", "**/*.pxd", "*.pxd", "*.pyd", "*.md", "*.txt",
        ]
    },
    exclude_package_data={
        "": ["*.c"],
        "light_compressor": ["**/*.c"],
    },
    include_package_data=True,
    setup_requires=["Cython>=3.0"],
    zip_safe=False,
)
