#!/bin/bash

validate_array_in() {
  NEEDLE=$1
  shift
  HAYSTACK=$@

  for item in $HAYSTACK; do
    if [ "$item" = "$NEEDLE" ]; then
      echo "true"
      return
    fi
  done
}

git_commit_id() {
  git rev-parse HEAD
}

# topic 유무에 따라 Exit Code 로 반환
# topic 이 있으면 0, 없으면 1 을 반환한다.
topic_exists() {
  local TOPIC=$1

  gcloud pubsub topics describe "$TOPIC" >/dev/null
  return $?
}

get_topic_name() {
  local TASK_NAME=$(get_task_name)
  echo "topic-cornerstone-${D1_ENV}-${D1_SITE}-${TASK_NAME}"
}

get_topic_url() {
  local TOPIC_NAME=$(get_topic_name)
  echo "https://console.cloud.google.com/cloudpubsub/topic/detail/${TOPIC_NAME}?project=${CLOUDSDK_CORE_PROJECT}"
}

# Public: 토픽이 없는 경우 생성한다
create_topic() {
  local TOPIC_NAME=$(get_topic_name)

  if topic_exists "$TOPIC_NAME"; then
    echo "Topic $TOPIC_NAME already exists. Skip creating topic."
  else
    echo "Topic $TOPIC_NAME does not exist. Creating..."
    gcloud pubsub topics create "$TOPIC_NAME" \
      --flags-file="$DEPLOY_DIR/.common.default.tmp.yml"
  fi

  return $?
}

# 구독 유무에 따라 Exit Code 로 반환
# 구독이 있으면 0, 없으면 1 을 반환한다.
subscription_exists() {
  local SUBSCRIPTION=$1

  gcloud pubsub subscriptions describe "$SUBSCRIPTION" >/dev/null
  return $?
}

get_subscription_name() {
  local TASK_NAME=$(get_task_name)

  echo "sub-cornerstone-${D1_ENV}-${D1_SITE}-${TASK_NAME}"
}

get_subscription_url() {
  local SUBSCRIPTION_NAME=$(get_subscription_name)
  echo "https://console.cloud.google.com/cloudpubsub/subscription/detail/${SUBSCRIPTION_NAME}?project=${CLOUDSDK_CORE_PROJECT}"
}

# Public: 구독이 없는 경우 생성한다
# 구독이 있다면 push-endpoint 를 업데이트 한다
#
# ARGS 로 전달되는 값은 생성시에만 동작한다.
# gcloud pubsub subscriptions create 문서를 참고한다.
#
# shellcheck disable=SC2120
create_subscription() {
  local ARGS="$@"
  local TASK_NAME="$(get_task_name)"
  local ENTRYPOINT="$(get_cloudrun_entrypoint)"
  local TOPIC_NAME="$(get_topic_name)"
  local SUBSCRIPTION="$(get_subscription_name)"
  local DEAD_LETTER_TOPIC_NAME="$(get_dead_letter_topic_name)"
  local ACK_DEADLINE=300
  local MAX_DELIVERY_ATTEMPTS=5

  if subscription_exists "$SUBSCRIPTION"; then
    echo "Subscription $SUBSCRIPTION already exists. Updating.."
    gcloud pubsub subscriptions update "$SUBSCRIPTION" \
      --push-endpoint="$ENTRYPOINT"
  else
    echo "Subscription $SUBSCRIPTION does not exist. Creating..."
    gcloud pubsub subscriptions create "$SUBSCRIPTION" \
      --flags-file="$DEPLOY_DIR/.common.default.tmp.yml" \
      --topic "$TOPIC_NAME" \
      --ack-deadline "$ACK_DEADLINE" \
      --push-endpoint="$ENTRYPOINT" \
      --push-auth-service-account "$OIDC_SERVICE_ACCOUNT_EMAIL" \
      --dead-letter-topic "$DEAD_LETTER_TOPIC_NAME" \
      --max-delivery-attempts "$MAX_DELIVERY_ATTEMPTS" \
      $ARGS
  fi

  return $?
}

# 스케줄러 유무에 따라 Exit Code 로 반환
# 스케줄러가 있으면 0, 없으면 1 을 반환한다.
scheduler_exists() {
  local JOB="$1"

  gcloud scheduler jobs describe "$JOB" --location $X_CLOUDSDK_SCHEDULER_LOCATION >/dev/null
  return $?
}

get_scheduler_name() {
  echo "scheduler-${D1_ENV}-${D1_SITE}-$(get_task_name)"
}

get_scheduler_url() {
  echo "https://console.cloud.google.com/logs/query;query=resource.type%3D%22cloud_scheduler_job%22%20AND%20resource.labels.job_id%3D%22$(get_scheduler_name)%22%20AND%20resource.labels.location%3D%22${X_CLOUDSDK_SCHEDULER_LOCATION}%22?project=${CLOUDSDK_CORE_PROJECT}"
}

# Public: 스케줄러가 없는 경우 생성한다
# 스케줄러는 일정시간마다 토픽에 메시지를 보낸다.
#
# ARGS 로 전달되는 값은 생성시에만 동작한다.
# gcloud scheduler create 문서를 참고한다.
#
create_scheduler() {
  local ARGS="$@"
  local JOB_NAME="$(get_scheduler_name)"
  local ENTRYPOINT="$(get_cloudrun_entrypoint)"
  local TOPIC_NAME="$(get_topic_name)"
  local TOPIC="projects/${CLOUDSDK_CORE_PROJECT}/topics/$TOPIC_NAME"

  if scheduler_exists "$JOB_NAME"; then
    echo "Scheduler $JOB_NAME already exists. Replacing..."
    gcloud scheduler jobs delete "$JOB_NAME" --location "$X_CLOUDSDK_SCHEDULER_LOCATION" -q
  else
    echo "Scheduler $JOB_NAME does not exist. Creating..."
  fi

  if [ -n "$SCHEDULER_MESSAGE_BODY" ]; then
    SCHEDULER_MESSAGE_BODY=$(base64 <<<"$SCHEDULER_MESSAGE_BODY")
    # JSON string 을 만들 때 공백이 없어야 한다
    MESSAGE_BODY=$(printf '{"message":{"data":"%s"}}' "$SCHEDULER_MESSAGE_BODY")
    MESSAGE_BODY_ARG="--message-body='$MESSAGE_BODY'"
  fi

  gcloud scheduler jobs create http "$JOB_NAME" \
    --location "$X_CLOUDSDK_SCHEDULER_LOCATION" \
    --attempt-deadline 300s \
    --http-method post \
    --uri "$ENTRYPOINT" \
    --oidc-service-account-email="$OIDC_SERVICE_ACCOUNT_EMAIL" \
    --oidc-token-audience="$ENTRYPOINT" \
    $MESSAGE_BODY_ARG \
    $ARGS

}

get_task_name() {
  _TASK_NAME="${TASK_NAME:-$(basename "$PWD")}"
  echo "$_TASK_NAME"
}

get_docker_image_tag() {
  local _HOST="$DOCKER_REGISTRY_HOST"
  local _PROJECT="$CLOUDSDK_CORE_PROJECT"
  local _REGISTRY="cornerstone-tasks"
  local _SERVICE="${SERVICE:-$(get_task_name)}"
  local _VERSION="$(git_commit_id)"
  echo "$_HOST/$_PROJECT/$_REGISTRY/$_SERVICE:$_VERSION"
}

docker_image_exists_local() {
  local IMAGE_WITH_TAG=$1
  RET=$(docker images -q "$IMAGE_WITH_TAG" 2>/dev/null)
  if [ -n "$RET" ]; then # 이미지가 존재하면 true
    echo "true"
  else # 이미지가 존재하지 않으면
    echo "false"
  fi
}

# Public: Docker 이미지를 생성한다.
#
# Examples
#
#  build_docker_image --build-arg BUILD_ARG=1 --build-arg BUILD_ARG2=2
#
build_docker_image() {
  local DOCKER_IMAGE_TAG="$(get_docker_image_tag)"
  local TASK_NAME="$(get_task_name)"

  # ARM 환경에서 빌드된 것이 배포되지 않도록 platform 은 linux/amd64 로 고정
  export DOCKER_DEFAULT_PLATFORM=linux/amd64
  export IMAGE_TAG="$DOCKER_IMAGE_TAG"

  docker-compose build "$TASK_NAME"
}

push_docker_image() {
  docker push "$(get_docker_image_tag)"
}

get_artifact_registry_url() {
  local DIGEST=$(docker inspect $(get_docker_image_tag) | jq -r '.[0].RepoDigests[0]' | sed -e "s|.*@||g")
  local TASK_NAME="$(get_task_name)"
  echo "https://console.cloud.google.com/artifacts/docker/${CLOUDSDK_CORE_PROJECT}/${CLOUDSDK_ARTIFACTS_LOCATION}/cornerstone-tasks/${TASK_NAME}/${DIGEST}?project=${CLOUDSDK_CORE_PROJECT}"
}

get_cloudrun_entrypoint() {
  gcloud run services describe "$(get_cloudrun_name)" --format 'value(status.url)'
}

get_cloudrun_name() {
  echo "run-cornerstone-${D1_ENV}-${D1_SITE}-$(get_task_name)"
}
cloudrun_exists() {
  gcloud run services describe "$(get_cloudrun_name)" 2>/dev/null
  return $?
}

get_cloudrun_url() {
  local CLOUD_RUN_NAME="$(get_cloudrun_name)"
  echo "https://console.cloud.google.com/run/detail/${CLOUDSDK_RUN_REGION}/${CLOUD_RUN_NAME}/metrics?project=${CLOUDSDK_CORE_PROJECT}"
}

get_cloudrun_log_url() {
  local CLOUD_RUN_NAME="$(get_cloudrun_name)"
  echo "https://console.cloud.google.com/logs/query;query=resource.type%3D"cloud_run_revision"%0Aresource.labels.service_name%3D"${CLOUD_RUN_NAME}"?project=${CLOUDSDK_CORE_PROJECT}"
}
# Public: Cloud Run 서비스를 생성하거나 업데이트한다.
#
# 다음 두 파일을 Merge 하고 export 된 변수를 바인딩한다.
# $DEPLOY_DIR/cloud-cloud-run-service.default.yml
# $TASK_DIR/deploy/cloud-run-service.override.yml
#
# 머지된 파일은 $TASK_DIR/deploy 에 cloud-run-service.$TIMESTAMP.yml 로 남는다.
# YAML 파일 Syntax 는 Knative의 Service Spec 을 참고한다.
#
# Examples
#
#   replace_cloudrun
#
replace_cloudrun() {
  local OVERRIDE_FILE_PATH="$1"
  local DEFAULT_FILE_PATH="$DEPLOY_DIR/cloud-run-service.default.yml"
  local CLOUD_RUN_NAME="$(get_cloudrun_name)"
  local BUILD_ID="$(git_commit_id)"
  local IMAGE="$(get_docker_image_tag)"

  export D1_ENV D1_SITE CLOUD_RUN_NAME BUILD_ID IMAGE

  local DATE=$(date '+%Y%m%d_%H%M%S')
  local OUTFILE_PATH="./deploy/cloud-run-service.$DATE.yml"

  if [ -f "$OVERRIDE_FILE_PATH" ]; then
    echo "Override file $OVERRIDE_FILE_PATH exists. Merging..."
    yq ea 'select(fileIndex == 0) *d select(fileIndex == 1)' "$DEFAULT_FILE_PATH" \
      "$OVERRIDE_FILE_PATH" | envsubst >"$OUTFILE_PATH"
  else
    echo "Override file $OVERRIDE_FILE_PATH does not exist. Using default..."
    envsubst <"$DEFAULT_FILE_PATH" >"$OUTFILE_PATH"
  fi

  echo "$OUTFILE_PATH generated."
  cat "$OUTFILE_PATH"
  printf '\n--------------------------\n'

  gcloud run services replace "$OUTFILE_PATH"

  echo "Cloud Run service $CLOUD_RUN_NAME updated."
}

auth_docker_repository() {
  gcloud auth configure-docker "$DOCKER_REGISTRY_HOST"
}

delete_subscription() {
  local SUBSCRIPTION="$(get_subscription_name)"

  if subscription_exists "$SUBSCRIPTION"; then
    echo "Subscription $SUBSCRIPTION exists. Deleting..."
    gcloud pubsub subscriptions delete "$SUBSCRIPTION"
  else
    echo "Subscription $SUBSCRIPTION does not exist. Skip deleting..."
  fi
}

delete_topic() {
  local TOPIC_NAME="$(get_topic_name)"
  local SUBSCRIPTION="$(get_subscription_name)"

  if topic_exists "$TOPIC_NAME"; then
    echo "Topic $TOPIC_NAME exists. Deleting..."
    gcloud pubsub topics delete "$TOPIC_NAME"
  else
    echo "Topic $TOPIC_NAME does not exist. Skipping deletion..."
  fi
}

delete_scheduler() {
  local JOB_NAME="$(get_scheduler_name)"

  if scheduler_exists "$JOB_NAME"; then
    echo "Scheduler $JOB_NAME exists. Deleting..."
    gcloud scheduler jobs delete "$JOB_NAME" --location "$X_CLOUDSDK_SCHEDULER_LOCATION"
  else
    echo "Scheduler $JOB_NAME exists. Skipping deletion..."
  fi
}

delete_cloudrun() {
  if cloudrun_exists "$(get_cloudrun_name)"; then
    echo "Cloud Run service $(get_cloudrun_name) exists. Deleting..."
    gcloud run services delete "$(get_cloudrun_name)"
  else
    echo "Cloud Run service $(get_cloudrun_name) not exists."
  fi
}

send_message_to_pubsub() {
  gcloud pubsub topics publish "$(get_topic_name)" "$1"
}

get_deadletter_topic_name() {
  local TASK_NAME=$(get_task_name)
  echo "topic-cornerstone-${D1_ENV}-${D1_SITE}-deadletter"
}

get_deadletter_subscription_name() {
  echo "sub-cornerstone-${D1_ENV}-${D1_SITE}-deadletter"
}

# Public: DeadLetter 토픽이 없는 경우 생성한다
create_deadletter_topic_and_subscription() {
  local TOPIC_NAME=$(get_deadletter_topic_name)
  local SUBSCRIPTION=$(get_deadletter_subscription_name)

  if topic_exists "$TOPIC_NAME"; then
    echo "Topic $TOPIC_NAME already exists. Skip creating topic."
  else
    echo "Topic $TOPIC_NAME does not exist. Creating..."
    gcloud pubsub topics create "$TOPIC_NAME" \
      --flags-file="$DEPLOY_DIR/.common.default.tmp.yml"
  fi

  if subscription_exists "$SUBSCRIPTION"; then
    echo "Subscription $SUBSCRIPTION already exists. Updating.."
    gcloud pubsub subscriptions update "$SUBSCRIPTION" \
      --push-endpoint="$ENTRYPOINT"
  else
    echo "Subscription $SUBSCRIPTION does not exist. Creating..."
    gcloud pubsub subscriptions create "$SUBSCRIPTION" \
      --flags-file="$DEPLOY_DIR/.common.default.tmp.yml"
    --topic "$TOPIC_NAME" \
      --expiration-period="never"
  fi

  return $?
}

get_dead_letter_topic_name() {
  local TASK_NAME=$(get_task_name)
  echo "topic-cornerstone-${D1_ENV}-${D1_SITE}-deadletter"
}

get_deadletter_subscription_name() {
  echo "sub-cornerstone-${D1_ENV}-${D1_SITE}-deadletter"
}

# Public: DeadLetter 토픽이 없는 경우 생성한다
create_deadletter_topic_and_subscription() {
  local TOPIC_NAME=$(get_dead_letter_topic_name)
  local SUBSCRIPTION=$(get_deadletter_subscription_name)

  if topic_exists "$TOPIC_NAME"; then
    echo "Topic $TOPIC_NAME already exists. Skip creating topic."
  else
    echo "Topic $TOPIC_NAME does not exist. Creating..."
    gcloud pubsub topics create "$TOPIC_NAME" \
      --flags-file="$DEPLOY_DIR/.common.default.tmp.yml"
  fi

  if subscription_exists "$SUBSCRIPTION"; then
    echo "Subscription $SUBSCRIPTION already exists. Updating.."
    gcloud pubsub subscriptions update "$SUBSCRIPTION" \
      --push-endpoint="$ENTRYPOINT"
  else
    echo "Subscription $SUBSCRIPTION does not exist. Creating..."
    gcloud pubsub subscriptions create "$SUBSCRIPTION" \
      --flags-file="$DEPLOY_DIR/.common.default.tmp.yml" \
      --topic "$TOPIC_NAME" \
      --expiration-period="never"
  fi

  return $?
}

create_temp_common_default() {
  envsubst <"$DEPLOY_DIR"/common.default.yml >"$DEPLOY_DIR"/.common.default.tmp.yml
}

_deploy() {
  create_temp_common_default

  # build the image if FORCE_BUILD is true or docker image not exits,
  local DOCKER_IMAGE_TAG=$(get_docker_image_tag)
  local DOCKER_IMAGE_EXISTS=$(docker_image_exists_local "$DOCKER_IMAGE_TAG")

  if [ "$FORCE_BUILD" = "true" ] || [ "$DOCKER_IMAGE_EXISTS" = "false" ]; then
    echo "Building docker image..."
    build_docker_image "$DOCKER_BUILD_ARGS"
  else
    echo "Docker image $DOCKER_IMAGE_TAG already exists. Skip building docker image."
  fi

  push_docker_image
  replace_cloudrun "$CLOUD_RUN_SERVICE_OVERRIDE_FILE"

  create_topic
  create_deadletter_topic_and_subscription

  # if $SUBSCRIPTION_FLAGS_FILE is normal file, use it
  if [ -f "$SUBSCRIPTION_FLAGS_FILE" ]; then
    create_subscription --flags-file "$SUBSCRIPTION_FLAGS_FILE"
  else
    create_subscription
  fi

  # if $USING_SCHEDULER == 'true' -> create scheduler
  if [ "$USING_SCHEDULER" = "true" ]; then
    # if $SCHEDULER_FLAGS_FILE is unset or not found, exit with error message
    if [ -z "$SCHEDULER_FLAGS_FILE" ] || [ ! -f "$SCHEDULER_FLAGS_FILE" ]; then
      echo "Scheduler flags file not found: $SCHEDULER_FLAGS_FILE"
      exit 1
    fi
    create_scheduler --flags-file "$SCHEDULER_FLAGS_FILE"
  fi

  echo ""
  echo "Deployment completed. 🚀"
  echo "-------------------------"
  print_urls
}

print_urls() {
  echo "* Artifact Registry Container Image at 👉 $(get_artifact_registry_url)"
  echo "* Cloud Run at 👉 $(get_cloudrun_url)"
  echo "* Cloud Run Log at 👉 $(get_cloudrun_log_url)"
  echo "* Cloud Pub/Sub Topic at 👉 $(get_topic_url)"
  echo "* Cloud Pub/Sub Subscription at 👉 $(get_subscription_url)"
  if [ "$USING_SCHEDULER" = "true" ]; then
    echo "* Cloud Scheduler at 👉 $(get_scheduler_url)"
  fi
}

_undeploy() {
  # if $USING_SCHEDULER == 'true' -> create scheduler
  if [[ "$USING_SCHEDULER" = "true" ]]; then
    delete_scheduler
  fi

  delete_subscription
  delete_topic

  delete_cloudrun
}
