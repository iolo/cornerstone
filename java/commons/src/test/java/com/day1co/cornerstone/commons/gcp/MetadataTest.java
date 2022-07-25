package com.day1co.cornerstone.commons.gcp;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.*;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withStatus;

public class MetadataTest {
    @Test
    void testGet() throws Exception {
        var TEST_PROJECT = "fastcampus-web-services";
        var TEST_REGION = "asia-northeast3";
        var TEST_ACCESS_TOKEN = "ACCESS_TOKEN";

        var restTemplate = new RestTemplate();
        var server = MockRestServiceServer.createServer(restTemplate);
        server
                .expect(requestTo(Metadata.BASE_URL + Metadata.BASE_PATH + Metadata.PROJECT_ID_PATH))
                .andExpect(method(HttpMethod.GET))
                .andExpect(header(Metadata.HEADER_NAME, Metadata.HEADER_VALUE))
                .andRespond(
                        withStatus(HttpStatus.OK)
                                .contentType(MediaType.TEXT_PLAIN)
                                .body(TEST_PROJECT)
                );
        server
                .expect(requestTo(Metadata.BASE_URL + Metadata.BASE_PATH + Metadata.ZONE_PATH))
                .andExpect(method(HttpMethod.GET))
                .andExpect(header(Metadata.HEADER_NAME, Metadata.HEADER_VALUE))
                .andRespond(
                        withStatus(HttpStatus.OK)
                                .contentType(MediaType.TEXT_PLAIN)
                                .body("projects/PROJECT/zones/" + TEST_REGION + "-ZONE")
                );
        server
                .expect(requestTo(Metadata.BASE_URL + Metadata.BASE_PATH + Metadata.TOKEN_PATH))
                .andExpect(method(HttpMethod.GET))
                .andExpect(header(Metadata.HEADER_NAME, Metadata.HEADER_VALUE))
                .andRespond(
                        withStatus(HttpStatus.OK)
                                .contentType(MediaType.APPLICATION_JSON)
                                .body("{\"access_token\":\"" + TEST_ACCESS_TOKEN +"\"}")// ObjectMapper().writeValueAsString(Metadata.TokenResponse.builder().access_token(TEST_ACCESS_TOKEN).build()))
                );

        var metadata = new Metadata(restTemplate);
        var result = metadata.get();
        assertThat(result.project).isEqualTo(TEST_PROJECT);
        assertThat(result.region).isEqualTo(TEST_REGION);
        assertThat(result.accessToken).isEqualTo(TEST_ACCESS_TOKEN);
    }
}
