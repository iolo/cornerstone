import { CloudSchedulerClient } from '@google-cloud/scheduler';
import { LoggerFactory } from '@day1co/pebbles';

const logger = LoggerFactory.getLogger('cornerstone-starter-commons-starter');

export interface SetupSchedulerOptions {
  projectId: string;
  region: string;
  jobName: string;
  topicName: string;
  // endpoint: string;
  schedule: string;
  timeZone: string;
}

export async function setupScheduler({
  projectId,
  region,
  jobName,
  topicName,
  schedule,
  timeZone,
}: SetupSchedulerOptions) {
  const client = new CloudSchedulerClient();

  const request = {
    parent: client.locationPath(projectId, region),
    job: {
      name: jobName,
      // $ gcloud scheduler jobs create pubsub myjob
      // --schedule "0 1 * * 0"
      // --topic cron-topic
      // --message-body "Hello"
      pubsubTarget: { topicName },
      // $ gcloud scheduler jobs create http test-job --schedule "5 * * * *"
      // --http-method=HTTP-METHOD
      // --uri=SERVICE-URL
      //httpTarget: {
      //  uri: endpoint,
      //  httpMethod: 'POST',
      //  body: JSON.stringify({ message: Buffer.from(message).toString('base64') }),
      //},
      schedule,
      timeZone,
    },
  };
  logger.debug('creating scheduler job: %o', request);

  const [job] = await client.createJob(request);
  logger.debug('scheduler job created: %o', job);

  return job;
}
