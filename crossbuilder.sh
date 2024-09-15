#!/bin/bash

DEFAULT="\e[0;0m"
GREEN="\e[1;32m"
RED="\e[1;31m"

build_binutils() {
        mkdir -p build-binutils
        cd build-binutils || exit
        ../binutils-$1/configure --target="$TARGET" --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
        make
        make install
        cd ..
}

build_gcc() {
        mkdir -p build-gcc
        cd build-gcc || exit
        ../gcc-$1/configure --target="$TARGET" --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
        make all-gcc
        make all-target-libgcc
        make install-gcc
        make install-target-libgcc
        cd ..
}

decompress_tar() {
        tar -xf "$1".tar.gz
        rm -rf "$1".tar.gz
}

install_binutils() {
        if [ -d binutils-$1 ]; then 
                echo "Already installed and decompressed" 
        elif [ -f binutils-$1.tar.gz ]; then
                echo "Already downloaded, decompressing..."
                decompress_tar "binutils-$1"
        else 
                wget https://ftp.gnu.org/gnu/binutils/binutils-$1.tar.gz
                decompress_tar "binutils-$1"
        fi
}

install_gcc() {
        if [ -d gcc-$1 ]; then
                echo "Already installed and decompressed"
        elif [ -f gcc-$1.tar.gz ]; then
                echo "Already downloaded, decompressing... "
                decompress_tar "gcc-$1"
        else 
                wget https://ftp.gnu.org/gnu/gcc/gcc-$1/gcc-$1.tar.gz
                decompress_tar "gcc-$1"
        fi
}

install_packages() {
        case "$1" in
            arch) pacman -Syu base-devel gmp libmpc mpfr ;;
            debian) sudo apt-get install build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo libisl-dev ;;
            gentoo) sudo emerge --ask sys-devel/gcc dev-build/make sys-devel/bison sys-devel/flex dev-libs/gmp dev-libs/mpc dev-libs/mpfr sys-apps/texinfo dev-libs/isl ;;
            rhel) sudo dnf install gcc gcc-c++ bison flex gmp-devel mpfr-devel libmpc-devel texinfo ;;
            *) 
                echo -e "$RED[-] Unable to determine the OS. Please input the base OS type (arch, debian, gentoo):$DEFAULT"
                read -r os_base
                install_packages "$os_base"
            ;;
        esac
}

print_usage() {
        echo "$0 -b <BINUTILS VERSION> -g <GCC VERSION> -t <TARGET SYSTEM>"
        echo
        echo " -b | --binutils      Binutils version to install"
        echo " -g | --gcc           GCC version to install"
        echo " -t | --target        Target system for the cross compiler"
        echo " -h | --help          Show this help message"
}

set -a
. /etc/os-release
set +a

binutils_version=""
gcc_version=""
target=""

OPTIONS=$(getopt -o b:g:t:h --long binutils:,gcc:,target:,help -- "$@")
if [ $? -ne 0 ]; then
    print_usage
    exit 1
fi

eval set -- "$OPTIONS"

while true; do
    case "$1" in
        -b | --binutils)
            binutils_version="$2"
            shift 2
            ;;
        -g | --gcc)
            gcc_version="$2"
            shift 2
            ;;
        -t | --target)
            target="$2"
            shift 2
            ;;
        -h | --help)
            print_usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Invalid option"
            print_usage
            exit 1
            ;;
    esac
done

if [ -z "$binutils_version" ] || [ -z "$gcc_version" ] || [ -z "$target" ]; then
    echo -e "$RED[-] Missing required options!$DEFAULT"
    print_usage
    exit 1
fi

echo -e "$GREEN\n\n [+] Installing requirements for $ID_LIKE OS...$DEFAULT"
install_packages "$ID_LIKE" 

echo -e "$GREEN\n\n [+] Installing binutils-$binutils_version...$DEFAULT"
install_binutils "$binutils_version"

echo -e "$GREEN\n\n [+] Installing gcc-$gcc_version...$DEFAULT"
install_gcc "$gcc_version"

export PREFIX="$HOME/opt/cross"
export TARGET="$target"
export PATH="$PREFIX/bin:$PATH"

echo -e "$GREEN\n\n [+] Building binutils-$binutils_version...$DEFAULT"
build_binutils "$binutils_version"

echo -e "$GREEN\n\n [+] Building gcc-$gcc_version...$DEFAULT"
build_gcc "$gcc_version"

echo -e "$GREEN\n\n New compiler built! Run $HOME/opt/cross/bin/$TARGET-gcc --version to check if everything worked.$DEFAULT"
