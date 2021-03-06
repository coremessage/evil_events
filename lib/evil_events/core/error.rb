# frozen_string_literal: true

module EvilEvents::Core
  # @api private
  # @since 0.2.0
  Error = Class.new(StandardError)
  ArgumentError = Class.new(ArgumentError)
end
