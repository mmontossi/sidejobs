[![Gem Version](https://badge.fury.io/rb/sidejobs.svg)](http://badge.fury.io/rb/sidejobs)
[![Code Climate](https://codeclimate.com/github/mmontossi/sidejobs/badges/gpa.svg)](https://codeclimate.com/github/mmontossi/sidejobs)
[![Build Status](https://travis-ci.org/mmontossi/sidejobs.svg)](https://travis-ci.org/mmontossi/sidejobs)
[![Dependency Status](https://gemnasium.com/mmontossi/sidejobs.svg)](https://gemnasium.com/mmontossi/sidejobs)

# Sidejobs

Versatile async database based jobs for rails.

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
bundle exec rails g sidejobs:install
```

The default configuration options are:
```ruby
Sidejobs.configure do |config|
  config.max_attempts = 3
  config.sleep_delay = 15
  config.batch_size = 20
end
```

Run the migration to create the sidejobs table:
```
bundle exec rake db:migrate
```

Assign the sidejobs adapter to the environments:
```ruby
Rails.application.configure do
  config.active_job.queue_adapter = :sidejobs
end
```

## Usage

Start the daemon using the rake task:
```
bundle exec rake sidejobs:start
```

Now you can deliver mails using deliver_later:
```ruby
UserMailer.invite('someone@mail.com').deliver_later
```

Or perform jobs using perform_later:
```ruby
SendNewsletterJob.perform_later
```

Management is done programtically using Sidejobs::Job model:
```ruby
Sidejobs::Job.where(status: 'failing').where('attempts > ?', 3).destroy_all
```

NOTE: Is better to do it this way to have the freedom to integrate the code anyway you want.

## Credits

This gem is maintained and funded by [mmontossi](https://github.com/mmontossi).

## License

It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
