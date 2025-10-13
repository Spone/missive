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

## Installation

```bash
bundle add missive
```

## Configuration

Missive uses the same configuration as postmark-rails. Please follow the [postmark-rails configuration instructions](https://github.com/ActiveCampaign/postmark-rails?tab=readme-ov-file#installation) to set up your Postmark API credentials.

## Usage

> Work in progress

## Testing

Run the test suite with:

```bash
bin/rails test
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Spone/missive. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/Spone/missive/blob/main/CODE_OF_CONDUCT.md).

### Get started

- Fork the repository
- Run `bin/setup` to install dependencies
- Create your feature branch (`git checkout -b my-new-feature`)
- Make your changes
- Run the tests `bin/rails test`
- Commit your change, push the branch and create a pull request

### Release

- Update the version number in `version.rb`
- Run `bundle exec rake release`, which will create a git tag for the version
- Push git commits and the created tag
- Push the `.gem` file to [rubygems.org](https://rubygems.org)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Missive project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Spone/missive/blob/main/CODE_OF_CONDUCT.md).
