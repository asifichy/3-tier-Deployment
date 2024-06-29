FROM golang:1.19-buster as build

WORKDIR /app

# Add non root user
RUN useradd -u 1001 nonroot

# Copy only files required to install dependencies (better layer caching)
COPY go.mod go.sum ./

RUN --mount=type=cache,target=/go/pkg/mod \
  --mount=type=cache,target=/root/.cache/go-build \
  go mod download

COPY . .

RUN go build \
    -ldflags="-linkmode external -extldflags -static" \
    -tags netgo \
    -o api-golang

###multi-stage build
FROM scratch

# Set gin mode
ENV GIN_MODE release

COPY --from=build /etc/passwd /etc/passwd

COPY --from=build /app/api-golang api-golang

USER nonroot

EXPOSE 8080

CMD ["/api-golang"] 
#with this the change is, we don't need to build the app cause it is already build

