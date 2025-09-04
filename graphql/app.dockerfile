# --- Build stage ---
FROM golang:1.23-alpine AS builder
WORKDIR /app

RUN apk --no-cache add build-base ca-certificates git

COPY go.mod go.sum ./
RUN go mod download

# Copy entire repository to preserve module paths
COPY . .

ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN mkdir -p /out \
 && go build -trimpath -ldflags "-s -w" -o /out/graphql ./graphql

# --- Runtime stage ---
FROM alpine:3.18
WORKDIR /usr/bin

RUN apk --no-cache add ca-certificates

COPY --from=builder /out/graphql /usr/local/bin/graphql

EXPOSE 8080

RUN adduser -D appuser
USER appuser

ENTRYPOINT ["/usr/local/bin/graphql"]