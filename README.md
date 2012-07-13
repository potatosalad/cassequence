# Cassequence

This will allow you to do sequence queries in cassandra

## Installation

Add this line to your application's Gemfile:

    gem 'cassequence'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cassequence

## Usage

First things first. you need to have your data arranged in a specific way to get it to work

it has to be arranged like this:



``` ruby
require 'cassequence'

Cassequence.configure do |config|
  config.host = '127.0.0.1'
  config.port = 9160
  config.key_space = 'Stats'
end

class ComponentStats
  include Cassequence::Column

  column_family :component_stats

end

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
