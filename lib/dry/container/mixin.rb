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
        base.class_eval do
          extend ::Dry::Configurable

          setting :registry, ::Dry::Container::Registry.new
          setting :resolver, ::Dry::Container::Resolver.new
          setting :namespace_separator, '.'

          @_container = ::Concurrent::Hash.new

          def self.inherited(subclass)
            subclass.instance_variable_set(:@_container, @_container.dup)
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

          def initialize(*args, &block)
            @_container = ::Concurrent::Hash.new
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
      # @param [Mixed] contents
      #   The item to register with the container (if no block given)
      # @param [Hash] options
      #   Options to pass to the registry when registering the item
      # @yield
      #   If a block is given, contents will be ignored and the block
      #   will be registered instead
      #
      # @return [Dry::Container::Mixin] self
      #
      # @api public
      def register(key, contents = nil, options = {}, &block)
        if block_given?
          item = block
          options = contents if contents.is_a?(::Hash)
        else
          item = contents
        end

        config.registry.call(_container, key, item, options)

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

      # Resolve an item from the container
      #
      # @param [Mixed] key
      #   The key for the item you wish to resolve
      #
      # @return [Mixed]
      #
      # @api public
      # @see Dry::Container::Mixin#resolve
      def [](key)
        resolve(key)
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

      # An array of registered names for the container
      #
      # @return [Array<String>]
      #
      # @api public
      def keys
        config.resolver.keys(_container)
      end

      # Converts the container to a hash with symbolized keys
      #
      # @return [Hash<Symbol, Object>]
      #
      # @api public
      def to_h
        keys.each_with_object({}) { |e, a| a[e.to_sym] = self[e] }
      end

      # Converts the container to a hash with stringified keys
      #
      # @return [Hash<String, Object>]
      #
      # @api public
      def to_hash
        keys.each_with_object({}) { |e, a| a[e.to_s] = self[e] }
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

      # @private no, really
      def _container
        @_container
      end
    end
  end
end
