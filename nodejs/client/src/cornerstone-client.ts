import { Logger } from '@day1co/pebbles';
import { BaseBus } from '@day1co/fastbus/lib/fast-bus.interface';
import { CornerstoneClientInitOpts } from './cornerstone-client.interfaces';

// TODO: bus.publish()가 cloud pub/sub이 발급한 messageId를 반환하도록 수정하고,
// messageId를 통해 진행상황/결과 등을 확인/제어할 수 있도록...
// client.addEventListener('onProgress', ({taskName, messageId, progress}) => {...});
// client.addEventListener('onComplete', ({taskName, messageId, result}) => {...});
// client.addEventListener('onError', ({taskName, messageId, error}) => {...});
// client.cancel(messageId);
export class CornerstoneClient {
  readonly logger: Logger;
  readonly bus: BaseBus;

  constructor({ logger, bus }: CornerstoneClientInitOpts) {
    this.logger = logger;
    this.bus = bus;
  }

  execute<T>(taskName: string, message: T): string {
    const topicName = CornerstoneClient.getTopicName(taskName);

    this.bus.publish(topicName, JSON.stringify(message), false);

    this.logger.debug(`cornerstone task ${taskName} was invoked via pub/sub topic ${topicName}: message=%o`, message);

    return 'not-yet-supported';
  }

  getStub(taskName: string): <T>(message: T) => string {
    return <T>(message: T): string => this.execute(taskName, message);
  }

  destroy(): void {
    this.bus.destroy();
  }

  private static getTopicName(taskName: string) {
    return `topic-cornerstone-${taskName}`;
  }
}
