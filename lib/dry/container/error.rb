# frozen_string_literal: true

module Dry
  class Container
    # @api public
    Error = Class.new(StandardError)

    KeyError = Class.new(::KeyError)
    DidYouMean.correct_error(KeyError, DidYouMean::KeyErrorChecker)

    deprecate_constant(:Error)
  end
end
