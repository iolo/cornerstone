package com.day1co.cornerstone.commons.gcp;

import com.google.cloud.scheduler.v1.*;
import com.google.protobuf.ByteString;
import lombok.Builder;
import lombok.Data;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.function.Consumer;

public class Scheduler implements Consumer<Scheduler.Command> {
    private static final Logger logger = LoggerFactory.getLogger(Scheduler.class);

    @Data
    @Builder
    public static class Command {
        public String project;
        public String region;
        public String job;
        public String endpoint;
        public String schedule;
        public String timeZone;
    }

    /**
     * 정해진 일정에 따라 토픽에 메시지를 전송할 cloud scheduler job 생성
     */
    @Override
    public void accept(Command command) {
        try (var cloudSchedulerClient = CloudSchedulerClient.create()) {
            var parent = LocationName.of(command.project, command.region).toString();
            // $ gcloud scheduler jobs create pubsub myjob
            // --schedule "0 1 * * 0"
            // --topic cron-topic
            // --message-body "Hello"
            // var pubsubTarget = PubsubTarget.newBuilder()
            //        .setTopicName(command.topic)
            //        .setData(ByteString.EMPTY)
            //        .build();
            // $ gcloud scheduler jobs create http test-job --schedule "5 * * * *"
            // --http-method=HTTP-METHOD
            // --uri=SERVICE-URL
            // --body
            var httpTarget = HttpTarget.newBuilder()
                    .setUri(command.endpoint)
                    .setHttpMethod(HttpMethod.POST)
                    .setBody(ByteString.EMPTY) // JSON.stringify({ message: Buffer.from(message).toString('base64') }),
                    .build();
            var job = Job.newBuilder()
                    .setName(command.job)
                    //.setPubsubTarget(pubsubTarget)
                    .setHttpTarget(httpTarget)
                    .setSchedule(command.schedule)
                    .setTimeZone(command.timeZone)
                    .build();
            var request = CreateJobRequest.newBuilder()
                    .setParent(parent)
                    .setJob(job)
                    .build();
            var result = cloudSchedulerClient.createJob(request);
            logger.info("scheduler job created: {}", result);
        } catch (Throwable t) {
            logger.warn("**ignore** failed to create scheduler job:" + command.job, t);
        }
    }
}
