import { SampleService } from './sample-service';

describe('sample-service', () => {
  it('should work', async () => {
    const TEST_MESSAGE = 'hello';
    const service = new SampleService();
    await service.doSomething(TEST_MESSAGE);
    expect(service.message).toBe(TEST_MESSAGE);
  });
});
