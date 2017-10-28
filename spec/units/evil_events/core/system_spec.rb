# frozen_string_literal: true

describe EvilEvents::Core::System, :stub_event_system do
  let(:event_system) { described_class.new }

  describe 'instance' do
    it 'has appropriate instances of corresponding logical modules' do
      expect(event_system.broadcaster).to be_a(EvilEvents::Core::System::Broadcaster)
      expect(event_system.event_manager).to be_a(EvilEvents::Core::System::EventManager)
    end
  end

  describe 'public interface' do
    it 'delegates the received method to the appropriate module' do
      broadcaster_module   = event_system.broadcaster
      event_manager_module = event_system.event_manager
      event_builder_module = EvilEvents::Core::System::EventBuilder

      %i[emit raw_emit resolve_adapter].each do |method_name|
        expect(broadcaster_module).to receive(method_name)
        event_system.public_send(method_name)
      end

      %i[
        observe raw_observe observers register_event_class
        unregister_event_class manager_of_event manager_of_event_type
        resolve_event_object managed_event?
      ].each do |method_name|
        expect(event_manager_module).to receive(method_name)
        event_system.public_send(method_name)
      end

      %i[define_event_class define_abstract_event_class].each do |method_name|
        expect(event_builder_module).to receive(method_name)
        event_system.public_send(method_name)
      end
    end
  end
end
