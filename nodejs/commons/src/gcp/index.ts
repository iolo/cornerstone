import { getMetadata } from './metadata';
import { getRunEndpoint } from './run';
import { setupPubSub } from './pubsub';
import { setupScheduler } from './scheduler';

export { ENDPOINT_PORT, ENDPOINT_METHOD, ENDPOINT_PATH, parseMessage } from './run';

export interface SetupOptions {
  name: string;
  env: string;
  site: string;
  schedule?: string;
  timeZone?: string;
}

// GCP 인프라 셋업
export async function setup({ name, env, site, schedule, timeZone }: SetupOptions) {
  const { projectId, region, accessToken } = await getMetadata();
  const endpoint = await getRunEndpoint({ projectId, region, accessToken });

  const topicName = getTopicName(name, env, site);
  const subscriptionName = getSubscriptionName(topicName);

  // 메시지를 수신하면 cloud run을 실행하는 cloud pubsub topic 설정
  await setupPubSub({ projectId, topicName, subscriptionName, endpoint });

  if (schedule && timeZone) {
    // 정해진 일정에 따라 토픽에 메시지를 전송할 cloud schduler job 생성
    const jobName = getJobName(topicName);
    await setupScheduler({ projectId, region, jobName, topicName, schedule, timeZone });
  }
}

function getTopicName(name: string, env: string, site: string): string {
  return `TEST_${name}_${env}_${site}`;
}

function getSubscriptionName(topicName: string): string {
  return `TEST_${topicName}_bus_trigger`;
}

function getJobName(topicName: string): string {
  return `TEST_${topicName}_cron_trigger`;
}
