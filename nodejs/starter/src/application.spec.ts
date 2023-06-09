import { HttpClient } from '@day1co/pebbles';
import { DummyTask } from '@day1co/cornerstone-commons';

import { Application } from './application';

describe('application', () => {
  process.env.PORT = '8080';
  const task = new DummyTask();
  const app = new Application(task);
  const client = new HttpClient('http://127.0.0.1:8080');
  beforeAll(async () => {
    await app.run();
  });
  afterAll(async () => {
    await app.destroy();
  });
  it('GET /.ping', async () => {
    const res = await client.sendGetRequest<string>('/.ping');
    expect(res.status).toBe(200);
    expect(res.data).toBe('pong!');
  });
  it('GET /', async () => {
    const TEST_MESSAGE = 'hello';
    const res = await client.sendGetRequest<string>('/', {
      params: { message: JSON.stringify(TEST_MESSAGE) },
    });
    expect(res.status).toBe(202);
    expect(res.data).toBe('ACCEPTED');
    expect(task.message).toBe(TEST_MESSAGE);
  });
  it('POST /', async () => {
    const TEST_MESSAGE = 'hello';
    const res = await client.sendPostRequest<string>('/', {
      message: { data: Buffer.from(JSON.stringify(TEST_MESSAGE), 'utf8').toString('base64') },
    });
    expect(res.status).toBe(202);
    expect(res.data).toBe('ACCEPTED');
    expect(task.message).toBe(TEST_MESSAGE);
  });
});
