import { Logger, StringUtil } from "@day1co/pebbles";
import { BaseBus } from "@day1co/fastbus/lib/fast-bus.interface";
import type { PublishingMessage } from "./message";
import { ClientInitOpts } from "./client.interfaces";

export class Client {
  readonly bus: BaseBus;
  readonly logger: Logger;

  constructor({ logger, bus }: ClientInitOpts) {
    this.logger = logger;
    this.bus = bus;
  }

  /**
   * @param taskName
   * @param environment
   * @param site
   */
  getStub(
    taskName: string,
    environment: string,
    site: string
  ): <T>(message: T) => string {
    return <T>(message: T): string => {
      const topicName = Client.getTopicName(taskName, environment, site);
      const requestId = `${topicName}:${StringUtil.getNonce(32, 36)}`;

      const publishingMessage: PublishingMessage<T> = {
        message,
        requestId,
      };

      const publishingMessageString = JSON.stringify(publishingMessage);
      this.bus.publish(topicName, publishingMessageString, false);

      this.logger.info(`cornerstone task requested: ${requestId}`);
      this.logger.debug(
        "cornerstone task requested with message: %s",
        publishingMessageString
      );

      return requestId;
    };
  }

  destroy(): void {
    this.bus.destroy();
  }

  private static shortenEnvName(environment: string) {
    switch (environment) {
      case "development":
        return "dev";
      case "production":
        return "prod";
      case "staging":
        return "stg";
      default:
        return environment;
    }
  }

  private static getTopicName(
    taskName: string,
    environment: string,
    site: string
  ) {
    return `topic-cs-${Client.shortenEnvName(environment)}-${site}-${taskName}`;
  }
}
