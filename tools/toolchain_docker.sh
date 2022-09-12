set -x -e

PREFIX="/usr/local/foxos-x86_64_elf_gcc"
TARGET=x86_64-elf
PATH="$PREFIX/bin:$PATH"
PROG_PREFIX="foxos-"
BUILD_DIR="/.toolchain/tmp"
CORES=8

mkdir $BUILD_DIR -pv

(
	cd $BUILD_DIR

	curl -O http://ftp.gnu.org/gnu/binutils/binutils-2.35.1.tar.gz || exit 1
	curl -O https://ftp.gnu.org/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.gz || exit 1
	curl -O https://codeload.github.com/netwide-assembler/nasm/zip/refs/tags/nasm-2.15.05 || exit 1

	tar xf binutils-2.35.1.tar.gz || exit 1
	tar xf gcc-10.2.0.tar.gz || exit 1
	unzip nasm-2.15.05 || exit 1

	mkdir binutils-build

	(
		cd $BUILD_DIR/binutils-build

		../binutils-2.35.1/configure --target=$TARGET --program-prefix=$PROG_PREFIX --with-sysroot --disable-nls --disable-werror --prefix=$PREFIX || exit 1
		make -j $CORES || exit 1
		make install || exit 1
	) || exit 1

	(
		cd $BUILD_DIR/gcc-10.2.0

		./contrib/download_prerequisites || exit 1
		echo "MULTILIB_OPTIONS += mno-red-zone" > gcc/config/i386/t-x86_64-elf || exit 1
		echo "MULTILIB_DIRNAMES += no-red-zone" >> gcc/config/i386/t-x86_64-elf || exit 1

		sed -i 's/x86_64-\*-elf\*)/x86_64-\*-elf\*)\n	tmake_file="\${tmake_file} i386\/t-x86_64-elf" # include the new multilib configuration/' gcc/config.gcc || exit 1
	) || exit 1

	mkdir gcc-build

	(
		cd $BUILD_DIR/gcc-build

		../gcc-10.2.0/configure --target=$TARGET --program-prefix=$PROG_PREFIX --prefix="$PREFIX" --disable-nls --enable-languages=c++ --without-headers || exit 1
		make all-gcc -j $CORES || exit 1
		make all-target-libgcc -j $CORES || exit 1
		make install-gcc || exit 1
		make install-target-libgcc || exit 1
	) || exit 1

	(
		cd $BUILD_DIR/nasm-nasm-2.15.05

		sh autogen.sh || exit 1
		sh configure --prefix="$PREFIX" || exit 1

		make nasm -j $CORES || exit 1
		mv nasm $PREFIX/bin/$PROG_PREFIX"nasm" -v || exit 1

	) || exit 1
) || exit 1

rm -rf $BUILD_DIR 

# needed for mujs patching
git config --global user.email "you@example.com" || exit 1
git config --global user.name "Your Name" || exit 1