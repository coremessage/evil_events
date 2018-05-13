# frozen_string_literal: true

describe EvilEvents::Core::Events::Serializers::JSON, :stub_event_system do
  include_context 'event system'

  shared_examples 'serialization behaviour' do
    it_behaves_like 'event serializer component' do
      let(:serializer) { EvilEvents::Core::Events::Serializers::JSON::Factory.new.create! }
      let(:serialization_error) { EvilEvents::JSONSerializationError }
      let(:deserialization_error) { EvilEvents::JSONDeserializationError }
      let(:serialization_type) { String }
      let(:incorrect_deserialization_objects) { gen_all }
      let(:invalid_serializations) do
        data = serializer.serialize(event)

        [
          data.sub('type":', "\"#{gen_str}\":"),
          data.sub('payload":', "\"#{gen_str}\":"),
          data.sub('metadata":', "\"#{gen_str}\":")
        ]
      end

      specify { expect(serializer).to be_a(described_class) }
    end
  end

  context 'native engine' do
    before { system_config.serializers.json.engine = :native }
    it_behaves_like 'serialization behaviour'
  end

  context 'oj engine' do
    before { system_config.serializers.json.engine = :oj }
    it_behaves_like 'serialization behaviour'
  end
end
