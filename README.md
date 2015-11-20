# dry-container <a href="https://gitter.im/dryrb/chat" target="_blank">![Join the chat at https://gitter.im/dryrb/chat](https://badges.gitter.im/Join%20Chat.svg)</a>

<a href="https://rubygems.org/gems/dry-container" target="_blank">![Gem Version](https://badge.fury.io/rb/dry-container.svg)</a>
<a href="https://travis-ci.org/dryrb/dry-container" target="_blank">![Build Status](https://travis-ci.org/dryrb/dry-container.svg?branch=master)</a>
<a href="https://gemnasium.com/dryrb/dry-container" target="_blank">![Dependency Status](https://gemnasium.com/dryrb/dry-container.svg)</a>
<a href="https://codeclimate.com/github/dryrb/dry-container" target="_blank">![Code Climate](https://codeclimate.com/github/dryrb/dry-container/badges/gpa.svg)</a>
<a href="http://inch-ci.org/github/dryrb/dry-container" target="_blank">![Documentation Status](http://inch-ci.org/github/dryrb/dry-container.svg?branch=master&style=flat)</a>

A simple, configurable container implemented in Ruby

## Synopsis

```ruby
User = Struct.new(:name, :email)

data_store = ThreadSafe::Cache.new.tap do |ds|
  ds[:users] = ThreadSafe::Array.new
end

# Initialize container
container = Dry::Container.new

# Register an item with the container to be resolved later
container.register(:data_store, singleton: true) { data_store }
container.register(:user_repository, singleton: true) do
  container[:data_store][:users]
end

# Resolve an item from the container
container.resolve(:user_repository) << User.new('Jack', 'jack@dry-container.com')
# You can also resolve with []
container[:user_repository] << User.new('Jill', 'jill@dry-container.com')
# => [
#      #<struct User name="Jack", email="jack@dry-container.com">,
#      #<struct User name="Jill", email="jill@dry-container.com">
#    ]

# Without the singleton option the container will resolve a proc
container.register(:block) do
  :result
end
container.resolve(:block)
# => #<Proc:0x007fa75e6830f0@(irb):36>

# You can also register items under namespaces using the #namespace method
container.namespace('repositories') do
  namespace('checkout') do
    register('orders', singleton: true) { ThreadSafe::Array.new }
  end
end
container.resolve('repositories.checkout.orders')
# => []

# Or import a namespace
ns = Dry::Container::Namespace.new('repositories') do
  namespace('authentication') do
    register('users', singleton: true) { ThreadSafe::Array.new }
  end
end
container.import(ns)
container.resolve('repositories.authentication.users')
# => []
```

You can also get container behaviour at both the class and instance level via the mixin:

```ruby
class Container
  extend Dry::Container::Mixin
end
Container.register(:item, singleton: true) { :my_item }
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
