module Dry
  class Container
    # Mixin to expose Inversion of Control (IoC) container behaviour
    #
    # @example
    #
    #   class MyClass
    #     extend Dry::Container::Mixin
    #   end
    #
    #   MyClass.register(:item, 'item')
    #   MyClass.resolve(:item)
    #   => 'item'
    #
    #   class MyObject
    #     include Dry::Container::Mixin
    #   end
    #
    #   container = MyObject.new
    #   container.register(:item, 'item')
    #   container.resolve(:item)
    #   => 'item'
    #
    #
    # @api public
    module Mixin
      # @private
      def self.extended(base)
        attr_reader :_container

        base.class_eval do
          extend ::Dry::Configurable

          setting :registry, ::Dry::Container::Registry.new
          setting :resolver, ::Dry::Container::Resolver.new
          setting :namespace_separator, '.'

          @_container = ::ThreadSafe::Hash.new

          def self.inherited(subclass)
            subclass.instance_variable_set(:@_container, @_container)
            super
          end
        end
      end

      # @private
      def self.included(base)
        base.class_eval do
          extend ::Dry::Configurable

          setting :registry, ::Dry::Container::Registry.new
          setting :resolver, ::Dry::Container::Resolver.new
          setting :namespace_separator, '.'

          attr_reader :_container

          def initialize(*args, &block)
            @_container = ::ThreadSafe::Hash.new
            super(*args, &block)
          end

          def config
            self.class.config
          end
        end
      end

      # Register an item with the container to be resolved later
      #
      # @param [Mixed] key
      #   The key to register the container item with (used to resolve)
      # @param [Hash] options
      #   Options to pass to the registry when registering the item
      # @yield
      #   Block to register with the container
      #
      # @return [Dry::Container::Mixin] self
      #
      # @api public
      def register(key, options = {}, &block)
        config.registry.call(_container, key, block, options)
        self
      end

      # Merge in the items of the other container
      #
      # @param [Dry::Container] other
      #   The other container to merge in
      #
      # @return [Dry::Container::Mixin] self
      #
      # @api public
      def merge(other)
        _container.merge!(other._container)
        self
      end

      # Resolve an item from the container
      #
      # @param [Mixed] key
      #   The key for the item you wish to resolve
      #
      # @return [Mixed]
      #
      # @api public
      def resolve(key)
        config.resolver.call(_container, key)
      end
      alias_method :[], :resolve

      # Check whether an items is registered under the given key
      #
      # @param [Mixed] key
      #   The key you wish to check for registration with
      #
      # @return [Bool]
      #
      # @api public
      def key?(key)
        config.resolver.key?(_container, key)
      end

      # Evaluate block and register items in namespace
      #
      # @param [Mixed] namespace
      #   The namespace to register items in
      #
      # @return [Dry::Container::Mixin] self
      #
      # @api public
      def namespace(namespace, &block)
        ::Dry::Container::NamespaceDSL.new(
          self,
          namespace,
          config.namespace_separator,
          &block
        )

        self
      end

      # Import a namespace
      #
      # @param [Dry::Container::Namespace] namespace
      #   The namespace to import
      #
      # @return [Dry::Container::Mixin] self
      #
      # @api public
      def import(namespace)
        namespace(namespace.name, &namespace.block)

        self
      end
    end
  end
end
