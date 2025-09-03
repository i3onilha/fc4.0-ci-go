FROM golang:latest AS development

LABEL maintainer="Jean Bonilha <jeanbonilha.webdev@gmail.com>"

ARG HOME_USER=/home/go

ENV DEBIAN_FRONTEND noninteractive
ENV GOENV="development"

ENV NODE_VERSION v22.12.0
ENV NVM_DIR ${HOME_USER}/.nvm
ENV NPM_FETCH_RETRIES 2
ENV NPM_FETCH_RETRY_FACTOR 10
ENV NPM_FETCH_RETRY_MINTIMEOUT 10000
ENV NPM_FETCH_RETRY_MAXTIMEOUT 60000

ENV SOURCE_CODE ${HOME_USER}/sourcecode

RUN go install golang.org/x/tools/cmd/godoc@latest
RUN go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
RUN go install github.com/air-verse/air@latest

RUN set -xe; \
    apt-get update && \
    apt-get upgrade -yqq && \
    apt-get install -yqq \
    apt-utils \
    gnupg2 \
    git \
    libzip-dev zip unzip \
    default-mysql-client \
    inetutils-ping \
    wget \
    libaio-dev \
    freetds-dev \
    sudo \
    bash-completion \
    curl \
    make \
    ncurses-dev \
    build-essential \
    tree \
    nano \
    tmux \
    tmuxinator \
    xclip \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    libssl-dev \
    libgtk-3-dev \
    nsis \
    ripgrep \
    fontconfig \
    gcc \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/share/fonts/truetype/nerd-fonts \
    && wget -O /tmp/nerd-fonts.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontPatcher.zip \
    && unzip /tmp/nerd-fonts.zip -d /usr/share/fonts/truetype/nerd-fonts \
    && rm /tmp/nerd-fonts.zip \
    && fc-cache -fv

RUN curl -LO https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.tar.gz && \
    tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
    rm nvim-linux-x86_64.tar.gz

RUN useradd -ms /bin/bash go && echo "go:secret" | chpasswd && adduser go sudo

RUN rm -rf /etc/localtime && \
    ln -s /usr/share/zoneinfo/America/Manaus /etc/localtime

USER go

RUN mkdir -p $NVM_DIR \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install ${NODE_VERSION} \
    && nvm use ${NODE_VERSION} \
    && nvm alias ${NODE_VERSION} \
    && npm config set fetch-retries ${NPM_FETCH_RETRIES} \
    && npm config set fetch-retry-factor ${NPM_FETCH_RETRY_FACTOR} \
    && npm config set fetch-retry-mintimeout ${NPM_FETCH_RETRY_MINTIMEOUT} \
    && npm config set fetch-retry-maxtimeout ${NPM_FETCH_RETRY_MAXTIMEOUT} \
    && npm install -g yarn \
    && npm install -g npm \
    && git clone --depth=1 https://github.com/i3onilha/nvim $HOME/.config/nvim

RUN git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf && $HOME/.fzf/install

RUN git clone --bare -b godevenv https://github.com/i3onilha/.dotfiles.git $HOME/.dotfiles && \
    git clone https://github.com/i3onilha/.tmux.git $HOME/.tmux && \
    ln -sf .tmux/.tmux.conf $HOME && \
    cp $HOME/.tmux/.tmux.conf.local $HOME && \
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no && \
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME reset HEAD . && \
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout -- .

RUN export PATH="$HOME/.nvm/versions/node/$NODE_VERSION/bin:$PATH"

WORKDIR $SOURCE_CODE

COPY . .
