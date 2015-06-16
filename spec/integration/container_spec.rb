RSpec.describe Dry::Container do
  let(:klass) { Dry::Container }
  let(:container) { klass.new }

  it_behaves_like 'a container'
end
