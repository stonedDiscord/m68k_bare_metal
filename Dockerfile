# To create the image:
#   $ docker build -t m68kbm -f Dockerfile .
# To run the container:
#   $ docker run -v ${PWD}:/src/ -it m68kbm <command>

FROM alpine:latest

ENV m68kbm_PATH="/opt/m68kbm"

RUN apk add --no-cache build-base m4 gmp mpfr4 mpc \
    && apk add --no-cache -t .build_deps git wget gmp-dev mpfr-dev mpc1-dev

RUN git clone --depth 1 --recursive https://github.com/stonedDiscord/m68k_bare_metal.git ${m68kbm_PATH} \
    && cd ${m68kbm_PATH} \
    && chmod +x *.sh

RUN cd ${m68kbm_PATH} \
    && ./linux-build-toolchain.sh

ENV PATH="${m68kbm_PATH}/toolchain/m68k-eabi-elf-14.3.0/bin:${PATH}"

RUN cd ${m68kbm_PATH}/libmetal \
    && make

RUN apk del .build_deps

WORKDIR /src/
