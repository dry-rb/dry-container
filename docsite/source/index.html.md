---
title: Introduction &amp; Usage
description: Simple, thread-safe container
layout: gem-single
order: 3
type: gem
name: dry-container
sections:
  - registry-and-resolver
  - testing
---

### Introduction

`dry-container` is a simple, thread-safe container, intended to be one half of a dependency injection system, possibly in combination with [dry-auto_inject](/gems/dry-auto_inject/).

At its most basic, dependency injection is a simple technique that makes it possible to implement patterns or principles of code design that rely on object composition, such as the [SOLID principles](https://en.wikipedia.org/wiki/SOLID). By being passed its dependencies instead of instantiating them itself, your code can be written to depend on abstractions, with implementations that can vary independently, potentially at runtime or for specific use-cases, such as injecting a double instead of an expensive web service call when running tests. A container offers two main improvements to basic dependency injection: it takes the work out of manually instantiating and composing trees of dependencies, and it makes it trivial to swap out one implementation of a dependency for another.

Note that dependency *injection*, dependency *inversion*, and *inversion of control* are related, but distinct, concepts that are often confused or conflated. [**Inversion of control**](https://en.wikipedia.org/wiki/Inversion_of_control) is an architectural pattern by which a low-level *system* passes control to higher-level application code, as opposed to the classical pattern, where higher-level code calls directly into a lower-level dependency. **Dependency inversion** is a principle that encourages thoughtfully designing the interfaces that your classes depend on, instead of tightly coupling to an *external* dependency's interface. This shouldn't imply that the external dependency itself changes in any way; instead it encourages the use of bridge, facade, or adapter classes to implement the interface that you designed using the third party dependency's public interface. **Dependency injection**, finally, is the practical technique of providing an object with its dependencies, instead of hard-coding them.

`dry-container` makes it much easier than with so-called "idiomatic" Ruby to make use of any one or all three of these, as desired.

### Brief Example

```ruby
container = Dry::Container.new
container.register(:parrot) { |a| puts a }

parrot = container.resolve(:parrot)
parrot.call("Hello World")
# Hello World
# => nil
```

### Detailed Example

```ruby
User = Struct.new(:name, :email)

data_store = ThreadSafe::Cache.new.tap do |ds|
  ds[:users] = ThreadSafe::Array.new
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
    register('orders') { ThreadSafe::Array.new }
  end
end
container.resolve('repositories.checkout.orders')
# => []

# Or import a namespace
ns = Dry::Container::Namespace.new('repositories') do
  namespace('authentication') do
    register('users') { ThreadSafe::Array.new }
  end
end
container.import(ns)
container.resolve('repositories.authentication.users')
# => []

# Also, you can import namespaces in container class
Repositories = Dry::Container::Namespace.new('repositories') do
  namespace('authentication') do
    register('users') { ThreadSafe::Array.new }
  end
end

class Container
  extend Dry::Container::Mixin
  import Repositories
end

Container.resolve('repositories.authentication.users')
# => []
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
