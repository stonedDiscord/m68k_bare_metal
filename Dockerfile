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
    && sed -i -e 's/68000/68010/g' Makefile \
    && make \
    && sed -i -e 's/68010/68020/g' Makefile \
    && make \
    && sed -i -e 's/68020/68030/g' Makefile \
    && make \
    && sed -i -e 's/68030/68040/g' Makefile \
    && make \
    && sed -i -e 's/68040/68060/g' Makefile \
    && make \
    && sed -i -e 's/68060/cpu32/g' Makefile \
    && make

RUN apt -y autoremove && apt clean autoclean
RUN rm -rf ${m68kbm_PATH}/toolchain/build
RUN rm -rf ${m68kbm_PATH}/toolchain/sources

RUN mkdir ${m68kbm_PATH}/src

WORKDIR "/opt/m68k_bare_metal/src"
