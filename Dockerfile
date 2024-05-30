FROM --platform=linux/amd64 golang:1.21.7-bullseye

# Replace shell with bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install dependencies
RUN apt-get update && apt-get -y install hwloc jq pkg-config bzr ocl-icd-opencl-dev

ENV NODE_VERSION 20

# Install nvm with node, npm and yarn
RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash \
    && . ~/.nvm/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && npm i -g yarn

ENV NODE_PATH ~/.nvm/$NODE_VERSION/lib/node_modules
ENV PATH      ~/.nvm/$NODE_VERSION/bin:$PATH

# Install rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc

# Install foundry
RUN curl -L https://foundry.paradigm.xyz | bash && \
    . /root/.bashrc && \curl -L https://foundry.paradigm.xyz | bash && \
    . /root/.bashrc && \
    foundryup
    foundryup

RUN mkdir -p /go/app
WORKDIR /go/app

RUN chmod +x /go/_scripts/*.sh