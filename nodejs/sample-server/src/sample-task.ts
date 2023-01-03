import { LoggerFactory } from '@day1co/pebbles';
import type { Task } from '@day1co/cornerstone-commons';

import { SampleService } from './sample-service';

const logger = LoggerFactory.getLogger('cornerstone-nodejs-sample:sample-task');

export class SampleTask implements Task<string> {
  constructor(readonly sampleService: SampleService) {}

  async execute(message: string): Promise<void> {
    logger.info(`message:${message}`);
    try {
      this.sampleService.doSomething(message);
    } catch (e) {
      throw e;
    }
  }
}
