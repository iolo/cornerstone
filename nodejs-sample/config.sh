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
JOB=scheduler-cornerstone-${ENV}-${SITE}-${NAME}
SCHEDULE="0/5 * * * *"
TIMEZONE="Asia/Seoul"

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

