FROM simplestakingcom/tezos-opam-builder:debian10

ARG tezos_branch="v8.0-rc1"
ARG python_version="3.8.2"
ARG rust_version="nightly-2020-10-24"

USER root
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH 
RUN apt-get update && apt-get install -y libssl-dev
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain ${rust_version} -y

# pyton stuff
RUN apt-get update && \
    apt-get install -y make zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev  \
    wget curl llvm libncurses5-dev \
    libncursesw5-dev xz-utils tk-dev \
    libffi-dev liblzma-dev python-openssl

# install pyenv (python version manager)
RUN curl https://pyenv.run | bash
ENV PATH="/root/.pyenv/bin:$PATH"

# install python 
RUN pyenv install -v ${python_version} && \
    pyenv global ${python_version} && \
    pyenv rehash

# install poetrty (virtual environment manager)
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
ENV PATH="/root/.poetry/bin:/root/.pyenv/shims:$PATH"

# poetry configuration
RUN poetry config virtualenvs.in-project true

# setup tezos repo
RUN git clone https://gitlab.com/tezos/tezos.git --branch ${tezos_branch} /tezos-src/tezos && \
    cd /tezos-src/tezos/tests_python && \
    poetry install