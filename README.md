[![Gem Version](https://badge.fury.io/rb/sidejobs.svg)](http://badge.fury.io/rb/sidejobs)
[![Code Climate](https://codeclimate.com/github/mmontossi/sidejobs/badges/gpa.svg)](https://codeclimate.com/github/mmontossi/sidejobs)
[![Build Status](https://travis-ci.org/mmontossi/sidejobs.svg)](https://travis-ci.org/mmontossi/sidejobs)
[![Dependency Status](https://gemnasium.com/mmontossi/sidejobs.svg)](https://gemnasium.com/mmontossi/sidejobs)

# Sidejobs

Versatile async database based jobs for rails.

## Why

I did this gem to:

- Avoid the need to install another admin interface.
- Simplify the job api by having close integration to rails.
- Using sql instead of redis to never lose jobs.

## Install

Put this line in your Gemfile:
```ruby
gem 'sidejobs'
```

Then bundle:
```
$ bundle
```

## Configuration

Generate the sidejobs configuration and migration file:
```
$ bundle exec rails g sidejobs:install
```

Set the global settings:
```ruby
Sidejobs.configure do |config|
  config.max_attempts = 3
  config.sleep_delay = 15
  config.batch_size = 20
end
```

Run the migration to create the sidejobs table:
```
$ bundle exec rake db:migrate
```

Assign the sidejobs adapter to the environments:
```ruby
Rails.application.configure do
  config.active_job.queue_adapter = :sidejobs
end
```

## Usage

### Daemon

To control the daemon, use the rake tasks:
```
$ bundle exec rake sidejobs:start
$ bundle exec rake sidejobs:stop
$ bundle exec rake sidejobs:restart
```

### Queue

You can deliver mails using deliver_later:
```ruby
UserMailer.invite('someone@mail.com').deliver_later
```

Or perform jobs using perform_later:
```ruby
SendNewsletterJob.perform_later
```

### Management

No admin interface, all is done using Sidejobs::Job model:
```ruby
Sidejobs::Job.failing.where('attempts > ?', 3).destroy_all
```

## Contributing

Any issue, pull request, comment of any kind is more than welcome!

I will mainly ensure compatibility to last versions of Ruby, Rails and PostgreSQL. 

## Credits

This gem is maintained and funded by [mmontossi](https://github.com/mmontossi).

## License

It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
