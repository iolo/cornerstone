cornerstone-task-nodejs-sample
=========================

TypeScript + NodeJS + Fastify를 이용한 cornerstone 타스크 예제

시작하기
--------

### 로컬에서 빌드 & 실행

```console
$ npm ci
$ npm run build
$ npm start
```

> FIXME: 로컬에서 실행하면 cloud pubsub이나 cloud scheduler를 통해 타스크를 시작할 수 없음

```console
$ curl http://localhost:8080/.ping
> pong!

$ curl 'http://localhost:8080/?message="hello"'
> ACCEPTED

$ curl -X POST -H 'Content-Type:application/json' -d '{"message":{"data":"ImhlbGxvIg=="}}' http://localhost:8080/
> ACCEPTED
```

### deploy

TODO: setup CI/CD

#### `config.sh` 파일의 환경변수 설정

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

1. docker 이미지를 빌드하고,
2. cloud registry에 이미지를 업로드하고,
3. 업로드한 이미지를 cloud run service를 생성/배포하고,
4. http endpoint를 조회해서
5. http endpoint를 트리거하는 cloud pubsub topic과 subscription을 생성하고(이미 있으면 무시)
6. 정해진 일정에 따라 http endpoint를 트리거하는 cloud scheduler job을 생성(이미 있으면 무시)

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
