import { HttpClient, LoggerFactory } from '@day1co/pebbles';

const logger = LoggerFactory.getLogger('cornerstone-starter-commons-starter');

// cloud run의 기본 포트는 8080, 다른 포트 쓰려면 deploy할때 `--port`옵션 필요
export const ENDPOINT_PORT = 8080;

// cloud pubsub을 통해 메시지가 들어오면 http post 요청이 발생함
// https://cloud.google.com/run/docs/triggering/pubsub-push
export const ENDPOINT_METHOD = 'POST';
export const ENDPOINT_PATH = '/';

// 메시지는 json body의 message 속성에 base64로 인코딩되어 있음
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function parseMessage(body?: any): string {
  return body?.message ? Buffer.from(body?.message, 'base64').toString() : '';
}

export interface GetRunEndpointOptions {
  projectId: string;
  region: string;
  accessToken: string;
}

/**
 * 현재 cloud run 실행중인 서비스의 http endpoint를 조회
 */
export async function getRunEndpoint({ projectId, region, accessToken }: GetRunEndpointOptions) {
  // 현재 실행 중인 서비스 이름
  // cloud run 안에서 실행되면 K_SERVICE 환경변수에 들어있음
  // https://cloud.google.com/run/docs/container-contract#env-vars
  const service = process.env.K_SERVICE;
  if (!service) {
    throw new Error('bad or missing K_SERVICE system env');
  }

  const client = new HttpClient(`https://${region}-run.googleapis.com`);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const res = await client.sendGetRequest<any>(
    `/apis/serving.knative.dev/v1/namespaces/${projectId}/services/${service}`,
    {
      headers: { Authorization: `Bearer ${accessToken}` },
    }
  );
  logger.debug('service info: %o', res);
  const endpoint = res?.data?.endpoint;
  logger.debug('endpoint: %s', endpoint);
  return endpoint;
}
