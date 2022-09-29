import { LoggerFactory } from '@day1co/pebbles';
import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';

import type { Task } from './task';

const logger = LoggerFactory.getLogger('cornerstone-commons:task-route');

export interface ExecuteTaskRequestQuery {
  message: string;
}

export type ExecuteTaskRequest = FastifyRequest<{
  Querystring: ExecuteTaskRequestQuery;
}>;

export class TaskRoute<T> {
  constructor(readonly task: Task<T>) {}

  async executeTask(request: ExecuteTaskRequest, reply: FastifyReply) {
    let message: any;
    try {
      message = JSON.parse(request.query.message);
    } catch (e) {
      reply.code(400);
      reply.send(`Bad Parameters: ${request.query.message}`);
      return;
    }
    logger.info('accept request: message=%s', message);
    setImmediate(() => {
      this.task
        .execute(message)
        .then(() => logger.debug('ok'))
        .catch((e: Error) => logger.error('error', e));
    });
    reply.code(202);
    reply.send('ACCEPTED');
  }

  async ping(request: FastifyRequest, reply: FastifyReply) {
    reply.code(200);
    reply.send('pong!');
  }

  bindRoutes(server: FastifyInstance) {
    server.get('/', this.executeTask.bind(this));
    server.get('/.ping', this.ping.bind(this));
  }
}
