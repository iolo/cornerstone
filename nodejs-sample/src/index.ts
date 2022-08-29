import { LoggerFactory } from '@day1co/pebbles';
import { Application } from '@day1co/cornerstone-starter';

import { SampleService } from './sample-service';
import { SampleTask } from './sample-task';

const logger = LoggerFactory.getLogger('cornerstone-nodejs-sample');
const service = new SampleService();
const task = new SampleTask(service);
const app = new Application(task);
app.run();
