# ctask

> 사용 전 필요한 유틸리티와 설정 파일을 준비해 주세요. [설치와 설정](../README.md#설치와-설정), [태스크 배포 변수](../README.md#태스크-배포-변수) 등을 참고하세요.

코너스톤 태스크에 대한 주요작업을 돕는 커맨드 입니다. Bash 쉘 환경에서 작동합니다.

## Table for ctask commands

| Command          | Description                        |
|------------------|------------------------------------|
| `ctask deploy`   | GCP 에 태스크를 배포합니다.                  |
| `ctask undeploy` | GCP 에 배포된 테스크를 회수합니다.              |
| `ctask info`     | env 파일로부터 태스크 정보를 출력합니다.           |
| `ctask publish`  | 환경파일에 지정된 태스크에 Pub/Sub 메시지를 발행합니다. |
| `ctask urls`     | 배포 관련 URL을 얻습니다.                   |
| `ctask mock`     | 테스트 배포를 진행합니다.                     |
| `ctask unmock`   | 테스트 배포를 회수합니다.                     | 
| `ctask help`     | 도움말을 출력합니다.                        |

## 테스트 배포 (`mock`)

사용자 지정 URL(`$CUSTOM_ENTRYPOINT`) 를 토픽에 등록하도록 배포합니다.
`$CUSTOM_ENTRYPOINT`가 제시 되지 않으면 로컬의 ngrok URL을 확인해 사용합니다.
ngrok URL 은 로컬의 8080 포트를 사용하는 Public URL 을 확인합니다.

mock은 deploy 와 다르게 컨테이너 빌드와 Cloud Run 배포를 하지 않습니다.

**CUSTOM_ENTRYPOINT 를 지정하는 경우:**

```shell
CUSTOM_ENTRYPOINT="http://example.com/" ./ctask mock ./nodejs-sample/deploy/deploy-dev.env
```

**ngrok 을 사용하는 경우 CUSTOM_ENTRYPOINT 생략가능 :**

```shell
./ctask mock ./nodejs-sample/deploy/deploy-dev.env
```

## 태스크 실행 (`publish`)

환경설정에 지정된 토픽으로 태스크 메시지를 발행합니다.
메시지는 JSON 형식이어야 합니다.

```shell
./ctask publish ./nodejs-sample/deploy/deploy-dev.env '"hello world"'
```

위 예제에서 `hello world` 는 문자열 이므로 `""` 으로 감쌌고, 쉘에서 `""` 를 문자열 파싱에 사용하는 것을 막기 위해 다시 `''` 로 감쌌습니다.

## 배포(`deploy`)

* Docker 를 이용해 이미지 빌드
* Artifact Registry 에 이미지 배포
* Cloud Run 컨테이너 이미지 구동 설정
* Cloud Pub/Sub 설정
* (Optional) Cloud Scheduler 설정

```shell
./ctask deploy ./nodejs-sample/deploy/deploy-dev.env
```

## 배포제거(`undeploy`)

* Cloud Run 제거
* Cloud Pub/Sub 제거
* Cloud Scheduler 제거

⚠️ Artifact Registry 와 로컬의 Docker Image 는 제거하지 않습니다.

```shell
./ctask undeploy ./nodejs-sample/deploy/deploy-dev.env
```

## Google Cloud Platform Console URL 표시

```shell
./ctask urls ./nodejs-sample/deploy/deploy-dev.env
```

## 정보확인 (info)

.env 파일로부터 태스크 정보를 출력합니다.

```shell
./ctask info ./nodejs-sample/deploy/deploy-dev.env
```
