RSpec.describe Dry::Container::Mixin do
  describe 'extended' do
    let(:klass) do
      Class.new { extend Dry::Container::Mixin }
    end
    let(:container) { klass }

    it_behaves_like 'a container'
  end

  describe 'included' do
    let(:klass) do
      Class.new { include Dry::Container::Mixin }
    end
    let(:container) { klass.new }
  end
end
