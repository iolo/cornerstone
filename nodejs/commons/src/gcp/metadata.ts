import { isAvailable, project, instance } from 'gcp-metadata';
import { LoggerFactory } from '@day1co/pebbles';

const logger = LoggerFactory.getLogger('cornerstone-starter-commons-starter');

export interface Metadata {
  projectId: string;
  region: string;
  accessToken: string;
}

export async function getMetadata(): Promise<Metadata> {
  const isGcpMetadataAvailable = await isAvailable();
  if (!isGcpMetadataAvailable) {
    throw new Error('no gcp metadata available!');
  }
  const projectId = await project('project-id');
  logger.debug('projectId: %s', projectId);
  const zone = await instance('zone');
  logger.debug('zone: %s', zone);
  const region = getRegionFromZonePath(zone);
  logger.debug('region: %s', region);
  const token = await instance('service-accounts/default/token');
  logger.debug('token: %o', token);
  return { projectId, region, accessToken: token?.access_token };
}

const GCP_ZONE_PATH_REGEX = /^projects\/[^/]+\/zones\/(\w+-\w+)-\w+$/;

export function getRegionFromZonePath(zone: string): string {
  const match = GCP_ZONE_PATH_REGEX.exec(zone);
  if (!match) {
    throw new Error(`invalid zone path: ${zone}`);
  }
  return match[1];
}
