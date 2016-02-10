module Dry
  class Container
    module Mocking
      class Resolver < Container::Resolver
        def initialize(resolver)
          @resolver = resolver
        end

        def mocks
          @mocks ||= {}
        end

        def call(original, key)
          container = if mocks.key?(key.to_s)
                        mocks
                      else
                        original
                      end

          @resolver.call(container, key)
        end

        def key?(container, key)
          @resolver.key?(container, key)
        end

        def mock(registry, mocks, val = nil)
          mocks = { mocks => val } unless mocks.is_a?(Hash)

          mocks.each do |key, value|
            registry.call(self.mocks, key, value, {})
          end

          mocks.keys
        end

        def unmock(keys)
          keys = mocks.keys if keys.empty?

          keys.map(&:to_s).each do |key|
            mocks.delete(key)
          end
        end

        def self.wrap(resolver)
          case resolver
          when self
            resolver
          else
            new(resolver)
          end
        end
      end
    end

    module Mixin
      def mock(mocks, val = nil)
        config.resolver = Mocking::Resolver.wrap(config.resolver)
        mocked = config.resolver.mock(config.registry, mocks, val)

        if block_given?
          yield
          unmock(*mocked)
        end

        self
      end

      def unmock(*keys)
        if config.resolver.respond_to? :unmock
          config.resolver.unmock(keys)
        else
          []
        end
      end
    end
  end
end
