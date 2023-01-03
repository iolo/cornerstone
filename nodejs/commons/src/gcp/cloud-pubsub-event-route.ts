import { LoggerFactory } from '@day1co/pebbles';
import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';

import type { Task } from '../task';
import type { CloudPubSubEvent } from './cloud-pubsub-event';
import { ENDPOINT_METHOD, ENDPOINT_PATH } from './run';

const logger = LoggerFactory.getLogger('cornerstone-commons:gcp:cloud-pubsub-event-route');

export type ExecuteTaskRequest = FastifyRequest<{
  Body: CloudPubSubEvent;
}>;

// XXX: 잘못된 의존성 방향이 잘못됐음!
// 그냥 삭제해버리고 싶지만 이미 몇개가 배포되어 있는 상황...
// cornerstone-client의 message.ts 파일을 복사해 옴.
// import { PublishingMessage } from '@day1co/cornerstone-client/lib';
/** @deprecated in favor of cloud pub/sub native messageId */
export interface PublishingMessage<T> {
  message: T;
  requestId: string;
}

export class CloudPubSubEventRoute<T> {
  constructor(readonly task: Task<T>) {}

  async executeTask(request: ExecuteTaskRequest, reply: FastifyReply) {
    const data = request.body.message.data;
    const message = data ? Buffer.from(data, 'base64').toString() : '';
    logger.info('accept request: body=%o, message=%s', request.body, message);

    let parsed: T;
    try {
      // 당분간 requestId가 있는 버전과 없는 버전을 모두 지원...
      const publishedMessage = <PublishingMessage<T>>JSON.parse(message);
      if (publishedMessage?.message || typeof publishedMessage?.requestId === 'string') {
        // old format(published by cornerstone-client's Client)
        parsed = publishedMessage?.message;
      } else {
        // new format(published by cornerstone-client's CornerstoneClient)
        parsed = <T>JSON.parse(message);
      }
    } catch {
      reply.code(400);
      reply.send(`Bad Parameters: ${message}`);
      return;
    }

    try {
      await this.task.execute(parsed);
      logger.debug('ok');
    } catch (e) {
      logger.error('error: %o', e);
    }
    reply.code(202);
    reply.send('ACCEPTED');
  }

  bindRoutes(server: FastifyInstance) {
    server.route({
      method: ENDPOINT_METHOD,
      url: ENDPOINT_PATH,
      handler: this.executeTask.bind(this),
    });
  }
}
