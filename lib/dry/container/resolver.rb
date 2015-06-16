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
        item = container.fetch(key) do
          fail Error, "Nothing registered with the key #{key.inspect}"
        end

        item.call
      end
    end
  end
end
