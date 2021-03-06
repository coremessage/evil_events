# frozen_string_literal: true

class EvilEvents::Core::System
  # @api private
  # @since 0.1.0
  class Broadcaster
    # @return [EvilEvents::Core::Broadcasting::Emitter]
    #
    # @since 0.1.0
    attr_reader :event_emitter

    # @return [EvilEvents::Core::Broadcasting::Adapters]
    #
    # @since 0.1.0
    attr_reader :adapters_container

    # @since 0.1.0
    def initialize
      @event_emitter      = EvilEvents::Core::Broadcasting::Emitter.new
      @adapters_container = EvilEvents::Core::Broadcasting::Adapters.new

      @adapters_container.register_core_adapters!
    end

    # @param event [EvilEvents::Core::Events::AbstractEvent]
    # @return void
    #
    # @since 0.1.0
    def emit(event)
      event_emitter.emit(event)
    end

    # @param event_type [String]
    # @param event_attributes [Hash]
    # @return void
    #
    # @since 0.1.0
    def raw_emit(event_type, **event_attributes)
      event_emitter.raw_emit(event_type, **event_attributes)
    end

    # @param adapter_name [Symbol, String]
    # @return [EvilEvents::Core::Broadcasting::Dispatcher::Dispatchable]
    #
    # @since 0.1.0
    def resolve_adapter(adapter_name)
      adapters_container.resolve(adapter_name)
    end

    # @param adapter_name [Symbol, String]
    # @param adapter_object [Object]
    # @return void
    #
    # @since 0.1.0
    def register_adapter(adapter_name, adapter_object)
      adapters_container.register(adapter_name, adapter_object)
    end
  end
end
