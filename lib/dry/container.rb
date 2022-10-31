# frozen_string_literal: true

require "dry/container/error"
require "dry/container/namespace"
require "dry/container/registry"
require "dry/container/resolver"
require "dry/container/namespace_dsl"
require "dry/container/mixin"
require "dry/container/version"

begin
  require "dry/core"

  if defined?(Dry::Core::Container)
    warn "dry-container is deprecated and is now provided by dry-core as Dry::Core::Container"
  else
    warn "dry-container is deprecated, please upgrade to the latest dry-core as it now ships with Dry::Core::Container built-in"
  end
rescue NameError
end

# A collection of micro-libraries, each intended to encapsulate
# a common task in Ruby
module Dry
  # Inversion of Control (IoC) container
  #
  # @example
  #
  #   container = Dry::Container.new
  #   container.register(:item, 'item')
  #   container.resolve(:item)
  #   => 'item'
  #
  #   container.register(:item1, -> { 'item' })
  #   container.resolve(:item1)
  #   => 'item'
  #
  #   container.register(:item2, -> { 'item' }, call: false)
  #   container.resolve(:item2)
  #   => #<Proc:0x007f33b169e998@(irb):10 (lambda)>
  #
  # @api public
  class Container
    include ::Dry::Container::Mixin
  end
end
