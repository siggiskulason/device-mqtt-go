.PHONY: build test clean prepare update docker

GO=CGO_ENABLED=0 GO111MODULE=on go
GOCGO=GCO_ENABLED=1 GO111MODULE=on go

MICROSERVICES=cmd/device-mqtt

.PHONY: $(MICROSERVICES)

DOCKERS=docker_device_mqtt_go

.PHONY: $(DOCKERS)

VERSION=$(shell cat ./VERSION 2>/dev/null || echo 0.0.0)
GIT_SHA=$(shell git rev-parse HEAD)

GOFLAGS=-ldflags "-X github.com/edgexfoundry/device-mqtt-go.Version=$(VERSION)"

build: $(MICROSERVICES)

cmd/device-mqtt:
	go mod tidy
	$(GOCGO) build $(GOFLAGS) -o $@ ./cmd

test:
	go mod tidy
	$(GOCGO) test ./... -coverprofile=coverage.out
	$(GOCGO) vet ./...
	gofmt -l .
	["`gofmt -l .`" = ""]
	./bin/test-attribution-txt.sh

clean:
	rm -f $(MICROSERVICES)

run:
	cd bin && ./edgex-launch.sh

docker: $(DOCKERS)

docker_device_mqtt_go:
	docker build \
		--label "git_sha=$(GIT_SHA)" \
		-t edgexfoundry/device-mqtt:$(GIT_SHA) \
		-t edgexfoundry/device-mqtt:$(VERSION)-dev \
		.
