SHELL=bash
TAG?=musl-gcc-x64
VERSION?=13.1.0

#https://stackoverflow.com/a/10858332
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
        $(error Undefined $1$(if $2, ($2))$(if $(value @), \
                required by target `$@')))


.PHONY: all build push login
build:
	BUILDKIT_PROGRESS=plain DOCKER_BUILDKIT=1 docker build -t ${USER}/${TAG}:${VERSION} .
	docker tag ${USER}/${TAG}:${VERSION} ${USER}/${TAG}:latest
login:
	@:$(call check_defined, DOCKER_ACCESS_TOKEN)
	@echo ${DOCKER_ACCESS_TOKEN} | docker login -u ${USER} --password-stdin

push: login build
	docker push ${USER}/${TAG}:${VERSION}
	docker push ${USER}/${TAG}:latest

