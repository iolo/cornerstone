cornerstone-nodejs-sample-server
================================

TypeScript + NodeJS + Fastify를 이용한 cornerstone 타스크 서버 예제

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

### 로컬에서 빌드해서 Cloud Run & Pub/Sub & Scheduler에 배포 & 실행

```console
$ npx ctask deploy deploy/deploy-development.env
$ npx ctask info deploy/deploy-development.env
$ npx ctask publish deploy/deploy-development.env '"test"'
$ npx ctask undeploy deploy/deploy-development.env
```

---
May the **SOURCE** be with you...
