# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.194.0/containers/ruby/.devcontainer/base.Dockerfile

# [Choice] Ruby version: 3, 3.0, 2, 2.7, 2.6
ARG VARIANT="2.7"
FROM mcr.microsoft.com/vscode/devcontainers/ruby:0-${VARIANT}

# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="10"
RUN if [ "${NODE_VERSION}" != "none" ]; then \
  su vscode -c "umask 0002 \
    && . /usr/local/share/nvm/nvm.sh \
    && nvm install ${NODE_VERSION} 2>&1"; \
fi

# Install PhantomJS dependencies
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get -y install --no-install-recommends \
  libfontconfig

# Fix for Phantomjs OpenSSL issue
# https://github.com/ariya/phantomjs/issues/15449
RUN echo 'export OPENSSL_CONF=/etc/ssl' >> /etc/bash.bashrc

# Install teh right version of bundler
RUN gem install bundler:2.2.22

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g [...]" 2>&1