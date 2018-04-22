# frozen_string_literal: true

class EvilEvents::Core::Events::Serializers
  # @api private
  # @since 0.4.0
  JSON = Class.new(Base)

  # @since 0.4.0
  register(:json, memoize: true) { JSON::Factory.new.create! }
end
