import { HttpClient } from '@day1co/pebbles';
import { DummyTask } from '@day1co/cornerstone-commons';

import { Application } from './application';

describe('application', () => {
  it('GET /.ping', async () => {
    process.env.PORT = '8080';
    const task = new DummyTask();
    const app = new Application(task);
    await app.run();
    const client = new HttpClient();
    const res = await client.sendGetRequest<string>('http://localhost:8080/.ping');
    expect(res.status).toBe(200);
    expect(res.data).toBe('pong!');
    await app.destroy();
  });
  it('GET /', async () => {
    const TEST_MESSAGE = 'hello';
    process.env.PORT = '8080';
    const task = new DummyTask();
    const app = new Application(task);
    await app.run();
    const client = new HttpClient();
    const res = await client.sendGetRequest<string>('http://localhost:8080/', {
      params: { message: JSON.stringify(TEST_MESSAGE) },
    });
    expect(res.status).toBe(202);
    expect(res.data).toBe('ACCEPTED');
    app.destroy();
    expect(task.message).toBe(TEST_MESSAGE);
  });
  it('POST /', async () => {
    const TEST_MESSAGE = 'hello';
    process.env.PORT = '8080';
    const task = new DummyTask();
    const app = new Application(task);
    app.run();
    const client = new HttpClient();
    const res = await client.sendPostRequest<string>('http://localhost:8080/', {
      message: { data: Buffer.from(JSON.stringify(TEST_MESSAGE), 'utf8').toString('base64') },
    });
    expect(res.status).toBe(202);
    expect(res.data).toBe('ACCEPTED');
    await app.destroy();
    expect(task.message).toBe(TEST_MESSAGE);
  });
});
