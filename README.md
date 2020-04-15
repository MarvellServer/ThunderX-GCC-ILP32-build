# ThunderX-GCC-ILP32-build

The script will build the toolchain with ILP32 support. You need to install all the toolchain build essential tools for your OS distribution.

e.g: The following is an example distribution version.

# Debian/Ubuntu:

sudo apt-get install libc6 gnat g++ gawk binutils gzip bzip2 make tar perl zip unzip autoconf automake gettext gperf dejagnu tcl tk autogen guile-2.0 flex texinfo subversion ssh diffutils patch build-essential libncurses5-dev bison byacc flex 

# CentOS/TXOS:

sudo yum groupinstall "Development Tools"

sudo yum install autoconf automake binutils bison flex gcc gcc-c++ gettext libtool make patch pkgconfig redhat-rpm-config rpm-build rpm-sign ctags elfutils indent patchutils kernel-devel make

sudo yum install gawk binutils gzip bzip2 make tar perl zip unzip autoconf automake gettext tcl tk flex subversion diffutils patch bison byacc flex

dnf config-manager --enable PowerTools

dnf install texinfo

or

You can also download, compile and install texinfo - http://ftp.gnu.org/gnu/texinfo/ 

./configure --prefix=/usr/local

make -j224

make install

# How to run the script

# Create a toolchain directory

mkdir toolchain

# Execute the build script

./build_github_gcc_toolchain.sh ~/toolchain TRUE TRUE

toolchain - INSTALLDIR

TRUE - Does the MULTILIB installation

TRUE - Does the LIBMVEC installation

# Reference:

https://gcc.gnu.org/install/prerequisites.html
