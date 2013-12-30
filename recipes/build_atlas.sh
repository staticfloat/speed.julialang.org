#!/bin/bash
# julia installation that uses julia-compiled openblas

BUILDOPTS="USE_BLAS64=0 USE_ATLAS=1 USE_QUIET=0"
if [[ "$(uname)" == "Darwin" ]]; then
    SYS_LIBS="LLVM ZLIB FFTW GMP MPFR PCRE"
elif [[ "$(uname)" == "Linux" ]]; then
    BUILDOPTS="$BUILDOPTS LLVM_CONFIG=llvm-config-3.3 LLVM_LLC=llc-3.3"
    SYS_LIBS="LLVM ZLIB FFTW GMP MPFR PCRE LIBUNWIND READLINE GRISU RMATH"
fi
for lib in $SYS_LIBS; do
    export BUILDOPTS="$BUILDOPTS USE_SYSTEM_$lib=1"
done
make -C deps $BUILDOPTS compile-atlas -j1
echo make $BUILDOPTS
make $BUILDOPTS
