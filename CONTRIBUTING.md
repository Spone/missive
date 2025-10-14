# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Spone/missive. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/Spone/missive/blob/main/CODE_OF_CONDUCT.md).

## Testing

Run the test suite with:

```bash
bin/rails test
```

## Get started

- Fork the repository
- Run `bin/setup` to install dependencies
- Create your feature branch (`git checkout -b my-new-feature`)
- Make your changes
- Run the tests `bin/rails test`
- Commit your change, push the branch and create a pull request

## Release

- Update the version number in `version.rb`
- Run `bundle exec rake release`, which will create a git tag for the version
- Push git commits and the created tag
- Push the `.gem` file to [rubygems.org](https://rubygems.org)
