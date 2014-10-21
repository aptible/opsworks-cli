# ![](https://raw.github.com/aptible/straptible/master/lib/straptible/rails/templates/public.api/icon-60px.png) OpsWorks::CLI

[![Gem Version](https://badge.fury.io/rb/opsworks-cli.png)](https://rubygems.org/gems/opsworks-cli)
[![Build Status](https://travis-ci.org/aptible/opsworks-cli.png?branch=master)](https://travis-ci.org/aptible/opsworks-cli)
[![Dependency Status](https://gemnasium.com/aptible/opsworks-cli.png)](https://gemnasium.com/aptible/opsworks-cli)

An alternative CLI for Amazon OpsWorks, focused on managing a large number of similarly provisioned stacks.

## Installation

Install the gem:

    gem install 'opsworks-cli'

## Configuration

The gem expects to have access to your AWS access key ID and secret access key. You can configure this in either of two ways. First, you may set the following environment variables:

    export AWS_ACCESS_KEY_ID=...
    export AWS_SECRET_ACCESS_KEY=...

If you're on OS X, you may also use the [aws-keychain-util](https://github.com/zwily/aws-keychain-util) to password-protect these credentials within the OS X Keychain. To do this, follow the instructions in the gem's README:

    gem install aws-keychain-util
    aws-creds init
    aws-creds add

When you add credentials, make sure to name the account `default`.

## Usage

```
$ opsworks help
Commands:
  opsworks deploy [--stack STACK] APP   # Deploy an OpsWorks app
  opsworks exec [--stack STACK] RECIPE  # Execute a Chef recipe
  opsworks status [--stack STACK] APP   # Display the most recent deployment of an app
  opsworks update [--stack STACK]       # Update OpsWorks custom cookbooks
  opsworks version                      # Print OpsWorks CLI version
```

## Contributing

1. Fork the project.
1. Commit your changes, with specs.
1. Ensure that your code passes specs (`rake spec`) and meets Aptible's Ruby style guide (`rake rubocop`).
1. Create a new pull request on GitHub.

## Copyright and License

MIT License, see [LICENSE](LICENSE.md) for details.

Copyright (c) 2014 [Aptible](https://www.aptible.com), Frank Macreery, and contributors.

[<img src="https://s.gravatar.com/avatar/f7790b867ae619ae0496460aa28c5861?s=60" style="border-radius: 50%;" alt="@fancyremarker" />](https://github.com/fancyremarker)
