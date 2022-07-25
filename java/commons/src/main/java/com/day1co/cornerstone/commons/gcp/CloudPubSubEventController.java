package com.day1co.cornerstone.commons.gcp;

import com.day1co.cornerstone.commons.Task;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.Base64;

@RestController
public class CloudPubSubEventController<T> {
    private final Task<T> task;

    public CloudPubSubEventController(Task<T> task) {
        this.task = task;
    }

    @PostMapping("/")
    public ResponseEntity<String> executeTask(@RequestBody CloudPubSubEvent event) {
        final CloudPubSubEvent.Message message = event.message;
        if (message == null) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }

        final String data = "".equals(message.data) ? "" :
                new String(Base64.getDecoder().decode(message.data));
        try {
            final ObjectMapper mapper = new ObjectMapper();
            task.execute(mapper.readValue(data, task.getMessageClass()));
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }

        return new ResponseEntity<>(HttpStatus.ACCEPTED);
    }

}
