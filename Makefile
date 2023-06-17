SHELL=bash
OUTPUT=0

ifeq ($(OUTPUT),1)
	DOCKER_OUTPUT=--output=built/
else
	DOCKER_OUTPUT=
endif

.PHONY: all build clean

build:
	BUILDKIT_PROGRESS=plain DOCKER_BUILDKIT=1 docker build -t voltagex/ffmpeg . $(DOCKER_OUTPUT) #

compiler:
	BUILDKIT_PROGRESS=plain DOCKER_BUILDKIT=1 docker build . --target=base


