# syntax=docker/dockerfile:1.4

FROM mcr.microsoft.com/vscode/devcontainers/base:bookworm
LABEL authors="Jeremy Hettenhouser"

ARG PYTHON_VER="3.12"

RUN \
  --mount=type=cache,target=/var/cache/apt \
  DEBIAN_FRONTEND=noninteractive \
  apt-get \
  -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
  dist-upgrade && apt-get -yqq install --no-install-recommends curl ca-certificates

# add repo for gum (https://github.com/audacioustux/devcontainers/blob/main/src/common-utils-extras/install.sh)
RUN \
  mkdir -p /etc/apt/keyrings &&
  curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg &&
  echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list

RUN \
  --mount=type=cache,target=/var/cache/apt \
  DEBIAN_FRONTEND=noninteractive \
  apt-get update && apt-get -yqq install --no-install-recommends \
  socat \
  parallel \
  gum \
  cloc \
  moreutils \
  pkg-config \
  inotify-tools \
  apt-utils \
  bash-completion \
  openssh-client \
  gnupg2 \
  dirmngr \
  iproute2 \
  procps \
  lsof \
  htop \
  net-tools \
  psmisc \
  tree \
  rsync \
  unzip \
  bzip2 \
  xz-utils \
  zip \
  vim-tiny \
  less \
  jq \
  lsb-release \
  apt-transport-https \
  dialog \
  libc6 \
  libgcc1 \
  libkrb5-3 \
  libgssapi-krb5-2 \
  libicu[0-9][0-9] \
  liblttng-ust[0-9] \
  libstdc++6 \
  zlib1g \
  locales \
  sudo \
  ncdu \
  man-db \
  strace \
  manpages \
  manpages-dev \
  init-system-helpers \
  git

# cleanup
RUN apt-get clean &&
  rm -rf /var/lib/apt/lists/*

WORKDIR /home/vscode
USER vscode

ENV HOME /home/vscode
ENV TZ="America/New_York"
ENV USER_ID=1000

ENV XDG_BIN_HOME=${HOME}/.local/bin
ENV XDG_LIB_HOME=${HOME}/.local/lib
ENV XDG_CONFIG_HOME=${HOME}/.config
ENV XDG_CACHE_HOME=${HOME}/.cache
ENV XDG_DATA_HOME=${HOME}/.local/share

ENV PYENV_ROOT=${XDG_DATA_HOME}/pyenv
ENV NVM_DIR=${XDG_DATA_HOME}/nvm
ENV NONINTERACTIVE=1
ENV PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH

WORKDIR ${XDG_DATA_HOME}
# Pyenv - Python install
RUN \
  --mount=type=cache,target=/${XDG_DATA_HOME}/pyenv,uid="${USER_ID}" \
  git clone https://github.com/pyenv/pyenv ${XDG_DATA_HOME}/pyenv && pyenv install "3.12" && pyenv global "3.12"
# NVM - Node install
RUN mkdir -p ${NVM_DIR} &&
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash &&
  \. ${NVM_DIR}/nvm.sh && nvm install --lts && nvm use --lts
WORKDIR ${HOME}

# Brew early, brew often -- this is much faster than the feature install which still uses a full clone
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Run this as a distinct step so that brew populates autocomplete and other shell addons to zsh rather than bash
RUN \
  --mount=type=cache,target=${XDG_CACHE_HOME}/Homebrew,uid="${USER_ID}" \
  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" &&
  brew install zsh &&
  sudo chsh --shell /home/linuxbrew/.linuxbrew/bin/zsh vscode && zsh

RUN \
  --mount=type=cache,target=${XDG_CACHE_HOME}/Homebrew,uid="${USER_ID}" \
  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" &&
  brew install eza btop curl wget bat fd rg sd gum wget fzf go-task git tldr gh vim jq yq \
    pygments starship z zinit pipx

RUN \. ${NVM_DIR}/nvm.sh && npm install -g typescript ts-node nodemon tsx nx zx playwright jest eslint tsc prettier-eslint

RUN pipx ensurepath && pipx install --include-deps ansible poetry &&
  pipx inject --include-apps ansible argcomplete

# COPY --chown=vscode:vscode "./.zshrc" "/home/vscode/.zshrc"

ENTRYPOINT ["sleep", "infinity"]
