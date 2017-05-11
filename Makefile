# CONTAINER_SOURCE: container-relative mount for the source directory
CONTAINER_SOURCE := /src
# CONTAINER_BUILD_DEST: container-relative mount for LOCAL_BUILD_DEST
CONTAINER_BUILD_DEST := /dest
# LOCAL_BUILD_DEST: destination directory for website
LOCAL_BUILD_DEST := $(CURDIR)/rootfs/svc

SHORT_NAME ?= gutenberg
VERSION ?= 0.6.0
IMAGE_PREFIX ?= jhansen
DEV_REGISTRY ?= quay.io
DEIS_REGISTRY ?= ${DEV_REGISTRY}/
IMAGE := ${DEIS_REGISTRY}${IMAGE_PREFIX}/${SHORT_NAME}:${VERSION}

DOCKER_RUN_CMD := docker run -p 4000:4000 -v $(CURDIR):$(CONTAINER_SOURCE) -v $(LOCAL_BUILD_DEST):$(CONTAINER_BUILD_DEST) --rm $(IMAGE)
DOCKER_SHELL_CMD := docker run -p 4000:4000 -v $(CURDIR):$(CONTAINER_SOURCE) -v $(LOCAL_BUILD_DEST):$(CONTAINER_BUILD_DEST) --rm -it $(IMAGE)

HELMSH_SHORT_NAME ?= helmsh
HELMSH_VERSION ?= latest
HELMSH_IMAGE_PREFIX ?= deis
HELMSH_IMAGE := ${DEIS_REGISTRY}${HELMSH_IMAGE_PREFIX}/${HELMSH_SHORT_NAME}:${HELMSH_VERSION}

prep:
	$(CURDIR)/script/prep $(LOCAL_BUILD_DEST)

build: prep
	$(DOCKER_RUN_CMD) /src/script/build $(CONTAINER_BUILD_DEST)

build-image:
	docker build \
	  --pull \
	  --build-arg BUILD_DATE=`date -u +'%Y-%m-%dT%H:%M:%SZ'` \
	  -t ${HELMSH_IMAGE} rootfs

push:
	docker push ${HELMSH_IMAGE}

deploy:
	deis login ${DEIS_URL} --username="${DEIS_USERNAME}" --password="${DEIS_PASSWORD}"
	deis pull ${HELMSH_IMAGE} -a helm-sh

serve:
	$(DOCKER_SHELL_CMD) /src/script/serve

shell:
	$(DOCKER_SHELL_CMD) /bin/bash
