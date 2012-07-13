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
column family
  time stamp (encoded to match cassandras DateType)
    Json encoded Hash


This can be done if using the twitter/cassandra gem like this:

``` ruby

def to_byte(time)
  time = (time.to_f*1000).to_i
  [time >> 32, time].pack('NN')  
end


client.insert(:slang, 'humans', { to_byte(Time.at(1993)) => {'man' => 'dude', 'woman' => 'dudette'}.to_json }, ttl: 36000)  

```


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

stats = ComponentStats.where(key: 'id')
stats.count

stats = ComponentStats.where(key: 'id').where(start: Time.now - 1000).where(finish: Time.now)
stats.first

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
