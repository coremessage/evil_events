# frozen_string_literal: true

describe EvilEvents::Core::System::Broadcaster, :stub_event_system, :null_logger do
  describe 'instance state' do
    let(:broadcaster) { described_class.new }

    describe 'attributes' do
      describe '#event_emitter' do
        specify 'event emitter instance with initial state' do
          expect(broadcaster.event_emitter).to be_a(EvilEvents::Core::Broadcasting::Emitter)
        end
      end

      describe '#adapters_container' do
        specify 'adapters container instance with pre-registered core adapters' do
          expect(broadcaster.adapters_container).to be_a(EvilEvents::Core::Broadcasting::Adapters)

          expect(broadcaster.adapters_container[:memory_sync]).to eq(
            EvilEvents::Core::Broadcasting::Adapters::MemorySync
          )

          expect(broadcaster.adapters_container[:memory_async]).to eq(
            EvilEvents::Core::Broadcasting::Adapters::MemoryAsync
          )
        end
      end
    end

    describe 'adapters orchestration' do
      let(:broadcaster) { described_class.new }

      describe '#register_adapter' do
        it 'registers passed adapter object with passed name (name already taken => fails)' do
          rabbit_adapter = double
          resque_adapter = double

          expect { broadcaster.register_adapter(:rabbit, rabbit_adapter) }.not_to raise_error
          expect { broadcaster.register_adapter(:resque, resque_adapter) }.not_to raise_error

          expect { broadcaster.register_adapter(:rabbit, double) }.to(
            raise_error(Dry::Container::Error)
          )

          expect { broadcaster.register_adapter(:resque, double) }.to(
            raise_error(Dry::Container::Error)
          )
        end
      end

      describe '#resolve_adapter' do
        it 'returns registered adapter object by passed event name (not registered => fails)' do
          sidekiq_adapter = double
          que_adapter     = double

          broadcaster.register_adapter(:sidekiq, sidekiq_adapter)
          broadcaster.register_adapter(:que, que_adapter)

          expect(broadcaster.resolve_adapter(:que)).to eq(que_adapter)
          expect(broadcaster.resolve_adapter(:sidekiq)).to eq(sidekiq_adapter)

          expect { broadcaster.resolve_adapter(:keki_peki) }.to raise_error(Dry::Container::Error)
        end
      end
    end
  end

  describe 'interaction interface' do
    describe 'broadcasting behavior' do
      let(:broadcaster) { described_class.new }

      describe '#emit' do
        it 'delegates a broadcasting logic to the internal event emitter' do
          event = double
          expect(broadcaster.event_emitter).to receive(:emit).with(event).once
          broadcaster.emit(event)
        end
      end

      describe '#raw_emit' do
        it 'delegates a raw broadcasting logic to the internal event emitter' do
          event_type  = double
          event_attrs = { payload: {}, metadata: {} }

          expect(broadcaster.event_emitter).to(
            receive(:raw_emit).with(event_type, **event_attrs).once
          )

          broadcaster.raw_emit(event_type, **event_attrs)
        end
      end
    end

    describe 'broadcasting process' do
      include_context 'event system'

      let(:sidekiq_adapter) { build_adapter_class.new }
      let(:rabbit_adapter)  { build_adapter_class.new }
      let(:broadcaster)     { event_system.broadcaster }

      before do
        event_system.register_adapter(:sidekiq, sidekiq_adapter)
        event_system.register_adapter(:rabbit,  rabbit_adapter)
      end

      describe '#emit' do
        it 'processes event (appropriate adapter should receive corresponding event)' do
          event_class         = build_event_class('broadcaster_works') { adapter :sidekiq }
          another_event_class = build_event_class('emitter_works')     { adapter :rabbit }

          event         = event_class.new
          another_event = another_event_class.new

          expect(sidekiq_adapter).to receive(:call).with(event).once
          expect(rabbit_adapter).to  receive(:call).with(another_event).once

          broadcaster.emit(event)
          broadcaster.emit(another_event)
        end
      end

      describe '#raw_emit' do
        it 'processes event with received event attributes' \
          '(appropriate adapter should receive corresponding event)' do
          build_event_class('saved') do
            payload :a
            payload :b
            adapter :rabbit
          end

          build_event_class('stored') do
            payload :kek, EvilEvents::Types::Strict::Int.default(1)
            payload :pek, EvilEvents::Types::Strict::String
            adapter :sidekiq
          end

          expect(sidekiq_adapter).to receive(:call).with(
            have_attributes(type: 'stored', payload: match(kek: 1, pek: 'test'))
          ).once

          expect(rabbit_adapter).to receive(:call).with(
            have_attributes(type: 'saved', payload: match(a: 'kek', b: 'pek'))
          ).once

          broadcaster.raw_emit('saved', payload: { a: 'kek', b: 'pek' })
          broadcaster.raw_emit('stored', payload: { pek: 'test' })
        end
      end
    end
  end
end
