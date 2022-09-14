package topics

// [START pubsub_list_topics]
import (
	"cloud.google.com/go/pubsub"
	"context"
	"fmt"
)

func Get(projectID string, topicID string) (*pubsub.Topic, error) {
	// projectID := "my-project-id"
	ctx := context.Background()
	client, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		return nil, fmt.Errorf("pubsub.NewClient: %v", err)
	}
	defer client.Close()

	topic := client.TopicInProject(topicID, projectID)
	return topic, nil
}

// [END pubsub_list_topics]
