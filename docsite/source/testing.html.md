---
title: Testing
layout: gem-single
name: dry-container
---

### Stub

To stub your containers call `#stub` method:

```ruby
container = Dry::Container.new
container.register(:redis) { "Redis instance" }

container[:redis] # => "Redis instance"

require 'dry/container/stub'

# before stub you need to enable stubs for specific container
container.enable_stubs!
container.stub(:redis, "Stubbed redis instance")

container[:redis] # => "Stubbed redis instance"
```

Also, you can unstub container:
```ruby
container = Dry::Container.new
container.register(:redis) { "Redis instance" }
container[:redis] # => "Redis instance"

require 'dry/container/stub'
container.enable_stubs!

container.stub(:redis, "Stubbed redis instance")
container[:redis] # => "Stubbed redis instance"

container.unstub(:redis) # => "Redis instance"
```

To clear all stubs at once, call `#unstub` without any arguments:

```ruby
container = Dry::Container.new
container.register(:redis) { "Redis instance" }
container.register(:db) { "DB instance" }

require 'dry/container/stub'
container.enable_stubs!
container.stub(:redis, "Stubbed redis instance")
container.stub(:db, "Stubbed DB instance")

container.unstub # This will unstub all previously stubbed keys

container[:redis] # => "Redis instance"
container[:db] # => "Redis instance"
```
