package com.day1co.cornerstone.commons;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TaskController<T> {
    private final Task<T> task;

    public TaskController(Task<T> task) {
        this.task = task;
    }

    @GetMapping("/")
    public ResponseEntity<String> executeTask(@RequestParam("message") String message) {
        try {
            final ObjectMapper mapper = new ObjectMapper();
            task.execute(mapper.readValue(message, task.getMessageClass()));
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        return new ResponseEntity<>(HttpStatus.ACCEPTED);
    }

    @GetMapping("/.ping")
    public String ping() {
        return "pong!";
    }

}

