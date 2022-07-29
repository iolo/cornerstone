import { Client } from "./client";
import { LoggerFactory } from "@day1co/pebbles";
import { BaseBus } from "@day1co/fastbus/lib/fast-bus.interface";
import { BusType, FastBus } from "@day1co/fastbus/lib";

describe("Client", () => {
  describe("execute", () => {
    let bus: BaseBus;

    beforeAll(() => {
      bus = FastBus.create({
        fastBusOpts: {},
        busType: BusType.LOCAL,
      });
    });
    afterAll(() => {
      bus.destroy();
    });

    it("should return requestId", () => {
      bus.publish = jest.fn();
      const logger = LoggerFactory.getLogger("cornerstone-commons:client");
      const client = new Client({ logger, bus });
      const topicName = "topicName";

      const testStub = client.getStub(topicName);
      const requestId = testStub({ message: "message" });
      expect(requestId).toBeDefined();
      expect(bus.publish).toBeCalledWith(
        topicName,
        JSON.stringify({ message: { message: "message" }, requestId }),
        false
      );
    });
  });

  describe("destroy", () => {
    it("should invoke fastbusBackend.destroy", () => {
      const bus = FastBus.create({
        fastBusOpts: {},
        busType: BusType.LOCAL,
      });

      bus.destroy = jest.fn();
      const logger = LoggerFactory.getLogger("cornerstone-commons:client");
      const client = new Client({ logger, bus });
      client.destroy();
      expect(bus.destroy).toBeCalled();
    });
  });
});
