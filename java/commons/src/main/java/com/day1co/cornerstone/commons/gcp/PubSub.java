package com.day1co.cornerstone.commons.gcp;

import com.google.cloud.pubsub.v1.SubscriptionAdminClient;
import com.google.cloud.pubsub.v1.TopicAdminClient;
import com.google.pubsub.v1.PushConfig;
import com.google.pubsub.v1.SubscriptionName;
import com.google.pubsub.v1.TopicName;
import lombok.Builder;
import lombok.Data;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.function.Consumer;

public class PubSub implements Consumer<PubSub.Command> {
    private static final Logger logger = LoggerFactory.getLogger(PubSub.class);

    @Data
    @Builder
    public static class Command {
        String project;
        String topic;
        String subscription;
        String endpoint;
    }

    /**
     * 메시지를 수신하면 cloud run service를 실행하는 cloud pubsub topic 설정
     */
    @Override
    public void accept(Command command) {
        // 기존 구독 삭제
        // $ gcloud pubsub subscriptions delete TOPIC
        //await pubsub.subscription(command.subscription).delete();
        //logger.debug('subscription deleted: %o', command.subscription);

        // 기존 토픽 삭제
        // $ gcloud pubsub topics delete TOPIC
        //await pubsub.topic(command.topic).delete();
        //logger.debug('topic deleted: %o', command.topic);

        // 토픽 등록
        // $ gcloud pubsub topics create TOPIC-NAME
        try (var topicAdminClient = TopicAdminClient.create()) {
            var topicName = TopicName.of(command.project, command.topic);
            topicAdminClient.createTopic(topicName);
            logger.info("pubsub topic created: " + command.topic);
        } catch (Throwable t) {
            logger.warn("**ignore** failed to create pubsub topic:" + command.topic, t);
        }

        // 구독 등록
        // 토픽으로 전송된 메시지를 수신해서 cloud run http endpoint 전달
        // $ gcloud pubsub subscriptions create SUBSCRIPTION
        // --topic TOPIC
        // --push-endpoint=ENDPOINT
        try (var subscriptionAdminClient = SubscriptionAdminClient.create()) {
            var topicName = TopicName.of(command.project, command.topic);
            var subscriptionName = SubscriptionName.of(command.project, command.subscription);
            var pushConfig = PushConfig.newBuilder().setPushEndpoint(command.endpoint).build();
            subscriptionAdminClient.createSubscription(subscriptionName, topicName, pushConfig, 10);
            logger.info("pubsub subscription created: " + command.subscription);
        } catch (Throwable t) {
            logger.warn("**ignore** failed to create pubsub subscription:" + command.subscription, t);
        }
    }

}
