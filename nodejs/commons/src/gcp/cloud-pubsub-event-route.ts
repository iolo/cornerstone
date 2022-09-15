import { LoggerFactory } from '@day1co/pebbles';
import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';

import type { Task } from '../task';
import type { CloudPubSubEvent } from './cloud-pubsub-event';
import { ENDPOINT_METHOD, ENDPOINT_PATH } from './run';

const logger = LoggerFactory.getLogger('cornerstone-commons:gcp:cloud-pubsub-event-route');

export type ExecuteTaskRequest = FastifyRequest<{
  Body: CloudPubSubEvent;
}>;

export class CloudPubSubEventRoute<T> {
  constructor(readonly task: Task<T>) {}

  async executeTask(request: ExecuteTaskRequest, reply: FastifyReply) {
    const data = request.body.message.data;
    const message = data ? Buffer.from(data, 'base64').toString() : '';
    logger.info('accept request: body=%s, message=%s', request.body, message);
    setImmediate(() => {
      this.task
        .execute(JSON.parse(message) as T)
        .then(() => logger.debug('ok'))
        .catch((e) => logger.error('error', e));
    });
    reply.code(200);
    reply.send('SUCCESS');
  }
  bindRoutes(server: FastifyInstance) {
    server.route({
      method: ENDPOINT_METHOD,
      url: ENDPOINT_PATH,
      handler: this.executeTask.bind(this),
    });
  }
}
