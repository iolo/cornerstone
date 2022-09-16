FROM --platform=linux/amd64 golang:alpine as builder

WORKDIR /src
COPY emulator-helper /src
RUN go build

FROM --platform=linux/amd64 google/cloud-sdk:alpine

ARG PORT=8085
ENV PORT=$PORT

RUN apk add --no-cache --update \
        netcat-openbsd \
        openjdk8-jre && \
    gcloud components install beta pubsub-emulator

EXPOSE $PORT

ENTRYPOINT ["gcloud", "beta", "emulators", "pubsub", "start"]

COPY --from=builder /src/pubsub-emulator-helper /usr/local/bin/

HEALTHCHECK --interval=5s --timeout=3s --start-period=10s --retries=3 CMD nc -z localhost $PORT || exit 1
