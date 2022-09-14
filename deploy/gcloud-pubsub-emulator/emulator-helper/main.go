package main

import (
	"fmt"
	"github.com/alexflint/go-arg"
	"github.com/day1co/cornerstone-tasks/pubsub-emulator-helper/lib"
	"github.com/day1co/cornerstone-tasks/pubsub-emulator-helper/subscriptions"
	"github.com/day1co/cornerstone-tasks/pubsub-emulator-helper/topics"
	"os"
	"time"
)

func main() {
	// Parse Arguments
	args := &lib.Args
	arg.MustParse(args)

	// Run on Emulator Only
	if os.Getenv("PUBSUB_EMULATOR_HOST") == "" {
		fmt.Println("PUBSUB_EMULATOR_HOST is not set")
		os.Exit(1)
	}

	projectID := os.Getenv("PUBSUB_PROJECT_ID")
	fmt.Println("Project ID: ", projectID)
	if projectID == "" {
		projectID = args.ProjectID
	}
	if projectID == "" {
		fmt.Println("Project ID is not set")
		os.Exit(1)
	}

	switch {
	case args.TopicSubCommand != nil:
		switch {
		case args.TopicSubCommand.CreateTopic != nil:
			topicID := args.TopicSubCommand.CreateTopic.TopicID
			topics.Create(os.Stdout, projectID, topicID)
			fmt.Printf("Topic created")
		case args.TopicSubCommand.ListTopic != nil:
			list, err := topics.List(projectID)
			if err != nil {
				fmt.Println("Error: ", err)
				os.Exit(1)
			}

			// for loop to print list
			for _, topic := range list {
				fmt.Println("List of Topics:")
				fmt.Println(topic)
			}
		case args.TopicSubCommand.PublishMessage != nil:
			topicID := args.TopicSubCommand.PublishMessage.TopicID
			message := args.TopicSubCommand.PublishMessage.Message

			// encode message with base64
			//encodedMessage := base64.StdEncoding.EncodeToString([]byte(message))
			//fmt.Println("Encoded Message: ", encodedMessage)
			topics.Publish(os.Stdout, projectID, topicID, message)
			time.Sleep(2 * time.Second)
		}

	case args.SubscriptionSubCommand != nil:
		topicID := args.SubscriptionSubCommand.CreatePushSubscription.TopicID
		subscriptionID := args.SubscriptionSubCommand.CreatePushSubscription.SubscriptionID
		endpoint := args.SubscriptionSubCommand.CreatePushSubscription.Endpoint

		topic, err := topics.Get(projectID, topicID)
		if err != nil {
			fmt.Printf("Error getting topic: %v", err)
			os.Exit(1)
		}

		subscriptions.CreateWithEndpoint(os.Stdout, projectID, subscriptionID, topic, endpoint)

	default:
		fmt.Printf("No command specified")
	}
}
