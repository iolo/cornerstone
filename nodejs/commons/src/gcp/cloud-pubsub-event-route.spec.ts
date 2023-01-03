import type { FastifyReply } from 'fastify';

import { CloudPubSubEventRoute, ExecuteTaskRequest } from './cloud-pubsub-event-route';
import { DummyTask } from '../dummy-task';

import { setTimeout } from 'node:timers/promises';

describe('cloud-pubsub-event-route', () => {
  describe('executeTask', () => {
    it('should work', async () => {
      const TEST_MESSAGE = 'hello';
      const task = new DummyTask();
      const route = new CloudPubSubEventRoute(task);
      const request = {
        body: { message: { data: Buffer.from(JSON.stringify(TEST_MESSAGE), 'utf8').toString('base64') } },
      } as unknown as ExecuteTaskRequest;
      const reply = { code: jest.fn(), send: jest.fn() } as unknown as FastifyReply;
      await route.executeTask(request, reply);
      await setTimeout(100);
      expect(reply.code).toBeCalledWith(202);
      expect(reply.send).toBeCalledWith('ACCEPTED');
      expect(task.message).toBe(TEST_MESSAGE);
    });

    /** @deprecated */
    it('should work with nested message', async () => {
      const TEST_MESSAGE = 'hello';
      const task = new DummyTask();
      const route = new CloudPubSubEventRoute(task);
      const request = {
        body: { message: { data: Buffer.from(JSON.stringify({ message: TEST_MESSAGE }), 'utf8').toString('base64') } },
      } as unknown as ExecuteTaskRequest;
      const reply = { code: jest.fn(), send: jest.fn() } as unknown as FastifyReply;
      await route.executeTask(request, reply);
      await setTimeout(100);
      expect(reply.code).toBeCalledWith(202);
      expect(reply.send).toBeCalledWith('ACCEPTED');
      expect(task.message).toBe(TEST_MESSAGE);
    });

    /** @deprecated */
    it('should work with requestId', async () => {
      const task = new DummyTask();
      const route = new CloudPubSubEventRoute(task);
      const request = {
        body: {
          message: { data: Buffer.from(JSON.stringify({ requestId: '**REQUEST_ID**' }), 'utf8').toString('base64') },
        },
      } as unknown as ExecuteTaskRequest;
      const reply = { code: jest.fn(), send: jest.fn() } as unknown as FastifyReply;
      await route.executeTask(request, reply);
      await setTimeout(100);
      expect(reply.code).toBeCalledWith(202);
      expect(reply.send).toBeCalledWith('ACCEPTED');
      expect(task.message).toBeUndefined();
    });

    it('should fail', async () => {
      const task = new DummyTask();
      const route = new CloudPubSubEventRoute(task);
      const request = {
        body: { message: { data: Buffer.from('INVALID_JSON', 'utf8').toString('base64') } },
      } as unknown as ExecuteTaskRequest;
      const reply = { code: jest.fn(), send: jest.fn() } as unknown as FastifyReply;
      await route.executeTask(request, reply);
      await setTimeout(100);
      expect(reply.code).toBeCalledWith(400);
      expect(reply.send).toBeCalledWith('Bad Parameters: INVALID_JSON');
    });
  });
});
