#!/bin/bash

source "config.sh"

SKIP_BUILD=
SKIP_PUSH=
SKIP_DEPLOY=

set -e

gcloud auth configure-docker
if [ -z ${SKIP_BUILD} ]; then
  docker build . --tag ${IMAGE} --build-arg GITHUB_TOKEN=$GITHUB_TOKEN --build-arg NODE_ENV=$NODE_ENV --build-arg D1_ENV=$ENV --build-arg D1_SITE=$SITE
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
  gcloud pubsub subscriptions describe ${SUBSCRIPTION}
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
