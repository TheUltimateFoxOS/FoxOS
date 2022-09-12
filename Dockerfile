FROM debian

RUN apt update && apt install kpartx graphicsmagick-imagemagick-compat lbzip2 mtools dosfstools git gcc make automake g++ flex bison unzip curl gdisk -y

COPY tools/toolchain_docker.sh /docker_build.sh
RUN bash /docker_build.sh

WORKDIR /root

ENTRYPOINT /bin/bash
