FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY main.go .
RUN go mod init backend && CGO_ENABLED=0 GOOS=linux go build -o backend .

FROM gcr.io/distroless/static-debian12
WORKDIR /app
COPY --from=builder /app/backend .
EXPOSE 8080
CMD ["./backend"]
