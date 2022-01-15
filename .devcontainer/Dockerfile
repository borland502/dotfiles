# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.209.6/containers/debian/.devcontainer/base.Dockerfile

# [Choice] Debian version (use bullseye or stretch on local arm64/Apple Silicon): bullseye, buster, stretch
ARG VARIANT="bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# ** [Optional] Uncomment this section to install additional packages. **
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --yes --no-install-recommends acl musl-tools \
    && rm -rf /var/lib/apt/lists/*

# [Optional] Uncomment the next line to use go get to install anything else you need
RUN go get -x mvdan.cc/gofumpt

RUN curl -fsLS https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$(go env GOPATH)/bin"

RUN curl -fsLS https://install.goreleaser.com/github.com/goreleaser/goreleaser.sh | sh -s -- -b "$(go env GOPATH)/bin"

RUN ./bootstrap.sh