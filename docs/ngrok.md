# 로컬 테스트에 ngrok 사용

ngrok 은 외부 인터넷에서 로컬 서버에 접속할 수 있도록 해주는 툴입니다. 로컬에서 테스트를 하기 위해 사용합니다.
이 문서에서는 ngrok 을 통한 로컬 테스트에 필수 절차들을 설명합니다. 

## ngrok 설치

[ngrok](https://ngrok.com/) 에서 다운로드 받아 설치합니다.

## 회원가입 및 API 획득

ngrok 의 API Token을 사용하기 위해 회원가입과 API 토큰 획득이 필요합니다.

* 회원가입 : [https://dashboard.ngrok.com/signup](https://dashboard.ngrok.com/signup)
* API 토큰 획득 : [https://dashboard.ngrok.com/get-started/your-authtoken](https://dashboard.ngrok.com/get-started/your-authtoken)

## ngrok config 에 토큰 설치 

```shell
ngrok config add-api-key $발급받은API키
```

## ngrok 서버 실행

```shell
ngrok http 8080
```

## API 테스트

ngrok 서버가 실행된 후 새로운 쉘에서 다음 명령을 보내면 API 응답을 받을 수 있습니다.

```
ngrok api tunnels list 
```

```
200 OK
{
  "endpoints": [
    {
      "created_at": "2022-09-30T03:36:01Z",
      "hostport": "xx:443",
      "id": "xx",
      "metadata": "",
      "proto": "https",
      "public_url": "https://xx.jp.ngrok.io",
      "region": "jp",
      "tunnel": {
        "id": "xx",
        "uri": "xx"
      },
      "type": "ephemeral",
      "updated_at": "2022-09-30T03:36:01Z"
    }
  ],
  "next_page_uri": null,
  "uri": "https://api.ngrok.com/endpoints"
}
```

## 로컬 환경 배포

ngrok 이 정상적으로 실행되고 나면 이제 PubSub 에 로컬 환경을 구독 등록할 수 있습니다.

```
cd nodejs-sample
../ctask mock ./deploy/deploy-costa.env
npm run start
```
