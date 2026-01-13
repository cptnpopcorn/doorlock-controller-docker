FROM golang:1.25.5-alpine3.23 AS compiled

ARG APP_REPO=https://github.com/cptnpopcorn/doorlock-controller.git
ARG APP_REF=v1.0.0

RUN apk add --no-cache git

WORKDIR /checkout

RUN git clone ${APP_REPO} app \
  && cd app \
  && git checkout ${APP_REF}

WORKDIR /checkout/app

RUN go mod download
RUN CGO_ENABLED=0 go build -o /out/doorlock-controller ./cmd/doorlock-controller

FROM alpine:3.23 AS working

RUN apk add --no-cache ca-certificates

COPY --from=compiled /out/doorlock-controller /usr/local/bin/doorlock-controller

ENTRYPOINT ["/usr/local/bin/doorlock-controller"]