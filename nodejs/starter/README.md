cornerstone-nodejs-starter
=====================

cornerstone 타스크를 위한 NodeJS, Fastify 의존성 모듈

시작하기
--------

### cornerstone-nodejs-starter 패키지 설치 & 의존성 추가

```console
$ npm install --save @day1co/cornerstone-nodejs-starter
```

### 태스크 작성 및 애플리케이션 시작

```
$ cat > index.ts
import { Task } from '@day1co/cornerstone-commons';
import { Application } from '@day1co/cornerstone-nodejs-starter';

class SampleTask implements Task<string> {
  execute(message: string) {
    // TODO: write your task
  }
}

new Application(new SampleTask()).run();
```
   
---
May the **SOURCE** be with you...
