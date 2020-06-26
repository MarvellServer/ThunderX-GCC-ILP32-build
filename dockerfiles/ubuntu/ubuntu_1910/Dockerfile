###############################################################################
# DEVEL_GCC_ILP32                                                             #
###############################################################################
FROM ubuntu:19.10 as devel_gcc_ilp32
RUN apt-get update -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	wget \
  git \
  automake \
  autoconf \
  libtool \
	m4 \
	pkg-config \
  ca-certificates \
  python \
	python-dev \
	flex \
	texinfo \
  help2man \
 	unzip \
	xz-utils \
	make \
	gawk \
	libtool-bin \
	libncurses5-dev \
	bison \
	rsync \
	libssl-dev \
  libxml2-dev \
  libedit-dev \
  swig \
  libffi-dev \
  cmake \
  binutils-dev \
	python3-pip \
	python3-dev && \
	rm -rf /var/lib/apt/lists/*
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        g++ \
        gcc \
	      sudo \
        libnuma-dev \
        openssh-client \
        gfortran && \
    rm -rf /var/lib/apt/lists/*

# define local vars
ENV GCC_VERSION=ilp32
ENV TARGET=aarch64-linux-gnu
ENV INSTALL_ROOT=/opt
ENV GCC_INSTALL_PREFIX=/usr
ENV BUILD_ROOT=/tmp/build_gcc_ilp32
ENV INSTALLDIR=${INSTALL_ROOT}/${GCC_VERSION}

ENV MULTILIB_CONF=--with-multilib-list=lp64,ilp32
ENV LIBMVEC_CONF=--enable-mathvec
ENV CONF --prefix=${INSTALLDIR} --with-sysroot=${INSTALLDIR} \
         --target=${TARGET} --host=${TARGET} --build=${TARGET}
ENV BINUTILS_CONF=${CONF}
ENV INIT_GCC_CONF="--with-newlib --without-headers \
               --enable-languages=c --enable-threads=no \
               --disable-shared --disable-decimal-float \
               --disable-libsanitizer --disable-bootstrap"
ENV FINAL_GCC_CONF="--enable-languages=c,c++,fortran \
                --disable-libsanitizer --enable-bootstrap \
                --enable-threads --enable-shared"
ENV GCC_CONF ${CONF} --enable-gnu-indirect-function \
	  --with-advance-toolchain=${INSTALLDIR} ${MULTILIB_CONF}
ENV GLIBC_CONF --with-headers=${INSTALLDIR}/usr/include \
            ${LIBMVEC_CONF} --enable-obsolete-rpc \
	    --prefix=/usr --host=${TARGET}
ENV PATH ${INSTALLDIR}/bin:${INSTALLDIR}/usr/bin:${PATH}

#setup SSH agent access
RUN cd /root &&\
    mkdir -p .ssh
COPY data/id_rsa /root/.ssh
COPY data/config /root/.ssh
RUN eval `ssh-agent -s` && \
    ssh-add /root/.ssh/id_rsa && \
    ssh-add -l

RUN mkdir -p ${INSTALLDIR} && \
    mkdir -p ${INSTALLDIR}/lib && \
    mkdir -p ${INSTALLDIR}/lib64 && \
    mkdir -p ${INSTALLDIR}/libilp32 && \
    mkdir -p ${INSTALLDIR}/include && \
    mkdir -p ${INSTALLDIR}/usr && \
    mkdir -p ${INSTALLDIR}/usr/lib && \
    mkdir -p ${INSTALLDIR}/usr/lib64 && \
    mkdir -p ${INSTALLDIR}/usr/libilp32

# GCC: fetch source
RUN mkdir -p ${BUILD_ROOT} && \
  cd ${BUILD_ROOT} && \
  git clone git@github.com:MarvellServer/ThunderX-Toolchain-gcc-ilp32.git -b master gcc &&\
  cd gcc && \
  contrib/download_prerequisites && \
  cd .. && \
  git clone git@github.com:MarvellServer/ThunderX-Toolchain-glibc-ilp32.git -b v-0.2 glibc && \
  git clone git@github.com:MarvellServer/ThunderX-ilp32-linux.git -b ilp32-5.4.y linux && \
  git clone http://sourceware.org/git/binutils-gdb.git -b master binutils-gdb

# make binutils
RUN cd ${BUILD_ROOT} && \
    mkdir obj-binutils && \
    cd obj-binutils && \
    ../binutils-gdb/configure ${BINUTILS_CONF} && \
    make -j64 all && \
    make install

ENV PARALLEL_BUILD=-j64
# make init gcc
RUN cd ${BUILD_ROOT} && \
	mkdir -p obj-gcc-init && \
	cd obj-gcc-init && \
        ../gcc/configure ${GCC_CONF} ${INIT_GCC_CONF}  && \
        make ${PARALLEL_BUILD} all-gcc all-target-libgcc && make install-gcc install-target-libgcc

#make_linux_headers
RUN cd ${BUILD_ROOT} && \
    cd linux && \
    export CC=/usr/bin/gcc && \
    make headers_install ARCH=arm64 INSTALL_HDR_PATH=${INSTALLDIR}/usr HOSTCC=/usr/bin/gcc && \
    unset CC

#make_glibc64
RUN cd ${BUILD_ROOT} && \
    mkdir obj-glibc64 && \
    cd obj-glibc64 && \
    export BUILD_CC=/usr/bin/gcc && \
    export CC="$INSTALLDIR/bin/$TARGET-gcc -mabi=lp64" && \
    export CXX="$INSTALLDIR/bin/$TARGET-g++ -mabi=lp64" && \
    export AR="$TARGET-ar" && \
    export RANLIB="$TARGET-ranlib" && \
    export AS="$TARGET-as" && \
    export LD="$TARGET-ld" && \
    ../glibc/configure ${GLIBC_CONF} && \
    make ${PARALLEL_BUILD} all && make DESTDIR=$INSTALLDIR install && \
    unset BUILD_CC CC CXX AR RANLIB AS LD

#make_glibc32
RUN cd ${BUILD_ROOT} && \
    mkdir obj-glibc32 && \
    cd obj-glibc32 && \
    export BUILD_CC=/usr/bin/gcc && \
    export CC="$INSTALLDIR/bin/$TARGET-gcc -mabi=ilp32" && \
    export CXX="$INSTALLDIR/bin/$TARGET-g++ -mabi=ilp32" && \
    export AR="$TARGET-ar" && \
    export RANLIB="$TARGET-ranlib" && \
    export AS="$TARGET-as" && \
    export LD="$TARGET-ld" && \
    ../glibc/configure ${GLIBC_CONF} && \
    make ${PARALLEL_BUILD} all && make DESTDIR=$INSTALLDIR install && \
    unset BUILD_CC CC CXX AR RANLIB AS LD

#make_gcc
RUN cd ${BUILD_ROOT} && \
    mkdir obj-gcc && \
    cd obj-gcc && \
    ../gcc/configure ${GCC_CONF} ${FINAL_GCC_CONF} && \
    make ${PARALLEL_BUILD} all && make install

#package ilp32 gcc
ENV PKG_ROOT=gcc-tot-ilp32-ubuntu-19.10
ENV PKG_SUFFIX=1_arm64
COPY data/control /tmp
RUN export TODAY=`date "+%Y%m%d"` && \
    export PKG_NAME=${PKG_ROOT}-${TODAY}-${PKG_SUFFIX} && \
    mkdir /tmp/${PKG_NAME} && \
    mkdir /tmp/${PKG_NAME}/opt && \
    mkdir /tmp/${PKG_NAME}/DEBIAN && \
    mv /tmp/control /tmp/${PKG_NAME}/DEBIAN

RUN export TODAY=`date "+%Y%m%d"` && \
    export PKG_NAME=${PKG_ROOT}-${TODAY}-${PKG_SUFFIX} && \
    cp -r ${INSTALLDIR} /tmp/${PKG_NAME}/opt && \
    cd /tmp && \
    dpkg-deb --build ${PKG_NAME}

#Start of run the test
RUN mv /opt/ilp32 /opt/ilp32_build && \
    cd /tmp && \
    export TODAY=`date "+%Y%m%d"` && \
    export PKG_NAME=${PKG_ROOT}-${TODAY}-${PKG_SUFFIX} && \
    dpkg -i ${PKG_NAME}.deb

#a quick simple test after installation
RUN cd /tmp && \
    echo "#include <stdio.h>  \n int main() { printf(\"hello world\\n\"); return 0;} " > hello.c

RUN cd /tmp && \
    gcc hello.c -o hello.out && \
    ./hello.out

#get the package file
RUN echo "We stop here so that you can copy the package out of the docker container" && \
    echo "You can find the package in /tmp" && \
    gcc

FROM devel_gcc_ilp32 AS devel
