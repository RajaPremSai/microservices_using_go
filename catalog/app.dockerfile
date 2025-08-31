# Stage 1: Build
FROM golang:1.21-alpine AS builder
WORKDIR /app

RUN apk --no-cache add build-base ca-certificates

COPY go.mod go.sum ./
COPY vendor ./vendor
COPY pkg ./pkg
COPY internal ./internal
COPY cmd ./cmd

RUN go build -mod=vendor -o app ./cmd/catalog/main.go

# Stage 2: Runtime
FROM alpine:3.18
WORKDIR /usr/bin

COPY --from=builder /app/app .

EXPOSE 8080

# Optional: Use a non-root user for security
RUN adduser -D appuser
USER appuser

ENTRYPOINT ["./app"]