#!/bin/bash

# This script builds a toolchain including binutils, gcc, and glibc
# (including ld-linux-aarch64.so.1, libc, and libm) under ${INSTALLDIR}.
# This GCC is intended for benchmarking purposes only and may not work with
# packages and libraries installed on an Arm system and built with a different
# compiler.

# Set INSTALLDIR to an absolute pathname where you want the compiler before
# running this script or pass in an absolute pathname as the argument to this
# script.

INSTALLDIR=$1

DO_MULTILIB=$2
if [ "$DO_MULTILIB" = "TRUE" ]; then
  MULTILIB_CONF="--with-multilib-list=lp64,ilp32"
else
  MULTILIB_CONF=""
fi

DO_LIBMVEC=$3
if [ "$DO_LIBMVEC" = "TRUE" ]; then
  LIBMVEC_CONF="--enable-mathvec"
else
  LIBMVEC_CONF=""
fi

# INSTALLDIR=SETME

PARALLEL_BUILD=-j$(nproc)
TARGET=aarch64-linux-gnu
CONF="--prefix=${INSTALLDIR} --with-sysroot=${INSTALLDIR} \
  --target=$TARGET --host=$TARGET --build=$TARGET"
BINUTILS_CONF="${CONF}"
INIT_GCC_CONF="--with-newlib --without-headers \
               --enable-languages=c --enable-threads=no \
               --disable-shared --disable-decimal-float \
               --disable-libsanitizer --disable-bootstrap"
FINAL_GCC_CONF="--enable-languages=c,c++,fortran \
                --disable-libsanitizer --enable-bootstrap \
                --enable-threads --enable-shared"
GCC_CONF="${CONF} --enable-gnu-indirect-function \
          --with-advance-toolchain=${INSTALLDIR} ${MULTILIB_CONF}"
GLIBC_CONF="--with-headers=${INSTALLDIR}/usr/include \
            ${LIBMVEC_CONF} --enable-obsolete-rpc \
            --prefix=/usr --host=${TARGET}"


make_dir()
{
  DIR=$1
  if [ ! -d ${DIR} ]; then
    mkdir ${DIR}
    echo "${DIR} successfully created."
  fi
}

check_error()
{
  RET=$1
  MSG=$2
  if [ ${RET} != 0 ]; then
    echo ${MSG}
    exit 1
  else
    echo "SUCCESS: ${MSG} successful"
  fi
}

make_tar()
{
   # Create tar.bz2 for the installdir
   if [ -d ${INSTALLDIR} ]; then
     tar -cvzf toolchain-tot-ilp32.tar.bz2 ${INSTALLDIR}
     echo "Successfully created tar file from ${INSTALLDIR}"
  fi   
}

get_sources()
{
  # Get the GCC sources
  if [ ! -d gcc ]; then
     git clone https://github.com/MarvellServer/ThunderX-Toolchain-gcc-ilp32.git gcc
     cd gcc
     ./contrib/download_prerequisites
     cd ..
  fi

  # Get the Binutils-gdb sources
  if [ ! -d binutils-gdb ]; then
    git clone http://sourceware.org/git/binutils-gdb.git binutils-gdb
  fi

  # Get the GLIBC sources
  if [ ! -d glibc ]; then
    git clone https://github.com/MarvellServer/ThunderX-Toolchain-glibc-ilp32.git -b v-0.2 glibc
  fi

  # Get the ILP32 supported linux kernel sources
  if [ ! -d linux ]; then
    git clone https://github.com/MarvellServer/ThunderX-TXOS.git -b next linux
  fi
}

make_binutils()
{
  if [ ! -d obj-binutils ]; then
    mkdir obj-binutils
    cd obj-binutils
    ../binutils-gdb/configure ${BINUTILS_CONF}
  else
    cd obj-binutils
  fi
  make ${PARALLEL_BUILD} all && make install
  check_error $? "binutils build"
  cd ..
}

make_init_gcc()
{
  if [ ! -d obj-gcc-init ]; then
    mkdir obj-gcc-init
    cd obj-gcc-init
    cd ../gcc
    git rev-parse HEAD > gcc/REVISION
    echo "Marvell" > gcc/gcc/DEV-PHASE
    BASEVER=`cat gcc/BASE-VER`
    cd -
    export LDFLAGS="-L${INSTALLDIR}/lib/gcc/aarch64-linux-gnu/${BASEVER} -lgcc"
    ../gcc/configure ${GCC_CONF} ${INIT_GCC_CONF}
  else
    cd obj-gcc-init
  fi
  make ${PARALLEL_BUILD} all-gcc all-target-libgcc && make install-gcc install-target-libgcc
  check_error $? "Initial gcc build"
  cd ..
}

make_linux_headers()
{
  cd linux
  export CC=/usr/bin/gcc
  make headers_install ARCH=arm64 \
    INSTALL_HDR_PATH=${INSTALLDIR}/usr HOSTCC=/usr/bin/gcc
  check_error $? "linux header build"
  unset CC
  cd ..
}

make_glibc64()
{
  export BUILD_CC=/usr/bin/gcc
  export CC="$INSTALLDIR/bin/$TARGET-gcc -mabi=lp64"
  export CXX="$INSTALLDIR/bin/$TARGET-g++ -mabi=lp64"
  export AR="$TARGET-ar"
  export RANLIB="$TARGET-ranlib"
  export AS="$TARGET-as"
  export LD="$TARGET-ld"

  if [ ! -d obj-glibc64 ]; then
    mkdir obj-glibc64
    cd obj-glibc64
    ../glibc/configure ${GLIBC_CONF}
  else
    cd obj-glibc64
  fi
  make ${PARALLEL_BUILD} all && make DESTDIR=$INSTALLDIR install
  check_error $? "glibc64 build"

  cd ..
  unset BUILD_CC CC CXX AR RANLIB AS LD
}

make_glibc32()
{
  export BUILD_CC=/usr/bin/gcc
  export CC="$INSTALLDIR/bin/$TARGET-gcc -mabi=ilp32"
  export CXX="$INSTALLDIR/bin/$TARGET-g++ -mabi=ilp32"
  export AR="$TARGET-ar"
  export RANLIB="$TARGET-ranlib"
  export AS="$TARGET-as"
  export LD="$TARGET-ld"

  if [ ! -d obj-glibc32 ]; then
    mkdir obj-glibc32
    cd obj-glibc32
    ../glibc/configure ${GLIBC_CONF}
  else
    cd obj-glibc32
  fi
  make ${PARALLEL_BUILD} all && make DESTDIR=$INSTALLDIR install
  check_error $? "glibc32 build"

  cd ..
  unset BUILD_CC CC CXX AR RANLIB AS LD
}

make_gcc()
{
  if [ ! -d obj-gcc ]; then
    mkdir obj-gcc
    cd obj-gcc
    cd ../gcc
    git rev-parse HEAD > gcc/REVISION
    echo "Marvell" > gcc/gcc/DEV-PHASE
    BASEVER=`cat gcc/BASE-VER`
    cd -
    export LDFLAGS="-L${INSTALLDIR}/lib/gcc/aarch64-linux-gnu/${BASEVER} -lgcc"
    ../gcc/configure ${GCC_CONF} ${FINAL_GCC_CONF}
  else
    cd obj-gcc
  fi
  make ${PARALLEL_BUILD} all && make install
  check_error $? "gcc build"
  cd ..
}


export PATH=${INSTALLDIR}/bin:${INSTALLDIR}/usr/bin:${PATH}
if [ "${INSTALLDIR}" = "SETME" ]; then
  check_error 1 "Set INSTALLDIR to where you want the compiler."
fi

make_dir ${INSTALLDIR}
make_dir ${INSTALLDIR}/lib
make_dir ${INSTALLDIR}/lib64
make_dir ${INSTALLDIR}/libilp32
make_dir ${INSTALLDIR}/include
make_dir ${INSTALLDIR}/usr
make_dir ${INSTALLDIR}/usr/lib
make_dir ${INSTALLDIR}/usr/lib64
make_dir ${INSTALLDIR}/usr/libilp32
get_sources
make_binutils
make_init_gcc
make_linux_headers
make_glibc64
if [ "$DO_MULTILIB" = "TRUE" ]; then
  make_glibc32
fi
make_gcc
make_tar
