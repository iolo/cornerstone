# Deimos 마이그레이션 가이드

Deimos 에서의 마이그레이션하는 방법을 소개합니다.

## jobs.js 확인

[jobs.js](https://github.com/day1co/deimos/blob/main/jobs.js)로부터 태스크의 인프라 특성을 확인합니다.

## 스케줄러 사용

스케줄러는 cron 키가 있는지 없는지로 확인할 수 있습니다.

```js
triggers: [{cron: '1/20 * * * *', timezone: 'UTC'}]
```

스케줄러 사용은 .env 파일과 scheduler flags 파일에서 지정할 수 있습니다.

```shellscript
USING_SCHEDULER=true
SCHEDULER_FLAGS_FILE="./scheduler-flags.yml"
```

```yaml
--schedule: '*/10 * * * *'
--time-zone: "Etc/UTC"
--message-body: '{ "message": "hello" }'
```

## 컴퓨팅 성능

다음과 같이 설정된 job 이 있습니다.

```js
const job = {
    task: 'createExportExcelFile',
    triggers: [{bus: 'create:export:excel'}],
    queue: 0,
    concurrency: 1,
    memory: 2048,
    cpu: 1000,
    throttling: false,
    mode: 'gen2',
    cpu_throttling: false,
    time_limit: 600,
}
```

이 job 의 프로퍼티를 참고해 cloud run service override 파일을 수정합니다.

```shellscript
# .env 파일, 파일의 경로 지정 
CLOUD_RUN_SERVICE_OVERRIDE_FILE="./cloud-run-service.override.yml"
```

```yaml 
# cloud-run-service.override.yml 파일 

template:

    metadata:
      annotations:
        autoscaling.knative.dev/maxScale: '1'  # 👈 queue
        autoscaling.knative.dev/minScale: '0'
        run.googleapis.com/execution-environment: gen2
        run.googleapis.com/vpc-access-connector: cloudrun-vpc-connector-03
        run.googleapis.com/vpc-access-egress: all-traffic
        run.googleapis.com/cpu-throttling: 'false', // 👈 cpu_throttling
    spec:
        containerConcurrency: 1 # 👈 concurrency
        timeoutSeconds:  600 # 👈 time_limit
        containers:
        - ...
          resources:
            limits:
              cpu: 1000m  # 👈 cpu, 숫자 뒤에 `m` 을 붙일 것 
              memory: 2048Mi # 👈 memory, 숫자 뒤에 `Mi` 를 붙일것 
```

## 권한

권한이 필요한 태스크는 redstone-support 의 grantAllPermissions 를 사용해 수동으로 설정해야 합니다.

```typescript
import {createLocalContext, closeLocalContext} from '@day1co/redstone-support/lib/cls';
import {grantAllPermissions} from '@day1co/redstone-support/lib/permission';

class SomeTask extends Task {

  async execute(): Promise<void> {
    const context = createLocalContext();
    grantAllPermissions();
    // ...
    closeLocalContext(context);
  }
}

```