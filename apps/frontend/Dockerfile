FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY main.go .
RUN go mod init frontend && CGO_ENABLED=0 GOOS=linux go build -o frontend .

FROM gcr.io/distroless/static-debian12
WORKDIR /app
COPY --from=builder /app/frontend .
EXPOSE 8080
CMD ["./frontend"]
