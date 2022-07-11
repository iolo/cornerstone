import { PubSub } from '@google-cloud/pubsub';
import { LoggerFactory } from '@day1co/pebbles';

const logger = LoggerFactory.getLogger('cornerstone-starter-commons-starter');

export interface SetupPubSubOptions {
  projectId: string;
  topicName: string;
  subscriptionName: string;
  endpoint: string;
}

export async function setupPubSub({ projectId, topicName, subscriptionName, endpoint }: SetupPubSubOptions) {
  const pubsub = new PubSub({ projectId });

  // 기존 구독 삭제
  // $ gcloud pubsub subscriptions delete TOPIC
  //await pubsub.subscription(subscriptionName).delete();
  //logger.debug('subscription deleted: %o', subscriptionName);

  // 기존 토픽 삭제
  // $ gcloud pubsub topics delete TOPIC
  //await pubsub.topic(topicName).delete();
  //logger.debug('topic deleted: %o', topicName);

  // 토픽 등록
  // $ gcloud pubsub topics create TOPIC-NAME
  const [topic] = await pubsub.createTopic(topicName);
  logger.debug('topic created: %o', topic);

  // 구독 등록
  // 토픽으로 전송된 메시지를 수신해서 cloud run http endpoint 전달
  // $ gcloud pubsub subscriptions create SUBSCRIPTION
  // --topic TOPIC
  // --push-endpoint=ENDPOINT
  const [subscription] = await pubsub.createSubscription(topicName, subscriptionName, { pushEndpoint: endpoint });
  logger.debug('subscription created: %o', subscription);

  return [topic, subscription];
}
