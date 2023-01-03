# 태스크의 메시지 교환 형식

## cornerstone-client 와 연동

cornerstone-client 를 사용하는 측에서는 다음처럼 코드를 사용합니다.

```typescript 
import { CornerstoneClient } from '@day1co/cornerstone-client';
import { FastBus } from '@day1co/fastbus';
import { LoggerFactory } from '@day1co/pebbles';

const logger = LoggerFactory.getLogger('my-logger');
const bus = new FastBus({}, BusType.PUBSUB);
const client = new CornerstoneClient({logger, bus});

// stub 를 얻어서
const taskName = `day1-${process.env.SPRING_CLOUD_CONFIG_PROFILE}-update-enrollment-state`;
const updateEnrollmentState = client.getStub(topicName);
// 'update-enrollment-state': 태스크 이름

// 메시지를 보낸다
const message = {state: 'NORMAL'};
updateEnrollmentState(message);
```

## nodejs-sample 의 예제

같은 내용을 nodejs-sample 프로젝트에서 확인해봅니다.

```shell
./ctask publish nodejs-sample/deploy/deploy-development.env '{ "message": "hello world" }'
```

위 JSON을 publish 하면 `SampleTask.execute` 의 `message` 파라미터는 `hello world` 을 받게 됩니다.
이 코드는 [nodejs-sample/src/sample-task.ts](../nodejs-sample/src/sample-task.ts) 에서 확인할 수 있습니다.

```typescript
export class SampleTask implements Task<string> {
  constructor(readonly sampleService: SampleService) {
  }

  async execute(message: string): Promise<void> { // message = "hello world"
    logger.info(`message:${message}`);
    try {
      this.sampleService.doSomething(message);
    } catch (e) {
      throw e;
    }
  }
}
```

## Scheduler 의 message body 에서의 사용법

이번에는 scheduler 의 message body 에서 확인해봅니다. 

스케줄러 flags-file 의 `--message-body` 항목을 수정합니다.
실제 사용할 오브젝트가 `"hello"` 라면, 이 오브젝트를 `message` 키에 넣도록 합니다.

```yaml
--message-body: '{ "message": "hello" }'
```

참고: [nodejs-sample/deploy/scheduler-flags.yml](../nodejs-sample/deploy/scheduler-flags.yml)
