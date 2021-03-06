###############################################################################
# DEVEL_GCC_ILP32                                                             #
###############################################################################
FROM centos:8.1.1911 as devel_gcc_ilp32

# install dnf plugins and enable epel repo
RUN dnf -y install dnf-plugins-core epel-release

# enable additional repos
RUN dnf config-manager --set-enabled PowerTools
RUN dnf config-manager --set-enabled extras

# install development packages
RUN dnf -y makecache
RUN dnf -y install \
      automake \
      autoconf \
      libtool \
      m4 \
      gcc \
      gcc-c++ \
      gcc-gfortran \
      patch \
      patchutils \
      diffutils \
      python2-devel \
      python3-devel \
      hwloc \
      openssl-devel \
      numactl \
      numactl-devel \
      openssh-clients \
      git \
      subversion \
      wget \
      lbzip2 \
      pkg-config \
      ca-certificates \
      flex \
      texinfo \
      help2man \
      unzip \
      make \
      cmake \
      libxml2-devel \
      libedit-devel \
      swig \
      libffi-devel \
      ncurses-devel \
      rsync \
      bison \
      openssl-devel \
      rpm-build \
      rpmdevtools \
      binutils-devel

# update alternatives
RUN alternatives --set python /usr/bin/python3
RUN update-alternatives --install /usr/bin/pydoc          pydoc         /usr/bin/pydoc3         10
RUN update-alternatives --install /usr/bin/python-config  python-config /usr/bin/python3-config 10
RUN update-alternatives --install /usr/bin/pip            pip           /usr/bin/pip3           10

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
RUN chmod 600 /root/.ssh/config
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
# update path
ENV PKG_NAME=gcc-tot-ilp32
RUN cd /opt && \
    tar -czvf ${PKG_NAME}.tar.gz ilp32/

RUN cd /root && \
    rpmdev-setuptree

COPY /data/gcc_ilp32.spec /root/rpmbuild/SPECS
RUN export TODAY=`date "+%Y%m%d"` && \
    sed -i "s#REPLACE_TODAY#${TODAY}#" /root/rpmbuild/SPECS/gcc_ilp32.spec

RUN cd /root/rpmbuild/SOURCES && \
    cp /opt/${PKG_NAME}.tar.gz ./ && \
    cd ../SPECS && \
    QA_RPATHS=$[ 0x0002 ] rpmbuild -bb gcc_ilp32.spec

#Start of run the test
RUN mv /opt/ilp32 /opt/ilp32_build && \
    cd /root/rpmbuild/RPMS/aarch64 && \
    export TODAY=`date "+%Y%m%d"` && \
    rpm -ivh ${PKG_NAME}-${TODAY}-0.el8.aarch64.rpm


#a quick simple test of gcc after installation
RUN cd /tmp && \
    echo -e "#include <stdio.h>  \\n int main() { printf(\"hello world\"); return 0;} " > hello.c

RUN cd /tmp && \
    gcc hello.c -o hello.out && \
    ./hello.out

RUN cd /tmp && \
    gcc hello.c -o hello.out && \
    ./hello.out && \
    gcc --version

RUN echo "We stop here so that you can copy the rpm file out of docker container" && \
    echo "You can find the package at /root/rpmbuild/RPMS/aarch64" && \
    gcc

FROM devel_gcc_ilp32 AS devel
