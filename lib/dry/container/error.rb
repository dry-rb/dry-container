# frozen_string_literal: true

module Dry
  class Container
    # @api public
    Error = Class.new(StandardError)

    KeyError = Class.new(::KeyError)
    if defined?(DidYouMean::KeyErrorChecker)
      DidYouMean.correct_error(KeyError, DidYouMean::KeyErrorChecker)
    end

    deprecate_constant(:Error)
  end
end
