FROM golang:1.19-alpine

WORKDIR /app

COPY . .

RUN go mod download

RUN go build -o api-golang

CMD ["./api-golang"] 
#with this the change is, we don't need to build the app cause it is already build

