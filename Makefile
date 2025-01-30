RELEASE = 2.0.1

.PHONY: usage build podman-build remove podman-remove run podman-run copy podman-copy all podman-all default

usage:
	@echo "Please execute with one of the following options:"
	@echo " make build			: Build a Docker container image using the Dockerfile"
	@echo " make podman-build		: Build a Podman container image using the Dockerfile"
	@echo " make run			: Run a Docker container to build the COEN ISO image"
	@echo " make podman-run		: Run a Podman container to build the COEN ISO image"
	@echo " make remove			: Remove the Docker container"
	@echo " make podman-remove		: Remove the Podman container"
	@echo " make copy			: Copy the resultant COEN ISO image from the Docker container into the host directory"
	@echo " make podman-copy		: Copy the resultant COEN ISO image from the Podman container into the host directory"
	@echo " make all			: Execute build, remove, run, and copy with Docker"
	@echo " make podman-all		: Execute build, remove, run, and copy with Podman"

build:
	docker build -t coen:$(RELEASE) .

podman-build:
	podman build -t coen:$(RELEASE) .

remove:
	-docker rm coen

podman-remove:
	-podman rm coen

run:
	docker run --init --interactive --tty \
	--privileged \
	--userns=host --ipc=host --network=host --pid=host --uts=host \
	--name=coen \
	coen:$(RELEASE)

podman-run:
	podman run --interactive --tty \
	--privileged \
	--userns=host --ipc=host --network=host --pid=host --uts=host \
	--name=coen \
	coen:$(RELEASE)

copy:
	-docker cp coen:/opt/coen-${RELEASE}-amd64.iso .

podman-copy:
	-podman cp coen:/opt/coen-${RELEASE}-amd64.iso .

all: build remove run copy

podman-all: podman-build podman-remove podman-run podman-copy

default: usage
