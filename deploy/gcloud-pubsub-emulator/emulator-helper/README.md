GCP Pub/Sub Emulator Helper
===========================

이 코드는 [GCP Pub/Sub Emulator](https://cloud.google.com/pubsub/docs/emulator)를 위한 것입니다.
gcloud CLI는 Pub/Sub 에뮬레이터에 토픽추가 및 구독 추가같은 작업을 할 수 없습니다.

[참고](https://cloud.google.com/pubsub/docs/emulator)

> To use the emulator, you must have an application built using the Cloud Client Libraries. The emulator does not
> support Google Cloud console or gcloud pubsub commands.

이에 따라 코너스톤의 로컬 테스트를 위해서 별도의 프로그램을 작성했습니다.

## 설치 

```console
go build 
```

## Usage

GCP 에뮬레이터가 기동된 상태에서 작동합니다.

0. 변수 설정

```
export PUBSUB_EMULATOR_HOST="localhost:8085"
export PUBSUB_PROJECT_ID="fastcampus-web-local"
TOPIC_ID="nodejs-sample"
```

## Topic 등록

```
./emulator-helper topic create $TOPIC_ID
```

## Topic 리스트 

```
./emulator-helper topic list 
```

## Push Subscription 등록

```
./emulator-helper sub create-push -t $TOPIC_ID nodejs-sample-sub  http://nodejs-sample:8080
```

## Publish

```
./emulator-helper topic publish $TOPIC_ID '{"message": "hello world"}'
```

---
may the **SOURCE** be with you...