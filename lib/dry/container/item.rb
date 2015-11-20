module Dry
  class Container
    # Container Item
    #
    # @private
    class Item
      attr_reader :item, :options

      def initialize(item, options = {})
        self.item = item
        self.options = options
        self.resolved = false
        self.mutex = Mutex.new
      end

      def call
        if options.fetch(:singleton, false)
          mutex.synchronize do
            return item if resolved?
            self.resolved = true
            self.item = item.call
          end
        else
          item
        end
      end

      private

      attr_accessor :resolved, :mutex
      alias_method :resolved?, :resolved
      attr_writer :item, :options, :mutex
    end
  end
end
