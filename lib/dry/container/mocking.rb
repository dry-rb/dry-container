module Dry
  class Container
    module Mocking
      MOCKERS = ThreadSafe::Array.new

      def self.clear!
        MOCKERS.map(&:clear!)
      end

      class ContainerProxy
        attr_reader :mocks

        def initialize(container)
          @container = container
          @mocks = ::ThreadSafe::Hash.new
        end

        def clear!
          @mocks = ::ThreadSafe::Hash.new
        end

        def key?(key)
          @mocks.key?(key) || @container.key?(key)
        end

        def fetch(key, &block)
          @mocks.fetch(key) { @container.fetch(key, &block) }
        end
      end
    end

    module Mixin
      def mock(key, contents = nil, options = {}, &block)
        if block_given?
          item = block
          options = contents if contents.is_a?(::Hash)
        else
          item = contents
        end

        unless _container.is_a? Mocking::ContainerProxy
          @_container = Mocking::ContainerProxy.new(_container)
          Mocking::MOCKERS << @_container
        end

        config.registry.call(_container.mocks, key, item, options)

        self
      end
    end
  end
end
