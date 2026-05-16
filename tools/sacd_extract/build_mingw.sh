#!/bin/bash
# Cross-compile sacd_extract.exe for Windows using mingw-w64
# Run this from: tools/sacd_extract/
# Prerequisite: sudo apt install mingw-w64 cmake make

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJ_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ICONV_DIR="$PROJ_DIR/libs/libiconv-mingw"
ICONV_SRC="$PROJ_DIR/libs/libiconv-1.15"

# Step 1: Build libiconv if not already built
if [ ! -f "$ICONV_DIR/lib/libiconv.a" ]; then
    echo "=== Building libiconv-1.15 for mingw-w64 ==="
    if [ ! -d "$ICONV_SRC" ]; then
        cd "$PROJ_DIR/libs"
        tar xzf libiconv-1.15.tar.gz
    fi
    cd "$ICONV_SRC"
    ./configure --host=x86_64-w64-mingw32 --prefix="$PROJ_DIR/libs/libiconv-mingw" \
        --enable-static --disable-shared -q
    make -j$(nproc)
    make install
    echo "=== libiconv built ==="
fi

# Step 2: Build sacd_extract
echo "=== Building sacd_extract ==="
cd "$SCRIPT_DIR"
cmake -DMINGW64=YES \
    -DCMAKE_C_FLAGS="-I$ICONV_DIR/include" \
    -DCMAKE_EXE_LINKER_FLAGS="-L$ICONV_DIR/lib" \
    .

make -j$(nproc)

echo "=== Done: $SCRIPT_DIR/sacd_extract.exe ==="
ls -lh sacd_extract.exe
