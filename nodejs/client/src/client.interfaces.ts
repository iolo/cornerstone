import { Logger } from '@day1co/pebbles';
import { BaseBus } from '@day1co/fastbus/lib/fast-bus.interface';

/** @deprecated in favor of CornerstoneClientInitOpts */
export interface ClientInitOpts {
  readonly logger: Logger;
  readonly bus: BaseBus;
}
