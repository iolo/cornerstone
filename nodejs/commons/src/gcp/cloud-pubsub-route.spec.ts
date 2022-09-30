import type { FastifyReply } from 'fastify';

import { CloudPubSubEventRoute, ExecuteTaskRequest } from './cloud-pubsub-event-route';
import { DummyTask } from '../dummy-task';

describe('cloud-pubsub-event-route', () => {
  describe('executeTask', () => {
    it('should work', (done) => {
      const TEST_MESSAGE = 'hello';
      const task = new DummyTask();
      const route = new CloudPubSubEventRoute(task);
      const request = {
        body: { message: { data: Buffer.from(JSON.stringify(TEST_MESSAGE), 'utf8').toString('base64') } },
      } as unknown as ExecuteTaskRequest;
      const reply = { code: jest.fn(), send: jest.fn() } as unknown as FastifyReply;
      route.executeTask(request, reply).then(() => {
        setTimeout(() => {
          expect(reply.code).toBeCalledWith(202);
          expect(reply.send).toBeCalledWith('ACCEPTED');
          expect(task.message).toBe(TEST_MESSAGE);
          done();
        }, 100);
      });
    });

    it('should fail', (done) => {
      const task = new DummyTask();
      const route = new CloudPubSubEventRoute(task);
      const request = {
        body: { message: { data: Buffer.from('INVALID_JSON', 'utf8').toString('base64') } },
      } as unknown as ExecuteTaskRequest;
      const reply = { code: jest.fn(), send: jest.fn() } as unknown as FastifyReply;
      route.executeTask(request, reply).then(() => {
        setTimeout(() => {
          expect(reply.code).toBeCalledWith(400);
          expect(reply.send).toBeCalledWith('Bad Parameters: INVALID_JSON');
          done();
        }, 100);
      });
    });
  });
});
