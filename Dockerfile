# Build the manager binary
FROM golang:1.10.3 as builder

# Copy in the go src
WORKDIR /go/src/github.com/kubernetes-sigs/application
COPY pkg/    pkg/
COPY cmd/    cmd/
COPY vendor/ vendor/

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o manager github.com/kubernetes-sigs/application/cmd/manager

# Copy the controller-manager into a thin image
FROM ubuntu:latest
WORKDIR /root/
COPY --from=builder /go/src/github.com/kubernetes-sigs/application/manager .

# What namespace the manager controller will scan. By default it will scan all namesapces.
# Specify a certain namespace if the controller run using a Role instead of a ClusterRole.
ENV NAMESPACE ""
ENTRYPOINT ["./manager", "--namespace=${NAMESPACE}"]
