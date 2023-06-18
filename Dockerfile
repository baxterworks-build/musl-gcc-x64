FROM alpine:latest as base
RUN --mount=type=cache,target=/var/cache apk add xz wget make gcc g++ git ca-certificates flex bison file patch linux-headers musl-libintl
RUN git clone https://github.com/baxterworks-build/musl-cross-make /usr/src/musl-cross-make
WORKDIR /usr/src/musl-cross-make
COPY config.mak .


RUN make TARGET=x86_64-linux-musl OUTPUT=$PWD/out/ &> make.log || true 
RUN make install

FROM alpine:latest as stage2
COPY --from=base /usr/src/musl-cross-make/output/ /usr/
COPY --from=base /usr/src/musl-cross-make/make.log /usr/make.log
ENV LDFLAGS="-Wl,-Bstatic -static-libgcc"
ENV CXXFLAGS="-static --static -fPIC -mtune=generic"
ENV CFLAGS="-static --static -fPIC -mtune=generic"
ENV PATH=/usr/bin/x86_64-linux-musl/bin/:${PATH}
