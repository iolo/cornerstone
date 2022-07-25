package com.day1co.cornerstone.task.sample;

import com.day1co.cornerstone.commons.Task;
import com.day1co.cornerstone.commons.TaskException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SampleTask implements Task<SampleMessage> {
    private static final Logger LOGGER = LoggerFactory.getLogger(SampleTask.class);
    private final SampleService sampleService;

    public SampleTask(SampleService watermark) {
        this.sampleService = watermark;
    }

    @Override
    public Class<SampleMessage> getMessageClass() {
        return SampleMessage.class;
    }

    @Override
    public void execute(SampleMessage message) {
        if (LOGGER.isDebugEnabled()) {
            LOGGER.debug("message: {}", message);
        }
        try {
            sampleService.doSomething();
        } catch (Throwable t) {
            throw new TaskException(t);
        }
    }

}
