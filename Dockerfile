FROM ubuntu:latest as builder

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update
RUN apt-get install -y curl git vim zip unzip jq build-essential cmake clang llvm libgmp-dev secure-delete pkg-config libssl-dev lld

RUN curl -sL https://raw.githubusercontent.com/OLSF/libra/main/ol/util/setup.sh | bash
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y
RUN . ~/.bashrc
RUN . $HOME/.cargo/env
ENV PATH "$PATH:/root/.cargo/bin"
RUN cargo install toml-cli

WORKDIR /libra
COPY . .

RUN make bins install
RUN make web-files

FROM ubuntu:latest

COPY --from=builder /root/bin /bin

RUN ulimit -n 20000

RUN apt-get update
RUN apt-get install -y libssl-dev ca-certificates
RUN apt-get clean

ENV RUST_BACKTRACE 1
ENV RUST_LOG error

RUN ol serve --update
