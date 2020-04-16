Name:           toolchain-tot-ilp32-B13
Version:        1.0
Release:        1%{?dist}
Summary:        ilp32 toolchain
License:        GPL
URL:            http://socrates/Server%20Toolchain/gcc
Source0:        http://socrates/Server%20Toolchain/gcc/%{name}.tar.bz2
BuildArch:      aarch64
BuildRequires:  libgcc, ncurses, python2-devel, ncurses-libs
Requires:       libgcc, ncurses, python2-devel, ncurses-libs
#AutoReq:	no

%description
A RPM that contains all the necessary ilp32 packages.

%prep
#%setup -q -c
mkdir -p $RPM_SOURCE_DIR/%{name}
tar -jxf $RPM_SOURCE_DIR/%{name}.tar.bz2 -C $RPM_SOURCE_DIR/%{name}

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/opt
cp -a $RPM_SOURCE_DIR/%{name} $RPM_BUILD_ROOT/opt

%files
/opt

%changelog
* Mon Apr  6 2020 Madhurika Joshi <mjoshi2@marvell.com> - 1.0-1
- Inital version of the package

