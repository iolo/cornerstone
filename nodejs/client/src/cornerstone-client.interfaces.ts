import { Logger } from '@day1co/pebbles';
import { BaseBus } from '@day1co/fastbus/lib/fast-bus.interface';

export interface CornerstoneClientInitOpts {
  readonly logger: Logger;
  readonly bus: BaseBus;
}
