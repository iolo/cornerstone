import { isAvailable, project, instance } from 'gcp-metadata';
import { getMetadata, getRegionFromZonePath } from './metadata';

jest.mock('gcp-metadata');

describe('metadata', () => {
  describe('getMetadata', () => {
    it('should fetch metadata using gcp-metadata', async () => {
      const mocked_isAvailable = isAvailable as jest.MockedFunction<typeof isAvailable>;
      const mocked_project = project as jest.MockedFunction<typeof project>;
      const mocked_instance = instance as jest.MockedFunction<typeof instance>;
      mocked_isAvailable.mockImplementation(async () => {
        return true;
      });
      mocked_project.mockImplementation(async (options) => {
        if (options === 'project-id') return 'PROJECT_ID';
        throw new Error();
      });
      mocked_instance.mockImplementation(async (options) => {
        if (options === 'zone') return 'projects/FOO/zones/BAR-BAZ-QUX';
        if (options === 'service-accounts/default/token') return { access_token: 'ACCESS_TOKEN' };
        throw new Error();
      });
      expect(await getMetadata()).toEqual({ projectId: 'PROJECT_ID', region: 'BAR-BAZ', accessToken: 'ACCESS_TOKEN' });
    });
  });
  describe('getRegionFromZonePath', () => {
    it('should extract region from zonePath', () => {
      expect(getRegionFromZonePath('projects/FOO/zones/BAR-BAZ-QUX')).toBe('BAR-BAZ');
    });
  });
});
