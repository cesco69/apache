-include env_make

HTTPD_VER ?= 2.4.29
HTTPD_MINOR_VER ?= $(shell echo "${HTTPD_VER}" | grep -oE '^[0-9]+\.[0-9]+')

TAG ?= $(HTTPD_MINOR_VER)

REPO = wodby/apache
NAME = apache-$(HTTPD_MINOR_VER)

ifneq ($(STABILITY_TAG),)
    ifneq ($(TAG),latest)
         override TAG := $(TAG)-$(STABILITY_TAG)
    endif
endif

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) --build-arg HTTPD_VER=$(HTTPD_VER) ./

test:
	cd ./test && IMAGE=$(REPO):$(TAG) ./run

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push
