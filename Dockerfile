# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.23 AS builder

# Set the current working directory inside the container.
WORKDIR /go/src/github.com/score-spec/score-k8s

# Copy just the module bits
COPY go.mod go.sum ./
RUN go mod download

# Copy the entire project and build it.
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /usr/local/bin/score-k8s ./cmd/score-k8s

# We can use scratch since we don't rely on any linux libs or state.
FROM scratch

# Set the current working directory inside the container.
WORKDIR /score-k8s

# Copy the binary from the builder image.
COPY --from=builder /usr/local/bin/score-k8s /usr/local/bin/score-k8s

# Run the binary.
ENTRYPOINT ["/usr/local/bin/score-k8s"]
