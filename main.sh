#!/bin/bash

DEFAULT="\e[0;0m"
GREEN="\e[1;32m"
RED="\e[1;31m"

decompress_tar() {
	tar -xf $1.tar.gz
	rm -rf $1.tar.gz
}

install_binutils() {
	if [ -d binutils-$1 ]; then 
		echo "Already installed and decompressed" 

	elif [ -d binutils-$1.tar.gz ]; then
		echo "Already installed, decompressing..."
		decompress_tar "binutils-$1"
	
	else 
		wget https://ftp.gnu.org/gnu/binutils/binutils-$1.tar.gz
		decompress_tar "binutils-$1"
	fi
}

install_gcc() {
	if [ -d gcc-$1 ]; then
		echo "Already installed and decompressed"

	elif [ -d gcc-$1.tar.gz ]; then
		echo "Already installed, decompressing... "
		decompress_tar "gcc-$1"
	
	else 
		wget https://ftp.gnu.org/gnu/gcc/gcc-$1/gcc-$1.tar.gz
		decompress_tar "gcc-$1"
	fi
}

install_packages() {
	if [ $1 = "arch" ]; then
		pacman -Syu base-devel gmp libmpc mpfr

	elif [ $1 = "debian" ]; then
		sudo apt-get install build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo libisl-dev
	
	elif [ $1 = "gentoo" ]; then
		sudo emerge --ask sys-devel/gcc dev-build/make sys-devel/bison sys-devel/flex dev-libs/gmp dev-libs/mpc dev-libs/mpfr sys-apps/texinfo dev-libs/isl

	else
		echo -e "$RED[-] Unable to determine the os this system is based on, type: $DEFAULT"
		read os_base
		install_packages os_base
	fi
}

set -a
. /etc/os-release
set +a

echo -e "$GREEN Using os: $ID_LIKE $DEFAULT"
install_packages "$ID_LIKE"

echo -e "$GREEN \n\n[+] Type the binutils version you want to install: $DEFAULT"
read binutils_version
install_binutils "$binutils_version"

echo -e  "$GREEN \n\n[+] Type the gcc version you want to install: $DEFAULT"
read gcc_version
install_gcc "$gcc_version"


