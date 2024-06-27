FROM golang:1.19-alpine-buster as build

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN go build \
    -ldflags="-linkmode external -extldflags -static" \
    -tags netgo \
    -o api-golang

###multi-stage build
FROM scratch

ENV GIN_MODE release

COPY --from=build /app/api-golang api-golang

EXPOSE 8080

CMD ["/api-golang"] 
#with this the change is, we don't need to build the app cause it is already build

