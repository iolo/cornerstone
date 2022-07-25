package com.day1co.cornerstone.commons.gcp;

import lombok.Builder;
import lombok.Data;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import java.util.function.Consumer;


/**
 * cornerstone task를 실행하기 위한 cloud run & cloud pubsub & cloud scheduler 인프라 설정
 */
public class GcpHelper implements Consumer<GcpHelper.Command> {

    public static final int ENDPOINT_PORT = Run.ENDPOINT_PORT;
    public static final String ENDPOINT_METHOD = Run.ENDPOINT_METHOD;
    public static final String ENDPOINT_PATH = Run.ENDPOINT_PATH;

    @Data
    @Builder
    public static class Command {
        String project; // TODO: get from metadata
        String region; // TODO: get from metadata
        String accessToken; // TODO: get from metadata
        String name;
        String env;
        String site;
        String topic;
        String subscription;
        String job;
        String schedule;
        String timeZone;
    }

    /**
     * GCP 인프라 셋업
     */
    @Override
    public void accept(Command options) {
        var metadataResult = new Metadata(new RestTemplate()).get();

        var project = StringUtils.hasLength(options.project) ? options.project : metadataResult.project;
        var region = StringUtils.hasLength(options.region) ? options.region : metadataResult.region;
        var accessToken = StringUtils.hasLength(options.accessToken) ? options.accessToken : metadataResult.accessToken;

        var runResult = new Run().apply(Run.Query.builder()
                .project(project)
                .region(region)
                .accessToken(accessToken)
                .build());

        var endpoint = runResult.endpoint;

        var topic = StringUtils.hasLength(options.topic) ? options.topic : getTopicName(options.name, options.env, options.site);
        var subscription = StringUtils.hasLength(options.subscription) ? options.subscription : getSubscriptionName(topic);
        new PubSub().accept(PubSub.Command.builder()
                .project(project)
                .topic(topic)
                .subscription(subscription)
                .endpoint(endpoint)
                .build());

        if (StringUtils.hasLength(options.schedule) && StringUtils.hasLength(options.timeZone)) {
            var job = StringUtils.hasLength(options.job) ? options.job : getJobName(topic);
            new Scheduler().accept(Scheduler.Command.builder()
                    .project(project)
                    .region(region)
                    .job(job)
                    .endpoint(endpoint).schedule(options.schedule).timeZone(options.timeZone)
                    .build());
        }
    }

    static String getTopicName(String name, String env, String site) {
        return "TEST_" + name + "_" + env + "_" + site;
    }

    static String getSubscriptionName(String topic) {
        return "TEST_" + topic + "_bus_trigger";
    }

    static String getJobName(String topic) {
        return "TEST_" + topic + "_cron_trigger";
    }
}
