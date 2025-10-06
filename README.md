# Missive

A lightweight Rails toolkit for building newsletter features. Missive provides the primitives for managing newsletters and subscribers, with [Postmark](https://postmarkapp.com/) handling delivery.

## Features

- **Newsletter Management**: Create and organize newsletters within your Rails application
- **Postmark Integration**: Leverage Postmark's reliable email delivery service
- **Rails Native**: Designed to work seamlessly with Rails conventions and ActionMailer
- **Subscriber Management**: Handle your newsletter subscriber lists

## Requirements

- Ruby 2.7 or higher
- A Postmark account with API credentials

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
