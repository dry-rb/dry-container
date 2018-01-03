module Dry
  class Container
    PREFIX_NAMESPACE = lambda do |namespace, key, namespace_separator|
      [namespace, key].join(namespace_separator)
    end
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
        hooks_mod = ::Module.new do
          def inherited(subclass)
            subclass.instance_variable_set(:@_container, @_container.dup)
            super
          end
        end

        base.class_eval do
          extend ::Dry::Core::ClassAttributes
          extend hooks_mod

          defines :registry
          defines :resolver
          defines :namespace_separator

          registry ::Dry::Container::Registry.new
          resolver ::Dry::Container::Resolver.new
          namespace_separator '.'

          @_container = ::Concurrent::Hash.new
        end
      end

      # @private
      module Initializer
        def initialize(*args, &block)
          @_container = ::Concurrent::Hash.new
          super
        end
      end

      # @private
      def self.included(base)
        base.class_eval do
          extend ::Dry::Core::ClassAttributes
          prepend Initializer

          defines :registry
          defines :resolver
          defines :namespace_separator

          registry ::Dry::Container::Registry.new
          resolver ::Dry::Container::Resolver.new
          namespace_separator '.'

          def registry
            self.class.registry
          end

          def resolver
            self.class.resolver
          end

          def namespace_separator
            self.class.namespace_separator
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

        registry.call(_container, key, item, options)

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
        resolver.call(_container, key)
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
      # @param [Hash] options
      # @option options [Symbol] :namespace
      #   Namespace to prefix other container items with, defaults to nil
      #
      # @return [Dry::Container::Mixin] self
      #
      # @api public
      def merge(other, namespace: nil)
        if namespace
          _container.merge!(
            other._container.each_with_object(::Concurrent::Hash.new) do |a, h|
              h[PREFIX_NAMESPACE.call(namespace, a.first, namespace_separator)] = a.last
            end
          )
        else
          _container.merge!(other._container)
        end

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
        resolver.key?(_container, key)
      end

      # An array of registered names for the container
      #
      # @return [Array<String>]
      #
      # @api public
      def keys
        resolver.keys(_container)
      end

      # Calls block once for each key in container, passing the key as a parameter.
      #
      # If no block is given, an enumerator is returned instead.
      #
      # @return [Dry::Container::Mixin] self
      #
      # @api public
      def each_key(&block)
        resolver.each_key(_container, &block)
        self
      end

      # Calls block once for each key/value pair in the container, passing the key and the registered item parameters.
      #
      # If no block is given, an enumerator is returned instead.
      #
      # @return [Enumerator]
      #
      # @api public
      #
      # @note In discussions with other developers, it was felt that being able to iterate over not just
      #       the registered keys, but to see what was registered would be very helpful. This is a step
      #       toward doing that.
      def each(&block)
        resolver.each(_container, &block)
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
          namespace_separator,
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
