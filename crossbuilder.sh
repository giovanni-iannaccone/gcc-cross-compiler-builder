#!/bin/bash

DEFAULT="\e[0;0m"
GREEN="\e[1;32m"
RED="\e[1;31m"

build_binutils() {
        mkdir build-binutils
        cd build-binutils
        ../binutils-$1/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
        make
        make install
        cd ..
}

build_gcc() {
        mkdir build-gcc
        cd build-gcc
        ../gcc-$1/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
        make all-gcc
        make all-target-libgcc
        make install-gcc
        make install-target-libgcc
        cd ..
}

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

print_usage() {
        echo "$0 -b <BINUTILS VERSION> -g <GCC VERSION> -t <TARGET SYSTEM> "
        echo
        echo " -b | --binutils                  binutils version you want to install"
        echo " -g | --gcc                       gcc version you want to install"
        echo " -t | --target                    the target system of the cross compiler"
}
 
set -a
. /etc/os-release
set +a

binutils_version=""
gcc_version=""
target=""

while getopts "b:g:t:" flag; do
        case "${flag}" in 
                b) binutils_version="${OPTARG}";;
                g) gcc_version="${OPTARG}";;
                t) target="${OPTARG}";;
                *) print_usage; exit 0;;
        esac
done

echo -e "$GREEN\n\n [+] Installing requirements for $ID_LIKE os...$DEFAULT"
install_packages "$ID_LIKE" 

echo -e "$GREEN\n\n [+] Installing gcc-$gcc_version...$DEFAULT"
install_gcc "$gcc_version"

echo -e "$GREEN\n\n [+] Installing binutils-$binutils_version...$DEFAULT"
install_binutils "$binutils_version"

export PREFIX="$HOME/opt/cross"
export TARGET="$target"
export PATH="$PREFIX/bin:$PATH"

build_binutils "$binutils_version"
build_gcc "$gcc_version"

echo -e "\n\n New compiler built, run $HOME/opt/cross/bin/$TARGET-gcc --version to check if everything worked"
