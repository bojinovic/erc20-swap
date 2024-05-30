NODE_VERSION=20

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash \
    && . ~/.nvm/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && npm i -g yarn

export NODE_PATH=~/.nvm/$NODE_VERSION/lib/node_modules
export PATH=~/.nvm/$NODE_VERSION/bin:$PATH

# Install rust
curl https://sh.rustup.rs -sSf | bash -s -- -y
echo 'source $HOME/.cargo/env' >> $HOME/.bashrc

# Install foundry
curl -L https://foundry.paradigm.xyz | bash && \
    . /root/.bashrc && \
    foundryup
