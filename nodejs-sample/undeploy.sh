#!/bin/bash

source "config.sh"

if [ -n "${JOB}" -a -n "${SCHEDULE}" -a -n "${TIMEZONE}" ]; then
  gcloud scheduler jobs delete ${JOB}
fi
if [ -n "${TOPIC}" -a -n "${SUBSCRIPTION}" ]; then
  gcloud pubsub subscriptions delete ${SUBSCRIPTION}
  gcloud pubsub topics delete ${TOPIC}
fi
gcloud run services delete ${SERVICE} --region=${REGION} --project=${PROJECT}
