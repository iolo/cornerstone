cornerstone-task-spring-boot-sample
==============================

스프링 부트를 이용한 cornerstone 타스크 예제

Getting Started
---------------

### build

```console
$ mvn package
```

### test run

```console
$ mvn spring-boot:run
```

```console
$ curl http://localhost:8080/.ping
pong!
```

### deploy

TODO: setup CI/CD

`deploy.sh` 파일 맨 위 환경변수들을 적절히 설정하고 실행하면:

1. [docker] 이미지를 빌드하고,
2. [cloud registry]에 이미지를 업로드하고,
3. 업로드한 이미지를 [cloud run] [service]를 생성/배포하고, [http endpoint]를 조회해서
4. [http endpoint]를 트리거하는 [cloud pubsub] [topic]/[subscription]을 생성하고(이미 있으면 무시)
5. 정해진 일정에 따라 http endpoint를 트리거하는 [cloud scheduler] [job]을 생성(이미 있으면 무시)

- PROJECT=fastcampus-web-services
- REGION=asia-northeast3
- SITE=day1
- ENV=dev
- NAME=sample
- VERSION=latest
- IMAGE=gcr.io/${PROJECT}/gcr-cornerstone-${SITE}-${NAME}:${VERSION}
- SERVICE=run-cornerstone-${ENV}-${SITE}-${NAME}
- TOPIC=topic-cornerstone-${ENV}-${SITE}-${NAME}
- SUBSCRIPTION=sub-cornerstone-${ENV}-${SITE}-${NAME}
- JOB=scheduler-cornerstone-${ENV}-${SITE}-${NAME}
- SCHEDULE="0/5 * * *"  # 스케쥴러가 필요할때만 지정
- TIMEZONE="Asia/Seoul" # 스케줄러가 필요할때만 지정
- SKIP_BUILD=
- SKIP_PUSH=
- SKIP_DEPLOY=

```console
$ ./deploy.sh
```

Internals
---------

* GCP resources
  - Container Registry Image: gcr-cornerstone-day1-sample
  - Cloud Run Service: run-cornerstone-dev-day1-sample
  - Cloud PubSub Topic: topic-cornerstone-dev-day1-sample
  - Cloud PubSub Subscription: sub-cornerstone-dev-day1-sample
  - Cloud Scheduler Job: scheduler-cornerstone-dev-day1-sample

---
May the **SOURCE** be with you...

[docker]:
[cloud registry]:
[cloud run]:
[service]:
[http endpoint]:
[cloud pubsub]:
[topic]:
[subscription]:
[cloud scheduler]:
[job]:
