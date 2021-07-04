export PREFIX="/usr/local/foxos-x86_64_elf_gcc"
export TARGET=x86_64-elf
export PATH="$PREFIX/bin:$PATH"
export PROG_PREFIX="foxos-"
export BUILD_DIR=$PWD"/.toolchain/tmp"
export CORES=8

mkdir $BUILD_DIR -pv
cd $BUILD_DIR

echo "Downloading..."

curl -O http://ftp.gnu.org/gnu/binutils/binutils-2.35.1.tar.gz
curl -O https://ftp.gnu.org/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.gz
curl -O https://codeload.github.com/netwide-assembler/nasm/zip/refs/tags/nasm-2.15.05

echo "Extracting..."

tar xf binutils-2.35.1.tar.gz
tar xf gcc-10.2.0.tar.gz
unzip nasm-2.15.05

echo "Compiling..."
mkdir binutils-build
cd binutils-build
../binutils-2.35.1/configure --target=$TARGET --program-prefix=$PROG_PREFIX --with-sysroot --disable-nls --disable-werror --prefix=$PREFIX
make -j $CORES
sudo make install

cd $BUILD_DIR

cd gcc-10.2.0
./contrib/download_prerequisites
echo "MULTILIB_OPTIONS += mno-red-zone" > gcc/config/i386/t-x86_64-elf
echo "MULTILIB_DIRNAMES += no-red-zone" >> gcc/config/i386/t-x86_64-elf

sed -i 's/x86_64-\*-elf\*)/x86_64-\*-elf\*)\n	tmake_file="\${tmake_file} i386\/t-x86_64-elf" # include the new multilib configuration/' gcc/config.gcc

cd ..
mkdir gcc-build
cd gcc-build
../gcc-10.2.0/configure --target=$TARGET --program-prefix=$PROG_PREFIX --prefix="$PREFIX" --disable-nls --enable-languages=c++ --without-headers
make all-gcc -j $CORES
make all-target-libgcc -j $CORES
sudo make install-gcc
sudo make install-target-libgcc

cd $BUILD_DIR

cd nasm-nasm-2.15.05

sh autogen.sh
sh configure --prefix="$PREFIX" 

make nasm -j $CORES
sudo mv nasm $PREFIX/bin/$PROG_PREFIX"nasm" -v
