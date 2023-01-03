import { CornerstoneClient } from '@day1co/cornerstone-client';
import { LoggerFactory } from '@day1co/pebbles';
import { FastBus, BusType } from '@day1co/fastbus';

interface SampleService {
  (message: string): void;
}

interface SampleClientOpts {
  sampleStub: SampleService;
}

export class SampleClient {
  readonly sampleStub: SampleService;

  constructor({ sampleStub }: SampleClientOpts) {
    this.sampleStub = sampleStub;
  }

  run() {
    this.sampleStub('hello,world!');
  }
}
