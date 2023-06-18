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
ENV LDFLAGS="-Wl,-Bstatic -static-libgcc"
ENV CXXFLAGS="-static --static -fPIC -mtune=generic"
ENV CFLAGS="-static --static -fPIC -mtune=generic"
ENV PATH=/usr/bin/x86_64-linux-musl/bin/:${PATH}
