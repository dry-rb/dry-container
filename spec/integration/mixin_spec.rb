RSpec.describe Dry::Container::Mixin do
  describe 'extended' do
    let(:container) do
      Class.new { extend Dry::Container::Mixin }
    end

    it_behaves_like 'a container'
  end

  describe 'included' do
    let(:container) do
      Class.new { include Dry::Container::Mixin }.new
    end

    it_behaves_like 'a container'
  end
end
