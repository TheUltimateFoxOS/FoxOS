FROM debian

RUN apt update
RUN apt install lbzip2 mtools dosfstools git gcc make automake g++ flex bison unzip curl gdisk -y

ENV PREFIX="/usr/local/foxos-x86_64_elf_gcc"
ENV TARGET=x86_64-elf
ENV PATH="$PREFIX/bin:$PATH"
ENV PROG_PREFIX="foxos-"
ENV BUILD_DIR="/.toolchain/tmp"
ENV CORES=8

RUN mkdir $BUILD_DIR -pv

WORKDIR /.toolchain/tmp

RUN curl -O http://ftp.gnu.org/gnu/binutils/binutils-2.35.1.tar.gz
RUN curl -O https://ftp.gnu.org/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.gz
RUN curl -O https://codeload.github.com/netwide-assembler/nasm/zip/refs/tags/nasm-2.15.05

RUN tar xf binutils-2.35.1.tar.gz
RUN tar xf gcc-10.2.0.tar.gz
RUN unzip nasm-2.15.05

RUN mkdir binutils-build

WORKDIR /.toolchain/tmp/binutils-build

RUN ../binutils-2.35.1/configure --target=$TARGET --program-prefix=$PROG_PREFIX --with-sysroot --disable-nls --disable-werror --prefix=$PREFIX
RUN make -j $CORES
RUN make install

WORKDIR /.toolchain/tmp/gcc-10.2.0

RUN ./contrib/download_prerequisites
RUN echo "MULTILIB_OPTIONS += mno-red-zone" > gcc/config/i386/t-x86_64-elf
RUN echo "MULTILIB_DIRNAMES += no-red-zone" >> gcc/config/i386/t-x86_64-elf

RUN sed -i 's/x86_64-\*-elf\*)/x86_64-\*-elf\*)\n	tmake_file="\${tmake_file} i386\/t-x86_64-elf" # include the new multilib configuration/' gcc/config.gcc

WORKDIR /.toolchain/tmp

RUN mkdir gcc-build

WORKDIR /.toolchain/tmp/gcc-build


RUN ../gcc-10.2.0/configure --target=$TARGET --program-prefix=$PROG_PREFIX --prefix="$PREFIX" --disable-nls --enable-languages=c++ --without-headers
RUN make all-gcc -j $CORES
RUN make all-target-libgcc -j $CORES
RUN make install-gcc
RUN make install-target-libgcc

WORKDIR /.toolchain/tmp/nasm-nasm-2.15.05

RUN sh autogen.sh
RUN sh configure --prefix="$PREFIX" 

RUN make nasm -j $CORES
RUN mv nasm $PREFIX/bin/$PROG_PREFIX"nasm" -v

RUN rm -rf /.toolchain
RUN apt install kpartx -y

# needed for mujs patching
RUN git config --global user.email "you@example.com"
RUN git config --global user.name "Your Name"

WORKDIR /root

ENTRYPOINT /bin/bash
