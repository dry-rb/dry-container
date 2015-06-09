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
        base.instance_variable_set(:@_mutex, Mutex.new)
      end
      # @private
      def self.included(base)
        base.send(:define_method, :initialize) do |*args, &block|
          @_mutex = Mutex.new
          super(*args, &block)
        end
      end
      # Register an item with the container to be resolved later
      #
      # @param [Mixed] key
      #   The key to register the container item with (used to resolve)
      # @param [Mixed] contents
      #   The item to register with the container (if no block given)
      # @param [Hash] options
      # @option options [Symbol] :call
      #   Whether the item should be called when resolved
      # @yield
      #   If a block is given, contents will be ignored and the block
      #   will be registered instead
      #
      # @raise [Dry::Conainer::Error]
      #   If an item is already registered with the given key
      #
      # @return [Dry::Container] self
      #
      # @api public
      def register(key, contents = nil, options = {}, &block)
        if block_given?
          item = block
          options = contents if contents.is_a?(::Hash)
        else
          item = contents
        end

        if _container.key?(key)
          fail Error, "There is already an item registered with the key #{key.inspect}"
        else
          _container[key] = Item.new(item, options)
        end

        self
      end
      # Resolve an item from the container
      #
      # @param [Mixed] key
      #   The key for the item you wish to resolve
      #
      # @raise [Dry::Conainer::Error]
      #   If the given key is not registered with the container
      #
      # @return [Mixed]
      #
      # @api public
      def resolve(key)
        item = _container.fetch(key) do
          fail Error, "Nothing registered with the key #{key.inspect}"
        end

        item.call
      end
      # Resolve an item from the container
      #
      # @param [Mixed] key
      #   The key for the item you wish to resolve
      #
      # @return [Mixed]
      #
      # @api public
      def [](key)
        resolve(key)
      end

      private

      # @private
      def _container
        @_mutex.synchronize { @_container ||= ThreadSafe::Cache.new }
      end
    end
  end
end
