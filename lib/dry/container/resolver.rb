module Dry
  class Container
    # Default resolver for resolving items from container
    #
    # @api public
    class Resolver
      # Resolve an item from the container
      #
      # @param [ThreadSafe::Hash] container
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
          fail Error, "Nothing registered with the key #{key.inspect}"
        end

        item.call
      end

      # Check whether an items is registered under the given key
      #
      # @param [ThreadSafe::Hash] container
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
    end
  end
end
