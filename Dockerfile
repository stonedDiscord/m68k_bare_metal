# To create the image:
#   $ docker build -t m68kbm -f Dockerfile .
# To run the container:
#   $ docker run -v ${PWD}:/src/ -it m68kbm <command>

FROM debian:bookworm-slim

ENV m68kbm_PATH="/opt/m68k_bare_metal"

RUN apt update && apt -y install binutils build-essential m4 make libmpc3 libmpc-dev libmpfr6 libmpfr-dev git wget libgmp10 libgmp-dev srecord xxd zip

RUN git clone --depth 1 --recursive https://github.com/stonedDiscord/m68k_bare_metal.git ${m68kbm_PATH} \
    && cd ${m68kbm_PATH} \
    && chmod +x *.sh

RUN cd ${m68kbm_PATH} \
    && ./linux-build-toolchain.sh

ENV PATH="${m68kbm_PATH}/toolchain/m68k-eabi-elf-13.4.0/bin:${PATH}"

RUN cd ${m68kbm_PATH}/libmetal \
    && make \
    && sed -i -e 's/CPU=68000/CPU=68010/g' hello.txt \
    && make \
    && sed -i -e 's/CPU=68010/CPU=68020/g' hello.txt \
    && make \
    && sed -i -e 's/CPU=68020/CPU=68030/g' hello.txt \
    && make \
    && sed -i -e 's/CPU=68030/CPU=68040/g' hello.txt \
    && make \
    && sed -i -e 's/CPU=68040/CPU=68060/g' hello.txt \
    && make \
    && sed -i -e 's/CPU=68060/CPU=cpu32/g' hello.txt \
    && make

RUN apt -y autoremove && apt clean autoclean
RUN rm -rf ${m68kbm_PATH}/toolchain/build
RUN rm -rf ${m68kbm_PATH}/toolchain/sources

RUN mkdir ${m68kbm_PATH}/src

WORKDIR "/opt/m68k_bare_metal/src"
