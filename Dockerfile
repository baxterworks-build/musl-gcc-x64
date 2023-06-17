FROM debian:sid as base
RUN --mount=type=cache,target=/var/cache apt update && apt --no-install-recommends -y install xz-utils wget make gcc g++ git ca-certificates libc6-dev flex bison file patch
RUN git clone https://github.com/baxterworks-build/musl-cross-make /usr/src/musl-cross-make
WORKDIR /usr/src/musl-cross-make
COPY config.mak .
RUN --mount=type=cache,target=/usr/src/ make TARGET=x86_64-linux-musl OUTPUT=$PWD/out/ extract_all || true
RUN make TARGET=x86_64-linux-musl OUTPUT=$PWD/out/ 
RUN make install

FROM alpine:latest as stage2
COPY --from=base /usr/src/musl-cross-make/output/ /usr/
RUN --mount=type=cache,target=/var/cache apk update && apk add make curl nasm libffi-dev patch openssl-libs-static openssl-dev

WORKDIR /src
RUN curl https://git.ffmpeg.org/gitweb/ffmpeg.git/snapshot/HEAD.tar.gz | tar -zxf - && mv ffmpeg-HEAD* ffmpeg-HEAD
#RUN curl https://ffmpeg.org/releases/ffmpeg-6.0.tar.xz | tar -Jxf -
ENV LDFLAGS="-Wl,-Bstatic -static-libgcc"
ENV CXXFLAGS="-static --static -fPIC -mtune=generic"
ENV CFLAGS="-static --static -fPIC -mtune=generic"
ENV PATH=/usr/bin/x86_64-linux-musl/bin/:${PATH}
#WORKDIR /src/ffmpeg-6.0
WORKDIR /src/ffmpeg-HEAD
RUN ln -s /usr/lib/libcrypto.a /usr/x86_64-linux-musl/lib/
RUN ln -s /usr/lib/libssl.a /usr/x86_64-linux-musl/lib/
RUN ln -s /usr/include/openssl /usr/x86_64-linux-musl/include/

RUN ./configure --disable-everything \ 
	--enable-ffmpeg --enable-ffprobe --disable-stripping --enable-static --disable-shared --enable-pic --extra-ldexeflags="-static" --prefix=/output/ \
	--enable-cross-compile --cross-prefix=x86_64-linux-musl- \
	--arch=x86_64 --prefix=/output --target-os=linux \ 
        --enable-openssl \
	--enable-protocols --enable-demuxer=mpegts --enable-decoder=aac --enable-parser=aac --enable-demuxer=aac || true
RUN mkdir -p /output && cp -Rv ffbuild/*.log /output || true
RUN make -j16 || true

FROM scratch
COPY --from=stage2 /output /output
