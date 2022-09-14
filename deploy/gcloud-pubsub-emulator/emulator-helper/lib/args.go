package lib

// create struct for topics

type CreateTopic struct {
	TopicID string `arg:"positional,required" help:"abc""`
}

type ListTopic struct {
}

type CreatePushSubscription struct {
	SubscriptionID string `arg:"positional,required"`
	Endpoint       string `arg:"positional,required"`
	TopicID        string `arg:"-t"`
}

type PublishMessage struct {
	TopicID string `arg:"positional,required"`
	Message string `arg:"positional,required" help:"Plain data"`
}

type TopicSubCommand struct {
	CreateTopic    *CreateTopic    `arg:"subcommand:create" help:"create a topic"`
	ListTopic      *ListTopic      `arg:"subcommand:list" help:"list topics"`
	PublishMessage *PublishMessage `arg:"subcommand:publish" help:"publish a message"`
}

type SubscriptionSubCommand struct {
	CreatePushSubscription *CreatePushSubscription `arg:"subcommand:create-push"`
}

var Args struct {
	TopicSubCommand        *TopicSubCommand        `arg:"subcommand:topic" help:"topic subcommand (create, list, publish)"`
	SubscriptionSubCommand *SubscriptionSubCommand `arg:"subcommand:sub" help:"subscription command (create-push)"`
	ProjectID              string                  `arg:"-p" help:"Project ID"` // Global
}
