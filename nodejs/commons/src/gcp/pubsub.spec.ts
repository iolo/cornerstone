import { PubSub } from '@google-cloud/pubsub';
import { setupPubSub } from './pubsub';

describe('pubsub', () => {
  describe('setupPubSub', () => {
    it('should create topic and subscription', async () => {
      PubSub.prototype.createTopic = jest.fn().mockResolvedValue(['TOPIC']);
      PubSub.prototype.createSubscription = jest.fn().mockResolvedValue(['SUBSCRIPTION']);
      expect(
        await setupPubSub({
          projectId: 'PROJECT',
          topicName: 'TOPIC',
          subscriptionName: 'SUBSCRIPTION',
          endpoint: 'ENDPOINT',
        })
      ).toEqual(['TOPIC', 'SUBSCRIPTION']);
    });
  });
});
