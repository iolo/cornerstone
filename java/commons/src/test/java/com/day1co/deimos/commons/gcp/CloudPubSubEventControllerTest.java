package com.day1co.cornerstone.commons.gcp;

import com.day1co.cornerstone.commons.DummyTask;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Base64;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.setup.MockMvcBuilders.standaloneSetup;

public class CloudPubSubEventControllerTest {
    DummyTask task = new DummyTask();
    MockMvc mockMvc = standaloneSetup(new CloudPubSubEventController<>(task)).build();

    @Test
    public void testExecuteTask() throws Exception {
        var TEST_MESSAGE = "hello,pubsub" + this.hashCode() + System.currentTimeMillis();
        var body = "{\"message\":{\"data\":\""
                + Base64.getEncoder().encodeToString(("\"" + TEST_MESSAGE + "\"").getBytes())
                + "\"}}";
        this.mockMvc.perform(post("/").contentType(MediaType.APPLICATION_JSON).content(body))
                .andDo(print()).andExpect(status().isAccepted());
        assertThat(task.message).isEqualTo(TEST_MESSAGE);
    }
}
