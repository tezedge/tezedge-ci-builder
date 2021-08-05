FROM tezedge/tezos-opam-builder:debian10

ARG tezos_branch="v9.5"
ARG python_version="3.8.5"
ARG rust_version="nightly-2020-12-31"
ARG ocaml_rust_version="1.44.0"

USER root
RUN apt-get update && \
    apt-get install -y make zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev  \
    wget curl llvm libncurses5-dev libssl-dev \
    libncursesw5-dev xz-utils tk-dev \
    libffi-dev liblzma-dev python-openssl libnuma-dev valgrind time

USER appuser
ENV RUSTUP_HOME=/home/appuser/.rustup \
    CARGO_HOME=/home/appuser/.cargo \
    PATH=/home/appuser/.cargo/bin:$PATH 

# install rust
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
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -
ENV PATH="/home/appuser/.poetry/bin:/home/appuser/.pyenv/shims:$PATH"

# poetry configuration
RUN poetry config virtualenvs.in-project true

# setup tezos repo
RUN git clone https://gitlab.com/tezos/tezos.git --branch ${tezos_branch} /home/appuser/tezos-src/tezos && \
    cd /home/appuser/tezos-src/tezos && \
    rustup toolchain install ${ocaml_rust_version} && \
    rustup override set ${ocaml_rust_version} && \
    make build-deps && opam config exec -- make && \
    cd /home/appuser/tezos-src/tezos/tests_python && \
    poetry install

# check default rust should be ${rust_version}
RUN rustc --version && \
    cargo --version && \
    poetry --version

USER root
# get the rt-test repo and compile the tests
RUN git clone git://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git --branch stable/v1.0
RUN cd rt-tests && make all && make install
USER appuser
