package com.day1co.cornerstone.commons;

import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.setup.MockMvcBuilders.standaloneSetup;

public class TaskControllerTest {
    DummyTask task = new DummyTask();
    MockMvc mockMvc = standaloneSetup(new TaskController<>(task)).build();

    @Test
    public void testPing() throws Exception {
        this.mockMvc.perform(get("/.ping")).andDo(print()).andExpect(status().isOk())
                .andExpect(content().string(containsString("pong!")));
    }

    @Test
    public void testExecuteTask() throws Exception {
        var TEST_MESSAGE = "hello,pubsub" + this.hashCode() + System.currentTimeMillis();
        this.mockMvc.perform(get("/").param("message", "\"" + TEST_MESSAGE + "\""))
                .andDo(print()).andExpect(status().isAccepted());
        assertThat(task.message).isEqualTo(TEST_MESSAGE);
    }
}
