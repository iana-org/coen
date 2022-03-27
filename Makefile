RELEASE = 0.4.0

.PHONY: usage build remove run copy all default

usage:
	@echo "Please provide an option:"
	@echo " make build	--- Build the COEN ISO image"
	@echo " make run	--- Run a container to build the ISO image"
	@echo " make remove	--- Remove the container"
	@echo " make copy	--- Copy the ISO image into the host directory"
	@echo " make all	--- Execute build, remove, run and copy"

build:
	docker build -t coen:$(RELEASE) .

remove:
	-docker rm coen

run:
	docker run -i -t \
	--privileged \
	--name=coen \
	--hostname=coen-builder \
	coen:$(RELEASE)

copy:
	-docker cp coen:/opt/coen-${RELEASE}-amd64.iso .

all: build remove run copy

default: usage
