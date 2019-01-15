module Dry
  class Container
    # Base class to abstract Memoizable and Callable implementations
    #
    # @api abstract
    #
    class Item
      # @return [Mixed] the item to be solved later
      attr_reader :item

      # @return [Hash] the options to memoize, call or no.
      attr_reader :options

      # @api abstract
      def initialize(item, options = {})
        @item = item
        @options = {
          call: item.is_a?(::Proc) && item.parameters.empty?
        }.merge(options)
      end

      # @api abstract
      def call
        raise NotImplementedError
      end
    end
  end
end
