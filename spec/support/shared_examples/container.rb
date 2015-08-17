shared_examples 'a container' do
  describe 'configuration' do
    describe 'registry' do
      describe 'default' do
        it { expect(klass.config.registry).to be_a(Dry::Container::Registry) }
      end

      describe 'custom' do
        let(:custom_registry) { double('Registry') }
        let(:key) { :key }
        let(:item) { :item }
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

        subject! { container.register(key, item, options) }

        it do
          expect(custom_registry).to have_received(:call).with(
            container._container,
            key,
            item,
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
        let(:item) { double('Item') }
        let(:key) { :key }

        before do
          klass.configure do |config|
            config.resolver = custom_resolver
          end

          allow(custom_resolver).to receive(:call).and_return(item)
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
        it { is_expected.to eq(item) }
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

          container.namespace(namespace) do
            register('key', 'item')
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

        it { is_expected.to eq('item') }
      end
    end
  end

  context 'with default configuration' do
    describe 'registering a block' do
      context 'without options' do
        it 'registers and resolves an object' do
          container.register(:item) { 'item' }

          expect(container.resolve(:item)).to eq('item')
        end
      end

      context 'with option call: false' do
        it 'registers and resolves a proc' do
          container.register(:item, call: false) { 'item' }

          expect(container.resolve(:item).call).to eq('item')
          expect(container[:item].call).to eq('item')
        end
      end
    end

    describe 'registering a proc' do
      context 'without options' do
        it 'registers and resolves an object' do
          container.register(:item, proc { 'item' })

          expect(container.resolve(:item)).to eq('item')
          expect(container[:item]).to eq('item')
        end
      end

      context 'with option call: false' do
        it 'registers and resolves a proc' do
          container.register(:item, proc { 'item' }, call: false)

          expect(container.resolve(:item).call).to eq('item')
          expect(container[:item].call).to eq('item')
        end
      end
    end

    describe 'registering an object' do
      context 'without options' do
        it 'registers and resolves the object' do
          item = 'item'
          container.register(:item, item)

          expect(container.resolve(:item)).to be(item)
          expect(container[:item]).to be(item)
        end
      end

      context 'with option call: false' do
        it 'registers and resolves an object' do
          item = -> { 'test' }
          container.register(:item, item, call: false)

          expect(container.resolve(:item)).to eq(item)
          expect(container[:item]).to eq(item)
        end
      end
    end

    describe 'registering with the same key multiple times' do
      it do
        container.register(:item, proc { 'item' })

        expect { container.register(:item, proc { 'item' }) }.to raise_error(Dry::Container::Error)
      end
    end

    describe 'resolving with a key that has not been registered' do
      it do
        expect { container.resolve(:item) }.to raise_error(Dry::Container::Error)
      end
    end

    describe 'namespace' do
      context 'when block does not take arguments' do
        before do
          container.namespace('one') do
            register('two', 2)
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
            c.register('two', 2)
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
              register('three', 3)
            end
          end
        end

        subject! { container.resolve('one.two.three') }

        it 'registers items under the given namespaces' do
          is_expected.to eq(3)
        end
      end
    end
  end
end
