# Multi-stage build for ultra-lightweight and reproducible deployment
FROM ubuntu:22.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    cmake \
    g++ \
    make \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY CMakeLists.txt ./
COPY src/ ./src/
COPY include/ ./include/
COPY third_party/ ./third_party/

RUN mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)

# Final runtime image
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libssl3 \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /build/build/tempmail-server /app/app
COPY dist/ /app/dist/
COPY data/ /app/data/

ENV PORT=8080
ENV TEMPMAIL_PORT=8080
ENV TEMPMAIL_DOMAIN=routerssh.web.id
ENV TEMPMAIL_DB=/app/data/tempmail.db
ENV TEMPMAIL_KEY_DIR=/app/data/keys
ENV TEMPMAIL_STATIC_DIR=/app/dist

EXPOSE 8080

CMD ["/app/app"]
