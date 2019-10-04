---
title: Registry &amp; Resolver
layout: gem-single
name: dry-container
---

### Register options

#### `call`

This boolean option determines whether or not the registered item should be invoked when resolved, i.e.

```ruby
container = Dry::Container.new
container.register(:key_1, call: false) { "Integer: #{rand(1000)}" }
container.register(:key_2, call: true)  { "Integer: #{rand(1000)}" }

container.resolve(:key_1) # => <Proc:0x007f98c90454c0@dry_c.rb:23>
container.resolve(:key_1) # => <Proc:0x007f98c90454c0@dry_c.rb:23>

container.resolve(:key_2) # => "Integer: 157"
container.resolve(:key_2) # => "Integer: 713"
```

#### `memoize`

This boolean option determines whether or not the registered item should be memoized on the first invocation, i.e.

```ruby
container = Dry::Container.new
container.register(:key_1, memoize: true)  { "Integer: #{rand(1000)}" }
container.register(:key_2, memoize: false) { "Integer: #{rand(1000)}" }

container.resolve(:key_1) # => "Integer: 734"
container.resolve(:key_1) # => "Integer: 734"

container.resolve(:key_2) # => "Integer: 855"
container.resolve(:key_2) # => "Integer: 282"
```

### Customization

You can configure how items are registered and resolved from the container. Currently, registry can be as simple as a proc
but custom resolver should subclass the default one or have the same public interface.

```ruby
class CustomResolver < Dry::Container::Registry
  RENAMED_KEYS = { 'old' => 'new' }

  def call(container, key)
    container.fetch(key.to_s) {
      fallback_key = RENAMED_KEYS.fetch(key.to_s) {
        raise Error, "Missing #{ key }"
      }
      container.fetch(fallback_key) {
        raise Error, "Missing #{ key } and #{ fallback_key }"
      }
    }.call
  end
end

class Container
  extend Dry::Container::Mixin

  config.registry = ->(container, key, item, options) { container[key] = item }
  config.resolver = CustomResolver
end

class ContainerObject
  include Dry::Container::Mixin

  config.registry = ->(container, key, item, options) { container[key] = item }
  config.resolver = CustomResolver
end
```

This allows you to customise the behaviour of Dry::Container, for example, the default registry (Dry::Container::Registry) will raise a Dry::Container::Error exception if you try to register under a key that is already used, you may want to just overwrite the existing value in that scenario, configuration allows you to do so.
