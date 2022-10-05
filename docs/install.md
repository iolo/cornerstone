# 설치와 설정

## 필수 커맨드 설치

## gcloud CLI 설치

gcloud CLI 설치와 초기 설정은 아래 문서를 참고하세요.
https://cloud.google.com/sdk/docs/install
https://cloud.google.com/sdk/docs/initializing

## yq 설치

https://github.com/mikefarah/yq/blob/v4.27.2/README.md#install

## envsubst 설치

GNU 의 gettext 를 설치합니다.

## Artifact Registry 사용설정

Container Image 저장은 Artifact Registry 를 사용합니다.

Artifact Registry 에 docker push 를 하려면 아래 명령을 통해 인증정보를 설정해야 합니다. 

```shell
gcloud auth configure-docker asia-northeast3-docker.pkg.dev
```
