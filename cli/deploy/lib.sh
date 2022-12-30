#!/bin/bash

git_commit_id() {
  git rev-parse HEAD
}

# topic 유무에 따라 Exit Code 로 반환
# topic 이 있으면 0, 없으면 1 을 반환한다.
topic_exists() {
  local TOPIC=$1
  gcloud pubsub topics describe "$TOPIC" 1>/dev/null 2>/dev/null
  return $?
}

get_topic_url() {
  echo "https://console.cloud.google.com/cloudpubsub/topic/detail/${TOPIC_NAME}?project=${CLOUDSDK_CORE_PROJECT}"
}

# Public: 토픽이 없는 경우 생성한다
create_topic() {
  if topic_exists "$TOPIC_NAME"; then
    echo "Topic $TOPIC_NAME already exists. Skip creating topic."
  else
    echo "Topic $TOPIC_NAME does not exist. Creating..."
    gcloud pubsub topics create "$TOPIC_NAME" \
      ${GCLOUD_CLI_LABEL_OPTS}
  fi

  return $?
}

# 구독 유무에 따라 Exit Code 로 반환
# 구독이 있으면 0, 없으면 1 을 반환한다.
subscription_exists() {
  local SUBSCRIPTION=$1

  gcloud pubsub subscriptions describe "$SUBSCRIPTION" 1>/dev/null 2>/dev/null
  return $?
}

get_subscription_url() {
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
  local ENTRYPOINT="$(get_task_entrypoint)"
  local ACK_DEADLINE=300
  local MAX_DELIVERY_ATTEMPTS=5

  if subscription_exists "$SUBSCRIPTION_NAME"; then
    echo "Subscription $SUBSCRIPTION_NAME already exists. Updating.."
    gcloud pubsub subscriptions update "$SUBSCRIPTION_NAME" \
      --push-endpoint="$ENTRYPOINT"
  else
    echo "Subscription $SUBSCRIPTION_NAME does not exist. Creating..."
    gcloud pubsub subscriptions create "$SUBSCRIPTION_NAME" \
      ${GCLOUD_CLI_LABEL_OPTS} \
      --topic "$TOPIC_NAME" \
      --ack-deadline "$ACK_DEADLINE" \
      --push-endpoint="$ENTRYPOINT" \
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

  gcloud scheduler jobs describe "$JOB" --location $X_CLOUDSDK_SCHEDULER_LOCATION 1>/dev/null 2>/dev/null
  return $?
}

get_scheduler_url() {
  echo "https://console.cloud.google.com/logs/query;query=resource.type%3D%22cloud_scheduler_job%22%20AND%20resource.labels.job_id%3D%22${SCHEDULER_NAME}%22%20AND%20resource.labels.location%3D%22${X_CLOUDSDK_SCHEDULER_LOCATION}%22?project=${CLOUDSDK_CORE_PROJECT}"
}

# Public: 스케줄러가 없는 경우 생성한다
# 스케줄러는 일정시간마다 토픽에 메시지를 보낸다.
#
# ARGS 로 전달되는 값은 생성시에만 동작한다.
# gcloud scheduler create 문서를 참고한다.
#
create_scheduler() {
  local ARGS="$@"
  local ENTRYPOINT="$(get_task_entrypoint)"
  local TOPIC="projects/${CLOUDSDK_CORE_PROJECT}/topics/$TOPIC_NAME"

  if scheduler_exists "${SCHEDULER_NAME}"; then
    echo "Scheduler ${SCHEDULER_NAME} already exists. Replacing..."
    gcloud scheduler jobs delete "${SCHEDULER_NAME}" --location "$X_CLOUDSDK_SCHEDULER_LOCATION" -q
  else
    echo "Scheduler ${SCHEDULER_NAME} does not exist. Creating..."
  fi

  if [ "$USING_PUBSUB" = "true" ]; then
    gcloud scheduler jobs create pubsub "${SCHEDULER_NAME}" \
      --location "$X_CLOUDSDK_SCHEDULER_LOCATION" \
      --topic $TOPIC \
      $ARGS
  else
    gcloud scheduler jobs create http "${SCHEDULER_NAME}" \
      --location="$X_CLOUDSDK_SCHEDULER_LOCATION" \
      --uri="$ENTRYPOINT" \
      $ARGS
  fi
}

get_docker_image_tag() {
  local _VERSION="$(git_commit_id)"
  echo "${DOCKER_REGISTRY_HOST}/${DOCKER_REGISTRY_PATH}/${TASK_NAME}:${_VERSION}"
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
  export IMAGE_TAG="$(get_docker_image_tag)"
  # ARM 환경에서 빌드된 것이 배포되지 않도록 platform 은 linux/amd64 로 고정
  export DOCKER_DEFAULT_PLATFORM=linux/amd64

  docker compose build "$TASK_NAME"
  unset DOCKER_DEFAULT_PLATFORM
}

push_docker_image() {
  docker push "$(get_docker_image_tag)"
}

get_artifact_registry_url() {
  local DIGEST=$(docker inspect $(get_docker_image_tag) | jq -r '.[0].RepoDigests[0]' | sed -e "s|.*@||g")
  echo "https://console.cloud.google.com/artifacts/docker/${CLOUDSDK_CORE_PROJECT}/${CLOUDSDK_ARTIFACTS_LOCATION}/cornerstone-tasks/${TASK_NAME}/${DIGEST}?project=${CLOUDSDK_CORE_PROJECT}"
}

get_task_entrypoint() {
  if [ -z "$CUSTOM_ENTRYPOINT" ]; then
    gcloud run services describe "${CLOUD_RUN_NAME}" --format 'value(status.url)'
  else
    echo "$CUSTOM_ENTRYPOINT"
  fi
}

cloudrun_exists() {
  gcloud run services describe "${CLOUD_RUN_NAME}" 1>/dev/null 2>/dev/null
  return $?
}

get_cloudrun_url() {
  echo "https://console.cloud.google.com/run/detail/${CLOUDSDK_RUN_REGION}/${CLOUD_RUN_NAME}/metrics?project=${CLOUDSDK_CORE_PROJECT}"
}

get_cloudrun_log_url() {
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
  local IMAGE="$(get_docker_image_tag)"

  export CLOUD_RUN_NAME IMAGE

  local TEMP_OVERRIDE_FILE_PATH="$(mktemp)"
  local OUTFILE_PATH="$(mktemp)"

  if [ -f "$OVERRIDE_FILE_PATH" ]; then
    echo "Override file $OVERRIDE_FILE_PATH exists. Merging..."

    echo "$(yq ea 'select(fileIndex == 0) *d select(fileIndex == 1)' \
    "$DEFAULT_FILE_PATH" "$OVERRIDE_FILE_PATH")" > $TEMP_OVERRIDE_FILE_PATH

    # yq eval-all의 deep merge는 배열 안의 객체에는 적용되지 않는다.
    # see https://mikefarah.gitbook.io/yq/operators/multiply-merge#merge-arrays-of-objects-together-matching-on-a-key
    ENV_NAME_KEY=".name"  ENV_ARRAY=".spec.template.spec.containers.[].env" \
    yq ea '
      (  (( eval(strenv(ENV_ARRAY)) | .[] | {(eval(strenv(ENV_NAME_KEY))): .}) as $item ireduce ({}; . * $item )) as $ENV_MAP
        | ( $ENV_MAP | to_entries | .[]) as $item ireduce([]; . + $item.value)
      ) as $MERGED_ENV_ARRAY 
      | select(fileIndex == 0) | (eval(strenv(ENV_ARRAY))) = $MERGED_ENV_ARRAY
    ' "$TEMP_OVERRIDE_FILE_PATH" "$DEFAULT_FILE_PATH" \
    | envsubst > "$OUTFILE_PATH"

  else
    echo "Override file $OVERRIDE_FILE_PATH does not exist. Using default..."
    envsubst <"$DEFAULT_FILE_PATH" >"$OUTFILE_PATH"
  fi

  echo "$OUTFILE_PATH generated."
  cat "$OUTFILE_PATH"
  printf '\n--------------------------\n'

  gcloud run services replace "$OUTFILE_PATH"

  # allow unauthenticated access
  gcloud run services add-iam-policy-binding ${CLOUD_RUN_NAME} \
    --member="allUsers" --role="roles/run.invoker"

  echo "Cloud Run service $CLOUD_RUN_NAME updated."
}

auth_docker_repository() {
  gcloud auth configure-docker "$DOCKER_REGISTRY_HOST"
}

delete_subscription() {
  if subscription_exists "$SUBSCRIPTION_NAME"; then
    echo "Subscription $SUBSCRIPTION_NAME exists. Deleting..."
    gcloud pubsub subscriptions delete "$SUBSCRIPTION_NAME"
  else
    echo "Subscription $SUBSCRIPTION_NAME does not exist. Skip deleting..."
  fi
}

delete_topic() {
  if topic_exists "$TOPIC_NAME"; then
    echo "Topic $TOPIC_NAME exists. Deleting..."
    gcloud pubsub topics delete "$TOPIC_NAME"
  else
    echo "Topic $TOPIC_NAME does not exist. Skipping deletion..."
  fi
}

delete_scheduler() {
  if scheduler_exists "$SCHEDULER_NAME"; then
    echo "Scheduler $SCHEDULER_NAME exists. Deleting..."
    gcloud scheduler jobs delete "$SCHEDULER_NAME" --location "$X_CLOUDSDK_SCHEDULER_LOCATION" --quiet
  else
    echo "Scheduler $SCHEDULER_NAME exists. Skipping deletion..."
  fi
}

delete_cloudrun() {
  if cloudrun_exists "$CLOUD_RUN_NAME"; then
    echo "Cloud Run service $CLOUD_RUN_NAME exists. Deleting..."
    gcloud run services delete "$CLOUD_RUN_NAME" --quiet
  else
    echo "Cloud Run service $CLOUD_RUN_NAME not exists."
  fi
}

send_message_to_pubsub() {
  gcloud pubsub topics publish "${TOPIC_NAME}" "$1"
}

# Public: Dead Letter 토픽이 없는 경우 생성한다
create_dead_letter_topic_and_subscription() {
  local TOPIC_NAME=${DEAD_LETTER_TOPIC_NAME}
  local SUBSCRIPTION=${DEAD_LETTER_SUBSCRIPTION_NAME}

  if topic_exists "$TOPIC_NAME"; then
    echo "Dead-letter Topic $TOPIC_NAME already exists. Skip creating topic."
  else
    echo "Topic $TOPIC_NAME does not exist. Creating..."
    gcloud pubsub topics create "$TOPIC_NAME" \
      ${GCLOUD_CLI_LABEL_OPTS}
  fi

  if subscription_exists "$SUBSCRIPTION"; then
    echo "Dead-letter Subscription $SUBSCRIPTION already exists. Skip creating subscription.."
  else
    echo "Subscription $SUBSCRIPTION does not exist. Creating..."
    gcloud pubsub subscriptions create "$SUBSCRIPTION" \
      --topic "$TOPIC_NAME" \
      --expiration-period="never"
  fi

  return $?
}

_deploy() {
  # if $CUSTOM_ENTRYPOINT is null, then deploy to cloudrun
  if [ -z "$CUSTOM_ENTRYPOINT" ]; then
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
  fi

  if [ "$USING_PUBSUB" = "true" ]; then
    create_topic_and_subscription
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
}

_undeploy() {
  # if $USING_SCHEDULER == 'true' -> create scheduler
  if [ "$USING_SCHEDULER" == "true" ]; then
    delete_scheduler
  fi

  delete_subscription
  delete_topic

  if [ "$COMMAND" == "undeploy" ]  || [ "$COMMAND" == "redeploy" ]; then
    delete_cloudrun
  fi
}

check_container_healthy() {
  local CONTAINER_NAME=$1
  local HEALTHY=$(docker inspect $CONTAINER_NAME | jq -r '.[0].State.Health.Status')
  # return $HEALTY is healty
  if [ "$HEALTHY" = "healthy" ]; then
    return 0
  else
    return 1
  fi
}

gcloud_emulator_helper() {
  local EMULATOR_SERVICE_NAME="gcloud-pubsub-emulator"
  docker exec \
    "$EMULATOR_SERVICE_NAME" pubsub-emulator-helper "$@"
}

create_topic_and_subscription() {
  create_topic

  # if $SUBSCRIPTION_FLAGS_FILE is normal file, use it
  if [ -f "$SUBSCRIPTION_FLAGS_FILE" ]; then
    create_subscription --flags-file "$SUBSCRIPTION_FLAGS_FILE"
  else
    create_subscription
  fi
}

ngrok_get_public_endpoint() {
  local PORT=8080
  ngrok api tunnels list | jq -r -c ".tunnels[] | select(.forwards_to | contains(\"$PORT\")) | .public_url"
}

_publish() {
  local MESSAGE=$1
  echo "Publishing Message: $MESSAGE to topic: $TOPIC_NAME"
  gcloud pubsub topics publish "$TOPIC_NAME" --message "$MESSAGE"
}

_mock() {
  # if CUSTOM_ENDPOINT is not found, use ngrok
  if [ -z "$CUSTOM_ENDPOINT" ]; then
    echo "CUSTOM_ENDPOINT is not found. Use ngrok."
    CUSTOM_ENTRYPOINT=$(ngrok_get_public_endpoint)
    if [ -z "$CUSTOM_ENTRYPOINT" ]; then
      echo "ngrok is not running. Please run ngrok first."
      exit 1
    fi
  fi

  echo "Using CUSTOM_ENTRYPOINT: $CUSTOM_ENTRYPOINT"
  _deploy
}

_info() {
  echo "-------------------------"
  echo "Cloud Run"
  echo "-------------------------"
  echo "Name: $CLOUD_RUN_NAME"
  if cloudrun_exists; then
    echo "URL: $(get_cloudrun_url)"
    echo "Log URL: $(get_cloudrun_log_url)"
    echo "Entrypoint URL: $(get_task_entrypoint)"
  else
    echo "NOT FOUND!"
  fi

  if [ "$USING_PUBSUB" = "true" ]; then
    echo "-------------------------"
    echo "Topic & Subscription"
    echo "-------------------------"
    echo "Topic Name: $TOPIC_NAME"
    if topic_exists "$TOPIC_NAME"; then
      echo "Topic URL: $(get_topic_url)"
    else
      echo "NOT FOUND!"
    fi

    echo "Subscription Name: $SUBSCRIPTION_NAME"
    if subscription_exists "$SUBSCRIPTION_NAME"; then
      echo "Subscription URL: $(get_subscription_url)"
    else
      echo "NOT FOUND!"
    fi

    echo "Dead Letter Topic Name: $DEAD_LETTER_TOPIC_NAME"
    if topic_exists "$DEAD_LETTER_TOPIC_NAME"; then
      echo "URL: https://console.cloud.google.com/cloudpubsub/topic/detail/${DEAD_LETTER_TOPIC_NAME}?project=${CLOUDSDK_CORE_PROJECT}"
    else
      echo "NOT FOUND!"
    fi
    echo "Dead Letter Subscription Name: $DEAD_LETTER_SUBSCRIPTION_NAME"
    if subscription_exists "$DEAD_LETTER_SUBSCRIPTION_NAME"; then
      echo "URL: https://console.cloud.google.com/cloudpubsub/subscription/detail/${DEAD_LETTER_SUBSCRIPTION_NAME}?project=${CLOUDSDK_CORE_PROJECT}"
    else
      echo "NOT FOUND!"
    fi
  fi

  if [ "$USING_SCHEDULER" = "true" ]; then
    echo "-------------------------"
    echo "Cloud Scheduler"
    echo "-------------------------"
    echo "Name: ${SCHEDULER_NAME}"
    if scheduler_exists "${SCHEDULER_NAME}"; then
      echo "URL: $(get_scheduler_url)"
    else
      echo "NOT FOUND!"
    fi
  fi
}
