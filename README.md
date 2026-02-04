# Missive

A lightweight Rails toolkit for building newsletter features. Missive provides the primitives for managing newsletters and subscribers, with [Postmark](https://postmarkapp.com/) handling delivery.

## Overview

### Features

- **Newsletter Management**: Create and organize newsletters within your Rails application
- **Postmark Integration**: Leverage Postmark's reliable email delivery service
- **Rails Native**: Designed to work seamlessly with Rails conventions and ActionMailer
- **Subscriber Management**: Handle your newsletter subscriber lists

### Scope

#### Goals

- Rely on Postmark as much as possible, integrate with webhooks, send through Postmark API (not SMTP).
- Provide a way to compose messages that include content from the host app models.

#### Non-goals

- Integrate with other sending services.
- Send transactional emails or email sequences: Missive focuses on newsletters.
- Provide ready-made subscription forms: subscription management is the responsibility of the host app.
- Multi-tenancy: Missive is designed for a single Rails app and domain.

## Concepts

### Models

- `Sender` is an identity used to send messages, optionally associated with a `User` from the host app. It has a corresponding [Sender Signature](https://postmarkapp.com/developer/api/signatures-api) in Postmark.
- `Subscriber` is a person who have opted in to receiving emails or have been added manually, optionally associated with a `User` from the host app.
- `Subscription` is the relation between a subscriber and a list.
- `List` is a list of subscribers. It uses a specific [Message Stream](https://postmarkapp.com/developer/api/message-streams-api) to send messages through Postmark.
- `Message` is an email sent to subscribers of a given list.
- `Dispatch` is the relation between a subscriber and a message (ie. when a `Message` is sent, it's dispatched to all subscribers). It's called [Email](https://postmarkapp.com/developer/api/email-api) in Postmark.

## Requirements

- Rails 8.0 or higher
- A Postmark account with API credentials

### Dependencies

- Official [postmark](https://github.com/activecampaign/postmark-gem) gem
- [time_for_a_boolean](https://github.com/calebhearth/time_for_a_boolean) to back boolean concepts (`sent`, `delivered`, `open`, ...) with timestamps
- [rails-pattern_matching](https://github.com/kddnewton/rails-pattern_matching) to use pattern matching when processing incoming webhooks

## Usage

### Setup

```bash
bundle add missive
```

Install the migrations:

```bash
rails generate missive:install
```

### Configuration

Missive uses the same configuration as `postmark-rails`. Please follow the [`postmark-rails` configuration instructions](https://github.com/ActiveCampaign/postmark-rails?tab=readme-ov-file#installation) to set up your Postmark API credentials.

### Quick start

#### Connect the host app `User` model (optional)

The host app `User` can be associated to a `Missive::Subscriber` and/or a `Missive::Sender`, using the `Missive::User` concern.

```rb
class User < ApplicationRecord
  include Missive::User
end
```

The concerns can also be included separately, which is useful if `User` needs to be implemented as a `Sender` or `Subscriber` only.

```rb
class User < ApplicationRecord
  include Missive::UserAsSender
  include Missive::UserAsSubscriber
end
```

This is equivalent to:

```rb
class User < ApplicationRecord
  # Missive::UserAsSender
  has_one :missive_sender # ...
  has_many :missive_sent_dispatches # ...
  has_many :missive_sent_lists # ...
  has_many :missive_sent_messages # ...

  def init_sender(attributes = {});
    # ...
  end

  # Missive::UserAsSubscriber
  has_one :missive_subscriber # ...
  has_many :missive_dispatches # ...
  has_many :missive_subscriptions # ...
  has_many :missive_subscribed_lists # ...
  has_many :missive_unsubscribed_lists # ...

  def init_subscriber(attributes = {})
    # ...
  end
end
```

#### Customizing association names

By default, association names are prefixed with `missive_` to avoid collisions with existing associations. If you want to use shorter names (e.g., `sender` instead of `missive_sender`), you can customize them using the `.with` method:

```rb
class User < ApplicationRecord
  include Missive::User.with(
    sender: {
      sender: :sender,
      sent_dispatches: :sent_dispatches,
      sent_lists: :sent_lists,
      sent_messages: :sent_messages
    },
    subscriber: {
      subscriber: :subscriber,
      dispatches: :dispatches,
      subscriptions: :subscriptions,
      subscribed_lists: :subscribed_lists,
      unsubscribed_lists: :unsubscribed_lists
    }
  )
end
```

Or, if including the concerns separately:

```rb
class User < ApplicationRecord
  include Missive::UserAsSender.with(
    sender: :sender,
    sent_dispatches: :sent_dispatches,
    sent_lists: :sent_lists,
    sent_messages: :sent_messages
  )

  include Missive::UserAsSubscriber.with(
    subscriber: :subscriber,
    dispatches: :dispatches,
    subscriptions: :subscriptions,
    subscribed_lists: :subscribed_lists,
    unsubscribed_lists: :unsubscribed_lists
  )
end
```

You only need to customize the associations you want to rename - any unconfigured associations will use their default `missive_` prefixed names.

#### Manage subscriptions

```rb
user = User.first
list = Missive::List.first

# Make sure the User has an associated Missive::Subscriber:
# - if one exists with the same email, associate it
# - else create a new subscriber with the same email
user.init_subscriber

# List the subscriptions
user.missive_subscriptions # returns a `Missive::Subscription` collection

# List the (un)subscribed lists
user.missive_subscribed_lists # returns a `Missive::List` collection
user.missive_unsubscribed_lists # returns a `Missive::List` collection

# Subscribe to an existing Missive::List
user.missive_subscriber.subscriptions.create!(list:)

# Unsubscribe from the list
user.missive_subscriptions.find_by(list:).suppress!(reason: :manual_suppression)
```

#### Manage senders

```rb
user = User.where(admin: true).first
list = Missive::List.first

# Make sure the User has an associated Missive::Sender:
# - if one exists with the same email, associate it
# - else create a new sender with the same email
# then assign them the provided name
user.init_sender(name: user.full_name)

# Make them the default sender for a list
user.missive_sent_lists << list
```

#### Manage lists

```rb
# Create a new list
list = Missive::List.create!(name: "My newsletter")

# Choose a specific Message Stream to send messages for this list
list.update!(postmark_message_stream_id: "bulk")

# Get available lists
Missive::List.all

# Get list stats
list.subscriptions_count # how many people subscribe or unsubscribe to this list?
list.messages_count # how many messages have been created in this list?
```

> [!WARNING]
> **Everything below is currently being developed and is not yet ready for use.**

#### Manage messages

```rb
# Create a new message in a list
list.create_message!(subject: "Hello world!")

# TODO: add message content

# Send the message to the list
message.send!
```

### Sending with Postmark Bulk API

Missive leverages the [Bulk Email API](https://postmarkapp.com/developer/api/bulk-email) endpoints.

> [!WARNING]
> This endpoint is available to early access customers only. You need to request access. [Learn more](https://postmarkapp.com/support/article/1311-the-early-access-program-for-the-new-bulk-api)

The official [postmark gem](https://github.com/ActiveCampaign/postmark-gem) does not support these endpoints yet, so Missive ships with `Stamp`, a thin layer over Postmark's official library.

#### Sending a message in bulk

You can pass a Hash that matches the body expected by the API.

```rb
Missive::Stamp::ApiClient.deliver_in_bulk(
  from: "sender@example.com",
  subject: "Hello {{name}}",
  html_body: "<p>Hello {{name}}</p>",
  text_body: "Hello {{name}}",
  messages: [
    {
      to: "jane.doe@example.com",
      template_model: {name: "Jane"}
    },
    {
      to: "john.doe@example.com",
      template_model: {name: "John"}
    }
  ]
)
```

You can also pass a `Mail` instance and an Array of recipients.

```rb
mail = Mail.new do
  from "sender@example.com"
  subject "Hello {{name}}"
  body: "Hello {{name}}"
end

Missive::Stamp::ApiClient.deliver_message_in_bulk(
  mail,
  [
    {
      to: "jane.doe@example.com",
      template_model: {name: "Jane"}
    },
    {
      to: "john.doe@example.com",
      template_model: {name: "John"}
    }
  ]
)
```

#### Getting the status of a bulk API request

```rb
Missive::Stamp::ApiClient.get_bulk_status("f24af63c-533d-4b7a-ad65-4a7b3202d3a7")
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Missive project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Spone/missive/blob/main/CODE_OF_CONDUCT.md).
