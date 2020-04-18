Name:           toolchain-tot-ilp32
Version:        1.0
Release:        2%{?dist}
Summary:        ilp32 toolchain
License:        GPL
URL:            http://socrates/Server%20Toolchain/gcc
Source0:        http://socrates/Server%20Toolchain/gcc/%{name}.tar.bz2
BuildArch:      aarch64
BuildRequires:  libgcc, ncurses, python3, ncurses-libs
Requires:       libgcc, ncurses, python3, ncurses-libs
#AutoReq:	no

%description
A RPM that contains all the necessary ilp32 packages.

%prep
#%setup -q -c
#mkdir -p $RPM_SOURCE_DIR/%{name}
cd -
cp toolchain-tot-ilp32.tar.bz2 $RPM_SOURCE_DIR/
cd -
tar -xvf $RPM_SOURCE_DIR/%{name}.tar.bz2 -C $RPM_SOURCE_DIR/

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/
cp -a $RPM_SOURCE_DIR/opt $RPM_BUILD_ROOT/


%files
/opt

%changelog
* Sat Apr  19 2020 Naresh Bhat <nareshb@marvell.com> - 1.0-2
- Add toolchain rpmbuild support on txos-20.04
* Mon Apr  6 2020 Madhurika Joshi <mjoshi2@marvell.com> - 1.0-1
- Inital version of the package
