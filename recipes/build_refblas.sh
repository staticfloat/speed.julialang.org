#!/bin/bash
# Really basic julia installation, ripped straight from Travis compilation procedure

BUILDOPTS="LLVM_CONFIG=llvm-config-3.2 USE_BLAS64=0"
for lib in LLVM ZLIB SUITESPARSE ARPACK BLAS FFTW LAPACK GMP MPFR PCRE LIBUNWIND READLINE GRISU OPENLIBM RMATH; do
    export BUILDOPTS="$BUILDOPTS USE_SYSTEM_$lib=1"
done
make $BUILDOPTS

