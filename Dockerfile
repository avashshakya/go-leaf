FROM golang:1.23-alpine AS builder

WORKDIR /app

COPY go.* .

RUN go mod tidy

COPY . .

RUN go build main.go

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/main .

EXPOSE 8080

CMD [ "/app/main" ]
