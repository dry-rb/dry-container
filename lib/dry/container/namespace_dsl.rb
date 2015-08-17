module Dry
  class Container
    # @api private
    class NamespaceDSL < ::SimpleDelegator
      def initialize(container, namespace, namespace_separator, &block)
        @namespace = namespace
        @namespace_separator = namespace_separator

        super(container)

        if block.arity.zero?
          instance_eval(&block)
        else
          block.call(self)
        end
      end

      def register(key, *args, &block)
        super(namespaced(key), *args, &block)
      end

      def namespace(namespace, &block)
        super(namespaced(namespace), &block)
      end

      private

      def namespaced(key)
        [@namespace, key].join(@namespace_separator)
      end
    end
  end
end
