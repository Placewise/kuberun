# Kuberun

How many time you had to run long running, resource exhausting command on Kubernetes pod and afterwards it was killed by autoscaling/memory limit or deployment made by someone?

This CLI tool aims to create completely separate pod for those commands without having to manually code its configuration.

Uses `kubectl` inside.

## Status

This tool is in early alpha stage.

## Installation

Dependencies:
* Ruby >= 2.4
* kubectl in `$PATH`

Add this line to your application's Gemfile (preferably in `development` group):

```ruby
gem 'kuberun'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kuberun

## Usage

```
kuberun help
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Boostcom/kuberun. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Kuberun project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Boostcom/kuberun/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2018 Boostcom. See [MIT License](LICENSE.txt) for further details.