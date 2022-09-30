import type { FastifyReply, FastifyRequest } from 'fastify';

import { TaskRoute, ExecuteTaskRequest } from './task-route';
import { DummyTask } from './dummy-task';

describe('task-route', () => {
  describe('executeTask', () => {
    it('should work', (done) => {
      const TEST_MESSAGE = 'hello';
      const task = new DummyTask();
      const route = new TaskRoute(task);
      const request = { query: { message: JSON.stringify(TEST_MESSAGE) } } as unknown as ExecuteTaskRequest;
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
      const route = new TaskRoute(task);
      const request = { query: { message: 'INVALID_JSON' } } as unknown as ExecuteTaskRequest;
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
  describe('ping', () => {
    it('should work', (done) => {
      const task = new DummyTask();
      const route = new TaskRoute(task);
      const request = {} as unknown as FastifyRequest;
      const reply = { code: jest.fn(), send: jest.fn() } as unknown as FastifyReply;
      route.ping(request, reply).then(() => {
        setTimeout(() => {
          expect(reply.code).toBeCalledWith(200);
          expect(reply.send).toBeCalledWith('pong!');
          done();
        }, 100);
      });
    });
  });
});
