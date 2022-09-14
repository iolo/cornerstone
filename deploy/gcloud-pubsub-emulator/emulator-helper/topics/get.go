package topics

// [START pubsub_list_topics]
import (
	"cloud.google.com/go/pubsub"
	"context"
	"fmt"
	"time"
)

func Get(projectID string, topicID string) (*pubsub.Topic, error) {
	// projectID := "my-project-id"
	ctx := context.Background()
	client, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		return nil, fmt.Errorf("pubsub.NewClient: %v", err)
	}

	topic := client.TopicInProject(topicID, projectID)

	time.Sleep(300 * time.Millisecond)
	client.Close()
	return topic, nil
}

// [END pubsub_list_topics]
