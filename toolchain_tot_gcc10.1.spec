Name:           toolchain-tot-gcc10.1
Version:        1.0
Release:        1%{?dist}
Summary:        gcc10.1 toolchain
License:        GPL
URL:            http://socrates/Server%20Toolchain/gcc
Source0:        http://socrates/Server%20Toolchain/gcc/%{name}.tar.bz2
BuildArch:      aarch64
BuildRequires:  libgcc, ncurses, python3, ncurses-libs
Requires:       libgcc, ncurses, python3, ncurses-libs
AutoReq:	no

%description
A RPM for gcc10.1.

%prep
#%setup -q -c
#mkdir -p $RPM_SOURCE_DIR/%{name}
cd -
cp toolchain-tot-gcc10.1.tar.bz2 $RPM_SOURCE_DIR/
cd -
tar -xvf $RPM_SOURCE_DIR/%{name}.tar.bz2 -C $RPM_SOURCE_DIR/

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/
cp -a $RPM_SOURCE_DIR/opt $RPM_BUILD_ROOT/


%files
/opt

%changelog
* Thu Apr  28 2020 Madhurika Joshi <mjoshi2@marvell.com> - 1.0-1
- Initial version of the package
