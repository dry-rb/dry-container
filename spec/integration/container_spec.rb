# frozen_string_literal: true

RSpec.describe Dry::Container do
  let(:klass) { Dry::Container }
  let(:container) { klass.new }

  it_behaves_like "a container"

  describe "inheritance" do
    it "sets up a container for a child class" do
      parent = Class.new { extend Dry::Container::Mixin }
      child = Class.new(parent)

      parent.register(:foo, Object.new)
      child.register(:foo, Object.new)

      expect(parent[:foo]).to_not be(child[:foo])
    end
  end
end
