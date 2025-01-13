FROM golang:1.23.4-alpine AS builder

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o server .

FROM alpine:3.21.2 AS runner

ARG UID=1000
ARG GID=1000

RUN addgroup -g ${GID} autoconf \
    && adduser -D -H -u ${UID} -G autoconf -h /server -s /sbin/nologin autoconf

USER autoconf
WORKDIR /server

COPY --chown=autoconf:autoconf --from=builder /build/server .

EXPOSE 8080

CMD ["./server", "-config", "config.yml"]