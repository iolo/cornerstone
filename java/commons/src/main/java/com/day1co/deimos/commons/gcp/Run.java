package com.day1co.cornerstone.commons.gcp;

import lombok.Builder;
import lombok.Data;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.RequestEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import java.util.function.Function;

public class Run implements Function<Run.Query, Run.Result> {
    @Data
    @Builder
    public static class Query {
        String project;
        String region;
        String accessToken;
    }

    @Data
    @Builder
    public static class Result {
        String endpoint;
    }

    /**
     * 현재 cloud run 실행중인 서비스의 http endpoint를 조회
     */
    @Override
    public Result apply(Query query) {
        var service = System.getenv(CLOUD_RUN_SERVICE_ENV_NAME);
        if (!StringUtils.hasLength(service)) {
            throw new RuntimeException("bad or missing " + CLOUD_RUN_SERVICE_ENV_NAME + " system env");
        }
        try {
            var restTemplate = new RestTemplate();
            var requestHeaders = new HttpHeaders();
            requestHeaders.setBearerAuth(query.accessToken);
            var request = RequestEntity
                    .get(GET_SERVICE_ENDPOINT_URL_TEMPLATE, query.region, query.project, service)
                    .headers(requestHeaders)
                    .build();
            var response = restTemplate.exchange(request, Result.class);
            var result = response.getBody();
            logger.info("service endpoint: {} -> {}", service, result);
            return result;
        } catch (Throwable t) {
            throw new RuntimeException("failed to get service endpoint: service=" + service, t);
        }
    }

    private static final Logger logger = LoggerFactory.getLogger(Run.class);

    // cloud run의 기본 포트는 8080, 다른 포트 쓰려면 deploy할때 `--port`옵션 필요
    public static final int ENDPOINT_PORT = 8080;

    // cloud pubsub을 통해 메시지가 들어오면 http post 요청이 발생함
    // https://cloud.google.com/run/docs/triggering/pubsub-push
    public static final String ENDPOINT_METHOD = "POST";

    public static final String ENDPOINT_PATH = "/";

    // 현재 실행 중인 서비스 이름
    // cloud run 안에서 실행되면 K_SERVICE 환경변수에 들어있음
    // https://cloud.google.com/run/docs/container-contract#env-vars
    public static final String CLOUD_RUN_SERVICE_ENV_NAME = "K_SERVICE";


    // $ gcloud run services describe ${SERVICE} --region=${REGION} --project=${PROJECT}
    public static final String GET_SERVICE_ENDPOINT_URL_TEMPLATE = "https://${region}-run.googleapis.com/apis/serving.knative.dev/v1/namespaces/${project}/services/${service}";

}
