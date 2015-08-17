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

          setting :registry, Registry.new
          setting :resolver, Resolver.new
          setting :namespace_separator, '.'

          @_container = ThreadSafe::Cache.new
        end
      end
      # @private
      def self.included(base)
        base.class_eval do
          extend ::Dry::Configurable

          setting :registry, Registry.new
          setting :resolver, Resolver.new
          setting :namespace_separator, '.'

          attr_reader :_container

          def initialize(*args, &block)
            @_container = ThreadSafe::Cache.new
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
      # @option options [Mixed] :namespace
      #   The namespace to register the item under (prefixed on the key)
      # @option options [Mixed] :namespace_separator
      #   The separator between the namespace and the key (defaults to '.')
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

        if namespace = options.fetch(:namespace, false)
          namespace_separator = options.fetch(
            :namespace_separator,
            config.namespace_separator
          )
          key = [namespace, namespace_separator, key].join('')
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
      alias_method :[], :resolve
      # Evaluate given block with namespace option set to given namespace
      #
      # @param [Mixed] namespace
      #   The namespace to register items under inside of the given block
      # @param [Hash] options
      # @option options [Mixed] :namespace_separator
      #   The separator between the namespace and the key (defaults to '.')
      #
      # @return [Dry::Container::Mixin] self
      #
      # @api public
      def namespace(namespace, options = {}, &block)
        fail ::Dry::Container::Error, 'namespace must be given a block' unless block_given?

        container = ::Dry::Container::Decorators::DefaultOptions.new(
          self,
          options.merge(namespace: namespace)
        )

        if block.arity.zero?
          container.instance_eval(&block)
        else
          block.call(container)
        end

        self
      end
    end
  end
end
