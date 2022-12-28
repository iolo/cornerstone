#!/bin/bash
PROJECT=fastcampus-web-services
REGION=asia-northeast3
SITE=day1
ENV=dev
NAME=sample
VERSION=latest
IMAGE=gcr.io/${PROJECT}/gcr-cornerstone-${SITE}-${NAME}:${VERSION}
SERVICE=run-cornerstone-${ENV}-${SITE}-${NAME}
TOPIC=topic-cornerstone-${ENV}-${SITE}-${NAME}
SUBSCRIPTION=sub-cornerstone-${ENV}-${SITE}-${NAME}
JOB=
SCHEDULER=
TIMEZONE=
SKIP_BUILD=
SKIP_PUSH=
SKIP_DEPLOY=

echo --------------------------------------------------
echo project=${PROJECT}
echo region=${REGION}
echo site=${SITE}
echo env=${ENV}
echo name=${NAME}
echo version=${VERSION}
echo image=${IMAGE}
echo service=${SERVICE}
echo topic=${TOPIC}
echo subscription=${SUBSCRIPTION}
echo --------------------------------------------------

set -e

gcloud auth configure-docker
if [ -z ${SKIP_BUILD} ]; then
  docker build . --tag ${IMAGE}
fi
if [ -z ${SKIP_PUSH} ]; then
  docker push ${IMAGE}
fi

if [ -z ${SKIP_DEPLOY} ]; then
  gcloud run deploy ${SERVICE} --image=${IMAGE} --region=${REGION} --project=${PROJECT} --allow-unauthenticated
fi

gcloud run services describe ${SERVICE} --region=${REGION} --project=${PROJECT}
ENTRYPOINT=$(gcloud run services describe ${SERVICE} --region=${REGION} --project=${PROJECT} --format 'value(status.url)')
[ -z "${ENTRYPOINT}" ] && exit 1;

# echo curl ${ENTRYPOINT}/.ping
PONG=$(curl -s ${ENTRYPOINT}/.ping)
[ "${PONG}" != "pong!" ] && exit 1; 

# pubsub -> run
if [ -n "${TOPIC}" -a -n "${SUBSCRIPTION}" ]; then
  set +e
  gcloud pubsub topics create ${TOPIC}
  set -e
  gcloud pubsub topics describe ${TOPIC}
  set +e
  gcloud pubsub subscriptions create ${SUBSCRIPTION} --topic=${TOPIC} --push-endpoint=${ENTRYPOINT}
  set -e
  gcloud pubsub subscriptions describe $SUBSCRIPTION
  # echo gcloud pubsub topics publish $TOPIC --message "hello"
fi

# scheduler -> run
if [ -n "${JOB}" -a -n "${SCHEDULE}" -a -n "${TIMEZONE}" ]; then
  set +e
  gcloud scheduler jobs create http ${JOB} --schedule "${SCHEDULE}" --time-zone=${TIMEZONE} --http-method=POST --uri=$ENTRYPOINT --message-body='{"message":{"data":""}}'
  # scheduler -> pubsub -> run
  #set +e
  #gcloud scheduler jobs create pubsub ${JOB} --schedule ${SCHEDULE} --time-zone=${TIMEZONE} --topic=${TOPIC} --message-body=""
  set -e
  gcloud scheduler jobs describe ${JOB}
fi
