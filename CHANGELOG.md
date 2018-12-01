## v0.7.0

## Changed

* [BREAKING] Now only Ruby 2.3 and above is supported ([flash-gordon](https://github.com/flash-gordon))

## Fixed

* Symbols are now coerced to strings when resolving stubbed dependencies ([cthulhu666](https://github.com/cthulhu666))

## Added

* Namespace DSL resolves keys relative to the current namespace, see the corresponding [changes](https://github.com/dry-rb/dry-container/pull/47) ([yuszuv](https://github.com/yuszuv))
* Registered objects can be decorated with the following API ([igor-alexandrov](https://github.com/igor-alexandrov))

  ```ruby
  class CreateUser
    def call(params)
      # ...
    end
  end
  container.register('create_user') { CreateUser.new }
  container.decorate('create_user', decorator: ShinyLogger.new)

  # Now subsequent resolutions will return a wrapped object

  container.resolve('create_user')
  # => #<ShinyLogger @obj=#<CreateUser:0x...>]>
  ```
* Freezing a container now prevents further registrations ([flash-gordon](https://github.com/flash-gordon))

## Internal

* Handling container items was generalized in [#34](https://github.com/dry-rb/dry-container/pull/34) ([GabrielMalakias](https://github.com/GabrielMalakias))

[Compare v0.6.0...HEAD](https://github.com/dry-rb/dry-container/compare/v0.6.0...HEAD)

## v0.6.0

## Added

* `Dry::Container::Mixin#each` - provides a means of seeing what all is registered in the container ([jeremyf](https://github.com/jeremyf))

## Fixed

* Including mixin into a class with a custom initializer ([maltoe](https://github.com/maltoe))

[Compare v0.5.0...v0.6.0](https://github.com/dry-rb/dry-container/compare/v0.5.0...v0.6.0)

## v0.5.0

## Added

* `memoize` option to `#register` - memoizes items on first resolve ([ivoanjo](https://github.com/ivoanjo))

## Fixed

* `required_ruby_version` set to `>= 2.0.0` ([artofhuman](https://github.com/artofhuman))

[Compare v0.4.0...v0.5.0](https://github.com/dry-rb/dry-container/compare/v0.4.0...v0.5.0)
