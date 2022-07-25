package com.day1co.cornerstone.task.sample;

import org.junit.jupiter.api.Test;

public class SampleTaskTest {
    @Test
    public void testExecute() {
        final SampleTask task = new SampleTask(new SampleService());
        final SampleMessage message = new SampleMessage();
        task.execute(message);
    }
}
