export interface Message {
  message_id?: string;
  publish_time?: string;
  data?: string;
}

export interface CloudPubSubEvent {
  message: Message;
}

export function isCloudPubSubEvent(event: CloudPubSubEvent): event is CloudPubSubEvent {
  return typeof event === 'object' && typeof event.message === 'object' && typeof event.message.message_id === 'string';
}
