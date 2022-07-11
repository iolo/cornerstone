export interface CloudPubSubEvent {
  message: CloudPubSubEventMessage;
}

export interface CloudPubSubEventMessage {
  message_id?: string;
  publish_time?: string;
  data?: string;
}
