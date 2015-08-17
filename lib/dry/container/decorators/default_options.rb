module Dry
  class Container
    # Decorators
    #
    # @private
    module Decorators
      # @api private
      class DefaultOptions < ::SimpleDelegator
        attr_reader :default_options
        attr_writer :default_options

        def initialize(container, options = {})
          self.default_options = options
          super(container)
        end

        def register(key, contents = nil, options = {}, &block)
          super(key, contents, default_options.merge(options), &block)
        end
      end
    end
  end
end
