module Dry
  class Container
    # Container class
    #
    # @private
    class Item
      attr_reader :item, :options, :memoize, :memoize_mutex

      def initialize(item, options = {})
        @item = item
        @options = {
          call: item.is_a?(::Proc) && item.parameters.empty?
        }.merge(options)
        @memoize = item.is_a?(::Proc) && options[:memoize] == true
        @memoize_mutex = Mutex.new if memoize
      end

      def call
        return memoized_item if memoize

        if options[:call] == true
          item.call
        else
          item
        end
      end

      def memoized_item
        memoize_mutex.synchronize do
          @memoized_item ||= item.call
        end
      end
    end
  end
end
