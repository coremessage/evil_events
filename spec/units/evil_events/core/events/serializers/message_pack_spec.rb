# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers::MessagePack, :stub_event_system do
  it_behaves_like 'event serializer component' do
    let(:serializer) { EvilEvents::Core::Events::Serializers::MessagePack::Factory.new.create! }
    let(:serialization_error) { EvilEvents::MessagePackSerializationError }
    let(:deserialization_error) { EvilEvents::MessagePackDeserializationError }
    let(:serialization_type) { String }
    let(:incorrect_deserialization_objects) { gen_all(except: :gen_str) }
    let(:invalid_serializations) do
      data = serializer.serialize(event)

      [
        data.sub('type', gen_str),
        data.sub('metadata', gen_str),
        data.sub('payload', gen_str)
      ]
    end

    specify { expect(serializer).to be_a(described_class) }
  end
end