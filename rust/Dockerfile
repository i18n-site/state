FROM ubuntu AS build

WORKDIR /app

ENV PIP_ROOT_USER_ACTION=ignore

# RUN apt-get update &&\
#   apt-get install -y python3-pip &&\
#   pip install apt-smart &&\
#   apt-smart -a 

RUN \
apt-get update &&\
apt-get install -y \
ca-certificates protobuf-compiler curl bash build-essential libssl-dev pkg-config mold clang &&\
update-ca-certificates

SHELL [ "/bin/bash", "-c" ]

ENV SHELL=/bin/bash

ENV CARGO_HOME=/opt/rust
ENV RUSTUP_HOME=/opt/rust

RUN curl https://sh.rustup.rs -sSf | \
sh -s -- -y --no-modify-path --default-toolchain none &&\
source $CARGO_HOME/env &&\
rustup toolchain install nightly --profile minimal


COPY sh/cpso.sh .
COPY srv/ srv/
COPY smtp/ smtp/
COPY ipv6_proxy/ ipv6_proxy/
COPY host_ip/ host_ip/
COPY pg_/ pg_/
COPY Cargo.toml .

RUN <<EOT bash
set -ex
. $CARGO_HOME/env 
export RUSTFLAGS="-Z linker-features=-lld --cfg reqwest_unstable -Ctarget-feature=+crt-static $RUSTFLAGS" 
cargo build \
  --release -p srv \
  --artifact-dir out \
  -Z unstable-options \
  --target=\$(rustc -vV | sed -n 's|host: ||p') 
mv out/* m 
./cpso.sh m
EOT


# FROM ubuntu
FROM scratch

ENV LD_LIBRARY_PATH=/lib
COPY --from=build /so/ lib/

WORKDIR /
COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /app/m .

ENTRYPOINT ["/m","--port","5123"]
