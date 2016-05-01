module Dry
  class Container
    # Container class
    #
    # @private
    class Item
      attr_reader :item, :options

      def initialize(item, options = {})
        @item = item
        @options = {
          call: item.is_a?(::Proc) && item.parameters.empty?
        }.merge(options)
      end

      def call
        if options[:call] == true
          item.call
        else
          item
        end
      end
    end
  end
end
