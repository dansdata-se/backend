FROM mcr.microsoft.com/devcontainers/base:bookworm

ARG JUST_VERSION="1.30.1"
ARG USQL_VERSION="0.19.3"
ARG BUN_VERSION="1.1.19"
# bun appends "/bin" by itself
ARG BUN_INSTALL="/usr/local"

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends build-essential curl

# Install [just](https://github.com/casey/just)
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --tag "${JUST_VERSION}" --to /usr/local/bin/

# Install [usql](https://github.com/xo/usql)
RUN curl -Lo /tmp/usql.tar.bz2 https://github.com/xo/usql/releases/download/v${USQL_VERSION}/usql_static-${USQL_VERSION}-linux-amd64.tar.bz2 \
  && tar -xjf /tmp/usql.tar.bz2 -C /usr/local/bin/ usql_static \
  && rm -f /tmp/usql.tar.bz2 \
  && mv /usr/local/bin/usql_static /usr/local/bin/usql \
  && chmod 555 /usr/local/bin/usql

# Install [bun](https://bun.sh/)
RUN curl -fsSL https://bun.sh/install | bash -s "bun-v${BUN_VERSION}"
