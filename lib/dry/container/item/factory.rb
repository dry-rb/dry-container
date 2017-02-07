module Dry
  class Container
    class Item

      # Factory for create an Item to register inside of container
      #
      # @api public
      class Factory

        # Creates an Item Memoizable or Callable
        # @param [Mixed] item
        # @param [Hash] options
        #
        # @raise [Dry::Container::Error]
        #
        # @return [Dry::Container::Item::Base]
        def call(item, options = {})
          return Memoizable.new(item, options) if options[:memoize]
          return Callable.new(item, options)
        end
      end
    end
  end
end
