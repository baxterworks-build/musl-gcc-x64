TARGET = x86_64-linux-musl
MAKEFLAGS := --jobs=$(shell nproc)
COMMON_CONFIG += CC="gcc -static --static -fPIC" CXX="g++ -static --static -fPIC" LDFLAGS="-Wl,-Bstatic"
#https://github.com/richfelker/musl-cross-make/issues/47
GCC_CONFIG += --enable-default-pie
GNU_SITE = http://mirror.aarnet.edu.au/pub/gnu/
