#!/usr/bin/env sh

echo Building GCC m68k toolchain...

mkdir -p toolchain
mkdir -p toolchain/sources
mkdir -p toolchain/build

CORES=1
TARGET=m68k-eabi-elf
PREFIX=$PWD/toolchain/$TARGET

MIRROR=http://ftpmirror.gnu.org
# MIRROR=https://mirror.team-cymru.com/gnu

BINUTILS=binutils-2.46.0
BINUTILS_URL=$MIRROR/binutils/$BINUTILS.tar.xz

GCCVER=15.2.0
GCC=gcc-$GCCVER
GCC_URL=$MIRROR/gcc/$GCC/$GCC.tar.xz

if [ ! -f toolchain/sources/$BINUTILS.tar.xz ]; then
  echo Fetching $BINUTILS_URL ...
  (cd toolchain/sources && wget -q --show-progress $BINUTILS_URL) || exit 1
fi

if [ ! -f toolchain/sources/$GCC.tar.xz ]; then
  echo Fetching $GCC_URL ...
  (cd toolchain/sources && wget -q --show-progress $GCC_URL) || exit 1
fi

echo Extracting $BINUTILS ...
test -d toolchain/sources/$BINUTILS || (cd toolchain/sources && tar xJf $BINUTILS.tar.xz) || exit 1
echo Extracting $GCC ...
test -d toolchain/sources/$GCC || (cd toolchain/sources && tar xJf $GCC.tar.xz) || exit 1
mkdir -p toolchain/build

if [ ! -f $PREFIX-$GCCVER/bin/$TARGET-nm ]; then
  echo Building binutils
  mkdir -p toolchain/build/binutils
  (cd toolchain/build/binutils && ../../sources/$BINUTILS/configure --target=$TARGET --disable-werror --prefix=$PREFIX-$GCCVER && make -j $CORES && make install) || exit 1
fi
echo Done with binutils
if [ ! -f $PREFIX-$GCCVER/bin/$TARGET-gcc ]; then
  echo GCC setup
  mkdir -p toolchain/build/gcc

  if [ -e /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    echo "Windows Subsystem for Linux (WSL)"
    (cd toolchain/sources/$GCC && contrib/download_prerequisites) || exit 1
  fi
  cd toolchain/build/gcc
  echo Configuring GCC
  ../../sources/$GCC/configure --target=$TARGET --disable-werror --prefix=$PREFIX-$GCCVER --enable-languages=c
  echo Building GCC
  make -j $CORES all-gcc
  echo Installing GCC
  make install-gcc

fi

echo All done!

exit 0
