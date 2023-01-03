import { CornerstoneApplication } from '@day1co/cornerstone-starter';
import { LoggerFactory } from '@day1co/pebbles';

import { SampleService } from './sample-service';
import { SampleTask } from './sample-task';

const logger = LoggerFactory.getLogger('cornerstone:sample:server');
const service = new SampleService();
const task = new SampleTask(service);
const app = new CornerstoneApplication({ logger, task });

app.run();
