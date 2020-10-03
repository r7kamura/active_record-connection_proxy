# ActiveRecord::ConnectionProxy

Provides proxy-based connection switching logic for ActiveRecord.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record-connection_proxy'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install active_record-connection_proxy

## Usage

To avoid overcomplication, this library only provides `ActiveRecord::ConnectionProxy` class that borrows ActiveRecord connection from another model.
So you'll need to assemble some parts yourself.

For example, if you do replication on production environment, the first step is to setup database configuration:

```yaml
# config/database.yml
development:
  url: ...

test:
  url: ...

produciton:
  url: ...

production_replica: # <- This one!
  url: ...
```

then create an empty abstract model class to borrow connection:

```ruby
# app/models/replica.rb
class Replica < ActiveRecord::Base
  self.abstract_class = true

  if ::Rails.env.production?
    establish_connection(:production_replica)
  end
end
```

then add some handy method like this:

```ruby
class ApplicationRecord < ActiveRecord::Base
  def with_replica
    ::ActiveRecord::ConnectionProxy.new(
      connection: ::Replica.connection,
      klass: self,
    )
  end
end
```

After that, you can read records from `production_replica` connection on production env like this:

```ruby
User.with_replica.where(status: :active).order(created_at: :desc).first
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/r7kamura/active_record-connection_proxy.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
