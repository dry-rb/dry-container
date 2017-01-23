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

        setup_memoization if options[:memoize] == true
      end

      def call
        return memoized_item if memoize

        if options[:call] == true
          item.call
        else
          item
        end
      end

      private

      def setup_memoization
        unless @item.is_a?(::Proc)
          raise(
            ::Dry::Container::Error,
            'Memoize only supported for a block or a proc'
          )
        end

        @memoize = true
        @memoize_mutex = ::Mutex.new
      end

      def memoized_item
        memoize_mutex.synchronize do
          @memoized_item ||= item.call
        end
      end
    end
  end
end
