require 'delegate'

module Dry
  class Container
    # @api private
    class NamespaceDSL < ::SimpleDelegator
      # DSL for defining namespaces
      #
      # @param [Dry::Container::Mixin] container
      #   The container
      # @param [String] namespace
      #   The namespace (name)
      # @param [String] namespace_separator
      #   The namespace separator
      # @yield
      #   The block to evaluate to define the namespace
      #
      # @return [Mixed]
      #
      # @api private
      def initialize(container, namespace, namespace_separator, &block)
        @namespace = namespace
        @namespace_separator = namespace_separator

        super(container)

        if block.arity.zero?
          instance_eval(&block)
        else
          yield self
        end
      end

      def register(key, *args, &block)
        super(namespaced(key), *args, &block)
      end

      def namespace(namespace, &block)
        super(namespaced(namespace), &block)
      end

      def import(namespace)
        namespace(namespace.name, &namespace.block)

        self
      end

      # Overrides resolve to look into namespace keys first
      #
      # @param [Mixed] key
      #   The key for the item you wish to resolve
      # @param [Bool] namespaced
      #   Indicates whether or not the key will be namespaced, defaults to true
      #
      # @return [Mixed]
      #
      # @api public
      def resolve(key, namespaced: true)
        key = namespaced(key) if namespaced

        super(key)
      end

      private

      def namespaced(key)
        [@namespace, key].join(@namespace_separator)
      end
    end
  end
end
