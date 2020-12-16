FROM simplestakingcom/tezos-opam-builder:debian10

ARG tezos_branch="v8.0-rc1"
ARG python_version="3.8.2"
ARG rust_version="nightly-2020-10-24"

USER root
RUN apt-get update && \
    apt-get install -y make zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev  \
    wget curl llvm libncurses5-dev libssl-dev \
    libncursesw5-dev xz-utils tk-dev \
    libffi-dev liblzma-dev python-openssl

USER appuser
ENV RUSTUP_HOME=/home/appuser/.rustup \
    CARGO_HOME=/home/appuser/.cargo \
    PATH=/home/appuser/.cargo/bin:$PATH 

RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain ${rust_version} -y

# cargo add-ons install
RUN cargo install critcmp

# install pyenv (python version manager)
RUN curl https://pyenv.run | bash
ENV PATH="/home/appuser/.pyenv/bin:$PATH"

# install python 
RUN pyenv install -v ${python_version} && \
    pyenv global ${python_version} && \
    pyenv rehash

# install poetrty (virtual environment manager)
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
ENV PATH="/home/appuser/.poetry/bin:/home/appuser/.pyenv/shims:$PATH"

# poetry configuration
RUN poetry config virtualenvs.in-project true

# setup tezos repo
RUN git clone https://gitlab.com/tezos/tezos.git --branch ${tezos_branch} /home/appuser/tezos-src/tezos && \
    cd /home/appuser/tezos-src/tezos && make build-deps && opam config exec -- make && \ 
    cd /home/appuser/tezos-src/tezos/tests_python && \
    poetry install