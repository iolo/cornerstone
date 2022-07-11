package com.day1co.cornerstone.autoconfigure;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties("day1co.cornerstone")
public class cornerstoneProperties {
    public boolean setupOnStart = false;
    public String project = "fastcampus-web-services";
    public String region = "asia-northeast3";
    public String accessToken;
    public String site = "day1";
    public String env = "dev";
    public String name;
    public String service; // "run-cornerstone-${ENV}-${SITE}-${NAME}"
    public String topic; // "topic-cornerstone-${ENV}-${SITE}-${NAME}"
    public String subscription; // "SUBSCRIPTION=sub-cornerstone-${ENV}-${SITE}-${NAME}"
    public String job;
    public String schedule;
    public String timeZone;
}

