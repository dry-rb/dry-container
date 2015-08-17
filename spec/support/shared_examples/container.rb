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

      context 'with :call option set to false' do
        it 'registers and resolves an object' do
          item = -> { 'test' }
          container.register(:item, item, call: false)

          expect(container.resolve(:item)).to eq(item)
          expect(container[:item]).to eq(item)
        end
      end

      context 'with :namespace option' do
        context 'without :namespace_separator option' do
          context 'without a configured namespace_separator' do
            it 'registers and resolves an object under the given namespace with default separator' do
              item = 'item'
              container.register('item', item, namespace: 'namespace')

              expect { container.resolve('item') }.to raise_error
              expect(container.resolve('namespace.item')).to eq(item)
              expect(container['namespace.item']).to eq(item)
            end
          end

          context 'with a configured namespace_separator' do
            before do
              klass.configure do |config|
                config.namespace_separator = '-'
              end
            end

            after do
              # HACK: Have to reset the configuration so that it doesn't
              # interfere with other specs
              klass.configure do |config|
                config.namespace_separator = '.'
              end
            end

            it 'registers and resolves an object under the given namespace with configured separator' do
              item = 'item'
              container.register('item', item, namespace: 'namespace')

              expect { container.resolve('item') }.to raise_error
              expect { container.resolve('namespace.item') }.to raise_error
              expect(container.resolve('namespace-item')).to eq(item)
              expect(container['namespace-item']).to eq(item)
            end
          end
        end

        context 'with :namespace_separator option' do
          it 'registers and resolves an object under the given namespace with given separator' do
            item = 'item'
            container.register('item', item, namespace: 'namespace', namespace_separator: '_')

            expect { container.resolve('item') }.to raise_error
            expect { container.resolve('namespace.item') }.to raise_error
            expect(container.resolve('namespace_item')).to eq(item)
            expect(container['namespace_item']).to eq(item)
          end
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
  end
end
