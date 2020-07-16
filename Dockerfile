FROM simplestakingcom/tezos-opam-builder:debian10

USER root
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH 
RUN apt-get update && apt-get install -y libssl-dev
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly-2020-05-15 -y

