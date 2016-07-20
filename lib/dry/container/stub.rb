module Dry
  class Container
    module Stub
      # Overrides resolve to look into stubbed keys first
      #
      # @api public
      def resolve(key)
        _stubs.fetch(key) { super }
      end

      # Add a stub to the container
      def stub(key, value, &block)
        _stubs[key] = value

        if block
          yield
          unstub(key)
        end

        self
      end

      # Remove stubbed keys from the container
      def unstub(*keys)
        keys = _stubs.keys if keys.empty?
        keys.each { |key| _stubs.delete(key) }
      end

      # Stubs have already been enabled turning this into a noop
      def enable_stubs!
      end

      private

      # Stubs container
      def _stubs
        @_stubs ||= {}
      end
    end

    module Mixin
      # Enable stubbing functionality into the current container
      def enable_stubs!
        extend ::Dry::Container::Stub
      end
    end
  end
end
