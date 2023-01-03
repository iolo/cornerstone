import { HttpClient, LoggerFactory } from '@day1co/pebbles';
import { DummyTask } from '@day1co/cornerstone-commons';

import { CornerstoneApplication } from './cornerstone-application';

describe('cornerstone-application', () => {
  const logger = LoggerFactory.getLogger('test');
  const task = new DummyTask();
  const app = new CornerstoneApplication({ logger, task });
  const client = new HttpClient(`http://127.0.0.1:${app.port}`);
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
    const res = await client.sendGetRequest<string>('/', {
      params: { message: JSON.stringify('**MESSAGE**') },
    });
    expect(res.status).toBe(202);
    expect(res.data).toBe('ACCEPTED');
    expect(task.message).toBe('**MESSAGE**');
  });
  it('POST /', async () => {
    const res = await client.sendPostRequest<string>('/', {
      message: { data: Buffer.from(JSON.stringify('**MESSAGE**'), 'utf8').toString('base64') },
    });
    expect(res.status).toBe(202);
    expect(res.data).toBe('ACCEPTED');
    expect(task.message).toBe('**MESSAGE**');
  });
});
