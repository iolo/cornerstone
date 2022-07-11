import { CloudSchedulerClient } from '@google-cloud/scheduler';
import { setupScheduler } from './scheduler';

describe('scheduler', () => {
  describe('setupScheduler', () => {
    it('should create scheduler job', async () => {
      CloudSchedulerClient.prototype.createJob = jest.fn().mockResolvedValue(['JOB']);
      expect(
        await setupScheduler({
          projectId: 'PROJECT',
          region: 'REGION',
          jobName: 'JOB',
          topicName: 'TOPIC',
          schedule: 'SCHEDULE',
          timeZone: 'TZ',
        })
      ).toEqual('JOB');
    });
  });
});
