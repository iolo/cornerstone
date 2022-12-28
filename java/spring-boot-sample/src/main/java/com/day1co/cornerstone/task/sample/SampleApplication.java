package com.day1co.cornerstone.task.sample;

import com.day1co.cornerstone.commons.Task;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
@SpringBootConfiguration
public class SampleApplication {
    public static void main(String[] args) {
        SpringApplication.run(SampleApplication.class, args);
    }

    @Bean
    Task sampleTask() {
        return new SampleTask(new SampleService());
    }
}
