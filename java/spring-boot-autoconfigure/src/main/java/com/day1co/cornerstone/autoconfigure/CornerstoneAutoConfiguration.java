package com.day1co.cornerstone.autoconfigure;

import com.day1co.cornerstone.commons.Task;
import com.day1co.cornerstone.commons.TaskController;
import com.day1co.cornerstone.commons.gcp.CloudPubSubEventController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.AutoConfigureAfter;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.boot.autoconfigure.web.servlet.WebMvcAutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@AutoConfigureAfter(WebMvcAutoConfiguration.class)
@ConditionalOnClass(Task.class)
@EnableConfigurationProperties(CornerstoneProperties.class)
public class CornerstoneAutoConfiguration {
    final CornerstoneProperties properties;

    public CornerstoneAutoConfiguration(CornerstoneProperties properties) {
        this.properties = properties;
    }

    @Bean
    public <T> TaskController<T> taskController(Task<T> task) {
        return new TaskController<T>(task);
    }

    @Bean
    public <T> CloudPubSubEventController<T> cloudPubSubEventController(Task<T> task) {
        return new CloudPubSubEventController<T>(task);
    }
}

