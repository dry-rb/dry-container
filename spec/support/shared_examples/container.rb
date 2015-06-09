shared_examples 'a container' do
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
end
