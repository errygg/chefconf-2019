GOOS?=$(shell go env GOOS)
GOARCH?=$(shell go env GOARCH)
GOPATH=$(shell go env GOPATH)

GOTOOLS = \
  github.com/GeertJohan/go.rice/rice

BINARY_NAME=counter
    
all: deps tools build
build: deps tools
	GOOS=$(GOOS) GOARCH=$(GOARCH) rice embed-go
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(BINARY_NAME) -v
clean: 
	go clean
	rm -f $(BINARY_NAME)
deps:
	go get -u -v github.com/gorilla/mux
run: build
	./$(BINARY_NAME)
tools:
	go get -u -v $(GOTOOLS)
