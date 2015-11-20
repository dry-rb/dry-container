shared_examples 'a container' do
  let(:item) { 'item' }
  let(:item_proc) { proc { item } }

  describe 'configuration' do
    describe 'registry' do
      describe 'default' do
        it { expect(klass.config.registry).to be_a(Dry::Container::Registry) }
      end

      describe 'custom' do
        let(:custom_registry) { double('Registry') }
        let(:key) { :key }
        let(:options) { {} }

        before do
          klass.configure do |config|
            config.registry = custom_registry
          end

          allow(custom_registry).to receive(:call)
        end

        after do
          # HACK: Have to reset the configuration so that it doesn't
          # interfere with other specs
          klass.configure do |config|
            config.registry = Dry::Container::Registry.new
          end
        end

        subject! do
          container.register(key, options, &item_proc)
        end

        it do
          expect(custom_registry).to have_received(:call).with(
            container._container,
            key,
            item_proc,
            options
          )
        end
      end
    end

    describe 'resolver' do
      describe 'default' do
        it { expect(klass.config.resolver).to be_a(Dry::Container::Resolver) }
      end

      describe 'custom' do
        let(:custom_resolver) { double('Resolver') }
        let(:key) { :key }

        before do
          klass.configure do |config|
            config.resolver = custom_resolver
          end

          allow(custom_resolver).to receive(:call).and_return(item_proc)
        end

        after do
          # HACK: Have to reset the configuration so that it doesn't
          # interfere with other specs
          klass.configure do |config|
            config.resolver = Dry::Container::Resolver.new
          end
        end

        subject! { container.resolve(key) }

        it { expect(custom_resolver).to have_received(:call).with(container._container, key) }
        it { is_expected.to eq(item_proc) }
      end
    end

    describe 'namespace_separator' do
      describe 'default' do
        it { expect(klass.config.namespace_separator).to eq('.') }
      end

      describe 'custom' do
        let(:custom_registry) { double('Registry') }
        let(:key) { 'key' }
        let(:namespace_separator) { '-' }
        let(:namespace) { 'one' }

        before do
          klass.configure do |config|
            config.namespace_separator = namespace_separator
          end

          container.namespace(namespace) do |ns|
            ns.register('key', &item_proc)
          end
        end

        after do
          # HACK: Have to reset the configuration so that it doesn't
          # interfere with other specs
          klass.configure do |config|
            config.namespace_separator = '.'
          end
        end

        subject! { container.resolve([namespace, key].join(namespace_separator)) }

        it { is_expected.to eq(item_proc) }
      end
    end
  end

  describe '#register' do
    context 'without options' do
      context 'without arguments' do
        it 'registers and resolves an object' do
          container.register(:item, &item_proc)

          expect(container.key?(:item)).to be true
          expect(container.resolve(:item)).to eq(item_proc)
        end
      end

      context 'with arguments' do
        let(:item_proc) { proc { |item| item } }

        it 'registers and resolves a proc' do
          container.register(:item, &item_proc)

          expect(container.resolve(:item).call('item')).to eq('item')
        end
      end
    end

    context 'with default options' do
      it 'registers and resolves a proc' do
        container.register(:item, &item_proc)

        expect(container.key?(:item)).to be true
        expect(container.resolve(:item)).to eq(item_proc)
        expect(container[:item]).to eq(item_proc)
      end
    end

    context 'with option singleton: false' do
      it 'registers and resolves a proc' do
        container.register(:item, singleton: false, &item_proc)

        expect(container.key?(:item)).to be true
        expect(container.resolve(:item)).to eq(item_proc)
        expect(container[:item]).to eq(item_proc)
      end
    end

    context 'with option singleton: true' do
      it 'registers, resolves and calls the proc, returning the result' do
        container.register(:item, singleton: true, &item_proc)

        expect(container.key?(:item)).to be true
        expect(container.resolve(:item)).to eq(item)
        expect(container[:item]).to eq(item)
      end
    end

    context 'registering with the same key multiple times' do
      it do
        container.register(:item, &item_proc)

        expect { container.register(:item, &item_proc) }.to raise_error(Dry::Container::Error)
      end
    end

    context 'resolving with a key that has not been registered' do
      it do
        expect(container.key?(:item)).to be false
        expect { container.resolve(:item) }.to raise_error(Dry::Container::Error)
      end
    end
  end

  describe '#merge' do
    let(:key) { :key }
    let(:other) { Dry::Container.new }

    before do
      other.register(key, singleton: true) { item }
    end

    subject! { container.merge(other) }

    it { expect(container.key?(key)).to be true }
    it { expect(container.resolve(key)).to eq(item) }
    it { expect(container[key]).to eq(item) }
  end

  describe '#freeze' do
    let(:key) { :key }

    subject! { container.freeze }

    it { expect { container.register(key, item) }.to raise_error(/^can't modify frozen/) }
  end

  describe 'namespace' do
    context 'when block does not take arguments' do
      before do
        container.namespace('one') do
          register('two', singleton: true) { 2 }
        end
      end

      subject! { container.resolve('one.two') }

      it 'registers items under the given namespace' do
        is_expected.to eq(2)
      end
    end

    context 'when block takes arguments' do
      before do
        container.namespace('one') do |c|
          c.register('two', singleton: true) { 2 }
        end
      end

      subject! { container.resolve('one.two') }

      it 'registers items under the given namespace' do
        is_expected.to eq(2)
      end
    end

    context 'with nesting' do
      before do
        container.namespace('one') do
          namespace('two') do
            register('three', singleton: true) { 3 }
          end
        end
      end

      subject! { container.resolve('one.two.three') }

      it 'registers items under the given namespaces' do
        is_expected.to eq(3)
      end
    end
  end

  describe 'import' do
    it 'allows importing of namespaces' do
      ns = Dry::Container::Namespace.new('one') do
        register('two', singleton: true) { 2 }
      end

      container.import(ns)

      expect(container.resolve('one.two')).to eq(2)
    end

    it 'allows importing of nested namespaces' do
      ns = Dry::Container::Namespace.new('two') do
        register('three', singleton: true) { 3 }
      end

      container.namespace('one') do
        import(ns)
      end

      expect(container.resolve('one.two.three')).to eq(3)
    end
  end
end
