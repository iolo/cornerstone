import { CornerstoneClient } from '@day1co/cornerstone-client';
import { LoggerFactory } from '@day1co/pebbles';
import { FastBus, BusType } from '@day1co/fastbus';
import { SampleClient } from './sample-client';

export class SampleContext {
  getSampleClient() {
    const taskName = 'day1-development-nodejs-sample';
    const sampleStub = this.getCornerstoneClient().getStub(taskName);
    return new SampleClient({ sampleStub });
  }
  getCornerstoneClient() {
    return new CornerstoneClient({ logger: this.getLogger(), bus: this.getBus() });
  }
  getLogger() {
    return LoggerFactory.getLogger('cornerstone:sample:client');
  }
  getBus() {
    return FastBus.create({ fastBusOpts: { clientConfig: { projectId: 'day1-dev' } }, busType: BusType.CLOUD_PUBSUB });
  }
}
