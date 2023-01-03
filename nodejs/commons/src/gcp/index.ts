import { getMetadata } from './metadata';
import { getRunEndpoint } from './run';
import { setupPubSub } from './pubsub';
import { setupScheduler } from './scheduler';

export { ENDPOINT_PORT, ENDPOINT_METHOD, ENDPOINT_PATH, parseMessage } from './run';

export interface SetupOptions {
  name: string;
  schedule?: string;
  timeZone?: string;
}

// GCP 인프라 셋업
export async function setup({ name, schedule, timeZone }: SetupOptions) {
  const { projectId, region, accessToken } = await getMetadata();
  const endpoint = await getRunEndpoint({ projectId, region, accessToken });

  const topicName = getTopicName(name);
  const subscriptionName = getSubscriptionName(name);

  // 메시지를 수신하면 cloud run을 실행하는 cloud pubsub topic 설정
  await setupPubSub({ projectId, topicName, subscriptionName, endpoint });

  if (schedule && timeZone) {
    // 정해진 일정에 따라 토픽에 메시지를 전송할 cloud schduler job 생성
    const jobName = getJobName(name);
    await setupScheduler({ projectId, region, jobName, topicName, schedule, timeZone });
  }
}

function getTopicName(name: string): string {
  return `topic-cornerstone-${name}`;
}

function getSubscriptionName(name: string): string {
  return `subscription-cornerstone-${name}`;
}

function getJobName(taskName: string): string {
  return `scheduler-cornerstone-${taskName}`;
}
