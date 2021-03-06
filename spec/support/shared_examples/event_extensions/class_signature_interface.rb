# frozen_string_literal: true

shared_examples 'class signature interface' do
  describe 'class signature proxy interface' do
    describe '__creation_strategy' do
      specify '.__creation_strategy accessor' do
        expect(event_class.__creation_strategy).to eq(nil)

        strategy = gen_symb
        event_class.__creation_strategy = strategy

        expect(event_class.__creation_strategy).to eq(strategy)
      end
    end

    describe '.signature' do
      it 'returns Signature-proxy instance' do
        event_class.signature.tap do |signature|
          expect(signature).to be_a(
            EvilEvents::Core::Events::EventExtensions::ClassSignature::Signature
          )

          expect(signature.event_class).to eq(event_class)
        end
      end
    end
  end
end
