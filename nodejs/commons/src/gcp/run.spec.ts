import { HttpClient } from '@day1co/pebbles';
import { getRunEndpoint } from './run';

//jest.mock('@day1co/pebbles');

describe('run', () => {
  describe('getRunServiceEndpoint', () => {
    it('should get service endpoint', async () => {
      process.env.K_SERVICE = 'SERVICE';
      HttpClient.prototype.sendGetRequest = jest.fn().mockResolvedValue({ data: { endpoint: 'ENDPOINT' } });
      expect(await getRunEndpoint({ projectId: 'PROJECT_ID', region: 'REGION', accessToken: 'ACCESS_TOKEN' })).toBe(
        'ENDPOINT'
      );
    });
  });
});
