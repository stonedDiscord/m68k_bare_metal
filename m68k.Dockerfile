# To create the image:
#   $ docker build -t m68k -f m68k.Dockerfile .
# To run the container:
#   $ docker run -v ${PWD}:/src/ -it m68k <command>

FROM alpine:latest

ENV m68k_PATH="/opt/m68k"

RUN apk add --no-cache build-base libxml2 m4 gmp \
    && apk add --no-cache -t .build_deps bison flex libxml2-dev git subversion boost-dev texinfo \
		perl-template-toolkit perl-app-cpanminus curl gmp-dev \
    && cpanm -l $HOME/perl5 --no-wget local::lib Template::Plugin::YAML \
    && git clone --depth 1 --recursive https://github.com/stonedDiscord/m68k_bare_metal.git ${m68k_PATH} \
    && cd ${m68k_PATH} \ 
    && eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)" \
    && chmod +x *.sh \
    && ./linux-build-toolchain.sh \
    && cd libmetal
    && make \
    && apk del .build_deps

ENV PATH="${m68k_PATH}/bin:${PATH}"

WORKDIR /src/
