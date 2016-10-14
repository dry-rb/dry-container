[gitter]: https://gitter.im/dry-rb/chat
[gem]: https://rubygems.org/gems/dry-container
[travis]: https://travis-ci.org/dry-rb/dry-container
[code_climate]: https://codeclimate.com/github/dry-rb/dry-container
[inch]: http://inch-ci.org/github/dry-rb/dry-container

# dry-container [![Join the Gitter chat](https://badges.gitter.im/Join%20Chat.svg)][gitter]

[![Gem Version](https://img.shields.io/gem/v/dry-container.svg)][gem]
[![Build Status](https://img.shields.io/travis/dry-rb/dry-container.svg)][travis]
[![Code Climate](https://img.shields.io/codeclimate/github/dry-rb/dry-container.svg)][code_climate]
[![Test Coverage](https://img.shields.io/codeclimate/coverage/github/dry-rb/dry-container.svg)][code_climate]
[![API Documentation Coverage](http://inch-ci.org/github/dry-rb/dry-container.svg)][inch]


A simple, configurable container implemented in Ruby.

## Synopsis

### Brief Example

```ruby
container = Dry::Container.new
container.register(:parrot) { |a| puts a }

parrot = container.resolve(:parrot)
parrot.call("Hello World")
# Hello World
# => nil
```

See [Dry::AutoInject Usage](https://github.com/dry-rb/dry-auto_inject#usage) for additional details.

### Detailed Example

```ruby
User = Struct.new(:name, :email)

data_store = Concurrent::Map.new.tap do |ds|
  ds[:users] = Concurrent::Array.new
end

# Initialize container
container = Dry::Container.new

# Register an item with the container to be resolved later
container.register(:data_store, data_store)
container.register(:user_repository, -> { container.resolve(:data_store)[:users] })

# Resolve an item from the container
container.resolve(:user_repository) << User.new('Jack', 'jack@dry-container.com')
# You can also resolve with []
container[:user_repository] << User.new('Jill', 'jill@dry-container.com')
# => [
#      #<struct User name="Jack", email="jack@dry-container.com">,
#      #<struct User name="Jill", email="jill@dry-container.com">
#    ]

# If you wish to register an item that responds to call but don't want it to be
# called when resolved, you can use the options hash
container.register(:proc, -> { :result }, call: false)
container.resolve(:proc)
# => #<Proc:0x007fa75e652c98@(irb):25 (lambda)>

# You can also register using a block
container.register(:item) do
  :result
end
container.resolve(:item)
# => :result

container.register(:block, call: false) do
  :result
end
container.resolve(:block)
# => #<Proc:0x007fa75e6830f0@(irb):36>

# You can also register items under namespaces using the #namespace method
container.namespace('repositories') do
  namespace('checkout') do
    register('orders') { Concurrent::Array.new }
  end
end
container.resolve('repositories.checkout.orders')
# => []

# Or import a namespace
ns = Dry::Container::Namespace.new('repositories') do
  namespace('authentication') do
    register('users') { Concurrent::Array.new }
  end
end
container.import(ns)
container.resolve('repositories.authentication.users')
# => []

# You can also register a block that is used to initialize a dependency and
# then memoize it, allowing several dependencies to be added without
# enforcing an instantiation order
class MessagePrinter
  def initialize(container)
    @message = container.resolve(:message)
    @time = Time.now
  end

  def print
    puts "#{@message} at #{@time}"
  end
end

container.register(:message_printer, -> { MessagePrinter.new(container) }, memoize: true)
container.register(:message, 'Hello, world!')
container.resolve(:message_printer).print
# => Hello, world! at 2016-08-30 05:32:12 -0700

# Same instance is reused next time
container.resolve(:message_printer).print
# => Hello, world! at 2016-08-30 05:32:12 -0700
```

You can also get container behaviour at both the class and instance level via the mixin:

```ruby
class Container
  extend Dry::Container::Mixin
end
Container.register(:item, :my_item)
Container.resolve(:item)
# => :my_item

class ContainerObject
  include Dry::Container::Mixin
end
container = ContainerObject.new
container.register(:item, :my_item)
container.resolve(:item)
# => :my_item
```
### Using a custom registry/resolver

You can configure how items are registered and resolved from the container:

```ruby
Dry::Container.configure do |config|
  config.registry = ->(container, key, item, options) { container[key] = item }
  config.resolver = ->(container, key) { container[key] }
end

class Container
  extend Dry::Container::Mixin

  configure do |config|
    config.registry = ->(container, key, item, options) { container[key] = item }
    config.resolver = ->(container, key) { container[key] }
  end
end

class ContainerObject
  include Dry::Container::Mixin

  configure do |config|
    config.registry = ->(container, key, item, options) { container[key] = item }
    config.resolver = ->(container, key) { container[key] }
  end
end
```

This allows you to customise the behaviour of Dry::Container, for example, the default registry (Dry::Container::Registry) will raise a Dry::Container::Error exception if you try to register under a key that is already used, you may want to just overwrite the existing value in that scenario, configuration allows you to do so.

## License

See `LICENSE` file.
