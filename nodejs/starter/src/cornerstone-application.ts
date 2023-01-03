import fastify, { FastifyInstance } from 'fastify';
import { Logger } from '@day1co/pebbles';
import type { Task } from '@day1co/cornerstone-commons';
import { TaskRoute } from '@day1co/cornerstone-commons/lib/task-route';
import { CloudPubSubEventRoute } from '@day1co/cornerstone-commons/lib/gcp/cloud-pubsub-event-route';

export interface CornerstoneApplicationOpts<T> {
  logger: Logger;
  task: Task<T>;
  host?: string;
  port?: number;
}

export class CornerstoneApplication<T> {
  readonly logger: Logger;
  readonly task: Task<T>;
  readonly port: number;
  readonly host: string;
  readonly server: FastifyInstance;
  readonly taskRoute: TaskRoute<T>;
  readonly cloudPubSubEventRoute: CloudPubSubEventRoute<T>;

  constructor({ logger, task, port, host }: CornerstoneApplicationOpts<T>) {
    this.logger = logger;
    this.task = task;
    this.host = host ?? process.env.HOST ?? '0.0.0.0';
    this.port = port ?? Number(process.env.PORT ?? 8080);
    this.server = fastify();
    this.taskRoute = new TaskRoute(this.task);
    this.cloudPubSubEventRoute = new CloudPubSubEventRoute(this.task);
    this.taskRoute.bindRoutes(this.server);
    this.cloudPubSubEventRoute.bindRoutes(this.server);
  }

  async run() {
    return this.server
      .listen({ port: this.port, host: this.host })
      .then((address) => {
        this.logger.info(`listen... ${address}`);
      })
      .catch((err) => {
        this.logger.error(`failed to listen: ${err}`);
        process.exit(1);
      });
  }

  async destroy(): Promise<void> {
    return this.server
      .close()
      .then(() => {
        this.logger.info('server closed...');
      })
      .catch((err) => {
        this.logger.error(`failed to close: ${err}`);
      });
  }
}
