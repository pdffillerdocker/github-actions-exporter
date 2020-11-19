FROM golang:1.14-alpine as builder

ENV deps "git"

RUN apk update && apk upgrade

RUN apk add --no-cache $deps

ENV CGO_ENABLED 0

WORKDIR /build/

COPY go.mod go.sum /build/
RUN  go mod download

RUN apk del --purge $deps

COPY . .

RUN go build -trimpath -o /usr/local/bin/main -ldflags="-s -w" /build/main.go

FROM alpine

COPY --from=builder /usr/local/bin/main /usr/local/bin/main

ENTRYPOINT ["/usr/local/bin/main"]
CMD ["server"]
EXPOSE 9999