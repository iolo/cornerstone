import fastify, { FastifyInstance } from 'fastify';
import { LoggerFactory } from '@day1co/pebbles';
import type { Task } from '@day1co/cornerstone-commons';
import { TaskRoute } from '@day1co/cornerstone-commons/lib/task-route';
import { CloudPubSubEventRoute } from '@day1co/cornerstone-commons/lib/gcp/cloud-pubsub-event-route';

const logger = LoggerFactory.getLogger('cornerstone-commons-starter-starter');

export class Application<T> {
  server: FastifyInstance;
  taskRoute: TaskRoute<T>;
  cloudPubSubEventRoute: CloudPubSubEventRoute<T>;

  constructor(readonly task: Task<T>) {
    this.server = fastify();
    this.taskRoute = new TaskRoute(this.task);
    this.cloudPubSubEventRoute = new CloudPubSubEventRoute(this.task);
    this.taskRoute.bindRoutes(this.server);
    this.cloudPubSubEventRoute.bindRoutes(this.server);
  }

  async run() {
    return this.server
      .listen({ port: Number(process.env.PORT) || 8080, host: '0.0.0.0' })
      .then((address) => {
        logger.info(`server started... ${address}`);
      })
      .catch((err) => {
        logger.error(`failed to listen: ${err}`);
        process.exit(1);
      });
  }

  async destroy(): Promise<void> {
    return this.server
      .close()
      .then(() => {
        logger.info('server closed...');
      })
      .catch((err) => {
        logger.error(`failed to close: ${err}`);
      });
  }
}
