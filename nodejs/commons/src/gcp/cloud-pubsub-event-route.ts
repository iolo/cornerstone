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

    let parsed: T;
    try {
      parsed = JSON.parse(message);
    } catch {
      reply.code(400);
      reply.send(`Bad Parameters: ${message}`);
      return;
    }

    setImmediate(() => {
      this.task
        .execute(parsed)
        .then(() => logger.debug('ok'))
        .catch((e) => logger.error('error', e));
    });
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
