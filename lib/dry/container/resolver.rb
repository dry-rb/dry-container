module Dry
  class Container
    # Default resolver for resolving items from container
    #
    # @api public
    class Resolver
      # Resolve an item from the container
      #
      # @param [Concurrent::Hash] container
      #   The container
      # @param [Mixed] key
      #   The key for the item you wish to resolve
      #
      # @raise [Dry::Conainer::Error]
      #   If the given key is not registered with the container
      #
      # @return [Mixed]
      #
      # @api public
      def call(container, key)
        item = container.fetch(key.to_s) do
          raise Error, "Nothing registered with the key #{key.inspect}"
        end

        item.call
      end

      # Check whether an items is registered under the given key
      #
      # @param [Concurrent::Hash] container
      #   The container
      # @param [Mixed] key
      #   The key you wish to check for registration with
      #
      # @return [Bool]
      #
      # @api public
      def key?(container, key)
        container.key?(key.to_s)
      end

      # An array of registered names for the container
      #
      # @return [Array]
      #
      # @api public
      def keys(container)
        container.keys
      end


      # Calls block once for each key in container, passing the key as a parameter.
      #
      # If no block is given, an enumerator is returned instead.
      #
      # @return Hash
      #
      # @api public
      def each_key(container, &block)
        container.each_key(&block)
      end

      # Calls block once for each key in container, passing the key and the registered item parameters.
      #
      # If no block is given, an enumerator is returned instead.
      #
      # @return Key, Value
      #
      # @api public
      # @note In discussions with other developers, it was felt that being able to iterate over not just
      #       the registered keys, but to see what was registered would be very helpful. This is a step
      #       toward doing that.
      def each_pair(container, &block)
        container.each_pair(&block)
      end
    end
  end
end
