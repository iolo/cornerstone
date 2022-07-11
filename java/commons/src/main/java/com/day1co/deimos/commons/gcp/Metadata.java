package com.day1co.cornerstone.commons.gcp;

import lombok.Builder;
import lombok.Data;
import lombok.extern.jackson.Jacksonized;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.RequestEntity;
import org.springframework.web.client.RestTemplate;

import java.util.function.Supplier;
import java.util.regex.Pattern;

/**
 * GCE 기본 메타데이터 추출
 */
@Data
@Builder
public class Metadata implements Supplier<Metadata.Result> {

    @Data
    @Builder
    public static class Result {
        String project;
        String region;
        String accessToken;
    }

    private final RestTemplate restTemplate;

    public Metadata(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @Override
    public Result get() {
        var project = getMetadata(PROJECT_ID_PATH, String.class);
        logger.debug("project: {}", project);
        var zone = getMetadata(ZONE_PATH, String.class);
        logger.debug("zone: {}", zone);
        var region = getRegionFromZonePath(zone);
        logger.debug("region: {}", region);
        var token = getMetadata(TOKEN_PATH, TokenResponse.class);
        logger.debug("token: {}", token);
        return Result.builder()
                .project(project)
                .region(getRegionFromZonePath(zone))
                .accessToken(token.access_token)
                .build();
    }

    public <T> T getMetadata(String path, Class<T> responseType) {
        //var restTemplate = new RestTemplate();
        var requestHeaders = new HttpHeaders();
        requestHeaders.set(HEADER_NAME, HEADER_VALUE);
        var request = RequestEntity
                .get(BASE_URL + BASE_PATH + path)
                .headers(requestHeaders)
                .build();
        var response = restTemplate.exchange(request, responseType);
        return response.getBody();
    }

    String getRegionFromZonePath(String zone) {
        var m = GCP_ZONE_PATH_REGEX.matcher(zone);
        if (!m.find()) {
            throw new RuntimeException("invalid zone path: zone=" + zone);
        }
        return m.group(1);
    }

    @Data
    @Jacksonized
    @Builder
    static class TokenResponse {
        String access_token;
    }

    static final String BASE_URL = "http://169.254.169.254";
    //static final String BASE_URL = "http://metadata.google.internal.";
    static final String BASE_PATH = "/computeMetadata/v1";
    static final String PROJECT_ID_PATH = "/project/project-id";
    static final String ZONE_PATH = "/instance/zone";
    static final String TOKEN_PATH = "/instance/service-accounts/default/token";
    static final String HEADER_NAME = "Metadata-Flavor";
    static final String HEADER_VALUE = "Google";

    static final Pattern GCP_ZONE_PATH_REGEX = Pattern.compile("^projects/[^/]+/zones/(\\w+-\\w+)-\\w+$");

    static final Logger logger = LoggerFactory.getLogger(Metadata.class);
}
