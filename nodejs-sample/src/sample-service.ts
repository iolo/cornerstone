import { LoggerFactory } from '@day1co/pebbles';

const logger = LoggerFactory.getLogger('cornerstone-nodejs-sample:sample-service');

export class SampleService {
  public message = '';

  async doSomething(message: string): Promise<void> {
    try {
      // TODO: add your code here!
      logger.debug(`message:${message}`);
      this.message = message;
    } catch (e) {
      throw e;
    }
  }
}
