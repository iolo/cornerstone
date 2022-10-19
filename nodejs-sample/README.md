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

```console
$ curl http://localhost:8080/.ping
> pong!

$ curl 'http://localhost:8080/?message="hello"'
> ACCEPTED

$ curl -X POST -H 'Content-Type:application/json' -d '{"message":{"data":"eyJtZXNzYWdlIjogImhlbGxvIn0="}}' http://localhost:8080/
> ACCEPTED
```

---
May the **SOURCE** be with you...
