import { SampleTask } from './sample-task';
import { SampleService } from './sample-service';

describe('sample-task', () => {
  it('sample-task', async () => {
    const TEST_MESSAGE = 'hello';
    const service = { doSomething: jest.fn() } as unknown as SampleService;
    const task = new SampleTask(service);
    await task.execute(TEST_MESSAGE);
    expect(service.doSomething).toBeCalledWith(TEST_MESSAGE);
  });
});
