#!/bin/bash
# julia installation that uses system-provided blas

BUILDOPTS="USE_BLAS64=0"
if [[ "$(uname)" == "Darwin" ]]; then
    SYS_LIBS="LLVM ZLIB FFTW GMP MPFR PCRE BLAS"
elif [[ "$(uname)" == "Linux" ]]; then
    BUILDOPTS="LLVM_CONFIG=llvm-config-3.2"
    SYS_LIBS="LLVM ZLIB FFTW GMP MPFR PCRE LIBUNWIND READLINE GRISU OPENLIBM RMATH BLAS LAPACK"
fi
for lib in SYS_LIBS; do
    export BUILDOPTS="$BUILDOPTS USE_SYSTEM_$lib=1"
done
make $BUILDOPTS
