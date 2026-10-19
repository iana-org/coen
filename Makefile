RELEASE=3.0.0

.PHONY: usage podman-check build podman-build remove podman-remove run podman-run copy podman-copy all podman-all default

usage:
	@echo "Please execute with one of the following options:"
	@echo " make build			: Build a Docker container image using the Dockerfile"
	@echo " sudo make podman-build		: Build a Podman container image using the Dockerfile"
	@echo " make run			: Run a Docker container to build the COEN ISO image"
	@echo " sudo make podman-run		: Run a Podman container to build the COEN ISO image"
	@echo " make remove			: Remove the Docker container"
	@echo " sudo make podman-remove	: Remove the Podman container"
	@echo " make copy			: Copy the resultant COEN ISO image from the Docker container into the host directory"
	@echo " sudo make podman-copy		: Copy the resultant COEN ISO image from the Podman container into the host directory"
	@echo " make all			: Execute build, remove, run, and copy with Docker"
	@echo " sudo make podman-all		: Execute build, remove, run, and copy with Podman"

podman-check:
	@if [ "$$(podman info --format '{{.Host.Security.Rootless}}')" = "true" ]; then \
		echo "ERROR: COEN requires Podman to run in rootful mode."; \
		echo "Run: sudo make podman-all"; \
		exit 1; \
	fi

build: 
	docker build --platform=linux/amd64 -t localhost/coen:$(RELEASE) .

podman-build: podman-check
	podman build --platform=linux/amd64 -t localhost/coen:$(RELEASE) .

remove:
	-docker rm coen

podman-remove: podman-check
	-podman rm coen

run:
	docker run --init --platform=linux/amd64 --interactive --tty \
	--privileged \
	--userns=host --ipc=host --network=host --pid=host --uts=host \
	--name=coen \
	localhost/coen:$(RELEASE)

podman-run: podman-check
	podman run --platform=linux/amd64 --interactive --tty \
	--privileged \
	--userns=host --ipc=host --network=host --pid=host --uts=host \
	--name=coen \
	localhost/coen:$(RELEASE)

copy:
	-docker cp coen:/opt/coen-${RELEASE}-amd64.iso .

podman-copy: podman-check
	-podman cp coen:/opt/coen-${RELEASE}-amd64.iso .

all: build remove run copy

podman-all: podman-build podman-remove podman-run podman-copy

default: usage
