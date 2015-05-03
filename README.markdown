# XMPP Notifications Plugin for Redmine

This plugin is intended to provide basic integration with XMPP messenger (Jabber).
Following actions will result in notifications to Jabber:

- Create and update issues

## Installation

Run following commands:

```ShellSession
cd /path/to/redmine
git clone --branch v1.1.0 https://github.com/frost-nzcr4/redmine_xmpp_notifications.git vendor/plugins/redmine_xmpp_notifications
bundle install
rake db:migrate_plugins RAILS_ENV=production
```

Note:

  Older `git` releases cannot checkout tag with `--branch` option, so one's need to run
  additional commands instead of `git clone --branch`:

```ShellSession
git clone https://github.com/frost-nzcr4/redmine_xmpp_notifications.git vendor/plugins/redmine_xmpp_notifications
cd vendor/plugins/redmine_xmpp_notifications
git checkout v1.1.0
cd ../../..
```

## Configuration

- Go to the Plugins section of the Administration page, and select Configure.
- On this page fill out the Jabber ID and password for user who will sends messages.
- Restart your Redmine web server (e.g. mongrel, thin, mod_rails).

## Compatibility

Plugin version and environment where it was tested and perfectly works out of the box:

- v1.1.0

  - redmine 1.4.2, ruby 1.8.7, rubygems 1.8.15, bundler 1.1.5

- v1.0.2

  - redmine 1.4.2, ruby 1.8.7, rubygems 1.8.15, bundler 1.1.5
