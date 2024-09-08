# Gcc cross compiler builder 🔧
A script to easly build a gcc cross compiler

## Installation 📂
first clone the github repo:
```
git clone https://github.com/giovanni-iannaccone/gcc-cross-compiler-builder
```
then add execution permission to the script
```
cd gcc-cross-compiler-builder
chmod +x crossbuilder.sh
```

## Usage 🕹
```
./crossbuilder.sh -b [BINUTILS VERSION] -g [GCC VERSION] -t [TARGET SYSTEM]

-b | --binutils           is the binutils version the script is going to install in your system
-g | --gcc                is the gcc version the script the script is going to install in your system
-t | --target             the target system
```

> [!IMPORTANT]
> Binutils and GCC must be compatible versions, check <a href="https://wiki.osdev.org/Cross-Compiler_Successful_Builds">here</a> for successful builds. <br/>
> Versions that were released around the same time should be compatible.

For more informations about cross compilers and their importance in os development check <a href="https://wiki.osdev.org/GCC_Cross-Compiler">osdev wiki</a>
