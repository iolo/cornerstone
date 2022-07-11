package com.day1co.cornerstone.commons.gcp;

import lombok.Data;

@Data
public class CloudPubSubEvent {

    public Message message;

    @Data
    public static class Message {
        public String messageId;
        public String publishTime;
        public String data;
    }
}
