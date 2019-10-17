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
