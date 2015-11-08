module Dry
  class Container
    # Default registry for registering items with the container
    #
    # @api public
    class Registry
      # @private
      def initialize
        @_mutex = ::Mutex.new
      end

      # Register an item with the container to be resolved later
      #
      # @param [ThreadSafe::Hash] container
      #   The container
      # @param [Mixed] key
      #   The key to register the container item with (used to resolve)
      # @param [Mixed] item
      #   The item to register with the container
      # @param [Hash] options
      # @option options [Symbol] :call
      #   Whether the item should be called when resolved
      #
      # @raise [Dry::Conainer::Error]
      #   If an item is already registered with the given key
      #
      # @return [Mixed]
      #
      # @api public
      def call(container, key, item, options)
        @_mutex.synchronize do
          if container.key?(key)
            fail Error, "There is already an item registered with the key #{key.inspect}"
          else
            key = key.is_a?(::String) ? key.dup.freeze : key
            container[key] = ::Dry::Container::Item.new(item, options)
          end
        end
      end
    end
  end
end
