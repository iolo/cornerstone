import { CornerstoneClient } from './cornerstone-client';
import { LoggerFactory } from '@day1co/pebbles';
import { BaseBus } from '@day1co/fastbus/lib/fast-bus.interface';

describe('CornerstoneClient', () => {
  describe('execute', () => {
    it('should invoke bus.publish', () => {
      const logger = LoggerFactory.getLogger('test');
      const bus = {
        publish: jest.fn(),
      } as unknown as BaseBus;
      const client = new CornerstoneClient({ logger, bus });
      const taskName = 'task-name';

      const testStub = client.getStub(taskName);
      expect(testStub).toBeInstanceOf(Function);
      client.execute(taskName, '**MESSAGE**');
      expect(bus.publish).toBeCalledWith('topic-cornerstone-task-name', JSON.stringify('**MESSAGE**'), false);
    });
  });

  describe('getStub', () => {
    it('should return function to invoke bus.publish', () => {
      const logger = LoggerFactory.getLogger('test');
      const bus = {
        publish: jest.fn(),
      } as unknown as BaseBus;
      const client = new CornerstoneClient({ logger, bus });
      const taskName = 'task-name';

      const testStub = client.getStub(taskName);
      expect(testStub).toBeInstanceOf(Function);
      testStub('**MESSAGE**');
      expect(bus.publish).toBeCalledWith('topic-cornerstone-task-name', JSON.stringify('**MESSAGE**'), false);
    });
  });

  describe('destroy', () => {
    it('should invoke bus.destroy', () => {
      const logger = LoggerFactory.getLogger('test');
      const bus = {
        destroy: jest.fn(),
      } as unknown as BaseBus;
      const client = new CornerstoneClient({ logger, bus });
      client.destroy();
      expect(bus.destroy).toBeCalled();
    });
  });
});
