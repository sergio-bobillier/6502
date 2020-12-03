# frozen_string_literal: true

require_relative '../processor'

RSpec.shared_examples_for 'Processor#reset' do
  it 'initializes the accumulator' do
    method_call
    expect(processor.accumulator).to eq(0)
  end

  it 'initializes the x-index register' do
    method_call
    expect(processor.x_index).to eq(0)
  end

  it 'initializes the y-index register' do
    method_call
    expect(processor.y_index).to eq(0)
  end

  describe 'reset vector' do
    before do
      allow(memory).to receive(:read).and_return(0x11)
    end

    # rubocop:disable RSpec/MultipleExpectations (need to make sure that 16 bits are read)
    it 'reads 16 bits from memory at the reset vector position' do
      expect(memory).to receive(:read).with(described_class::RESET_VECTOR)
      expect(memory).to receive(:read).with(described_class::RESET_VECTOR + 1)
      method_call
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'assigns the read value to the program counter' do
      method_call
      expect(processor.program_counter).to eq(0x1111)
    end
  end

  it 'initializes the stack pointer' do
    method_call
    expect(processor.stack_pointer).to eq(described_class::STACK_START)
  end
end

RSpec.describe Processor do
  subject(:processor) do
    described_class.new(memory: memory, decoder: decoder)
  end

  let(:memory) do
    instance_double(
      Memory,
      read: 0
    )
  end

  let(:decoder) do
    instance_double(
      Decoder,
      decode_at: nil
    )
  end

  before do
    allow(Memory).to receive(:new).and_return(memory)
    allow(Decoder).to receive(:new).and_return(decoder)
  end

  describe '#initialize' do
    subject(:method_call) { processor } # needed for the behaves_like

    it 'assigns the given memory' do
      expect(processor.memory).to eq(memory)
    end

    it 'assigns the given decoder' do
      expect(processor.decoder).to eq(decoder)
    end

    it_behaves_like 'Processor#reset'
  end

  describe '#reset' do
    subject(:method_call) { processor.reset }

    before { processor } # Triggers the execution of the initialize method

    it_behaves_like 'Processor#reset'

    it 'does not start a clock thread' do
      expect(Thread).not_to receive(:new)
      method_call
    end
  end

  describe '#reset!' do
    subject(:method_call) do
      processor.reset!

      # Needed because RSpec Mocks do not work well in multi-threaded environments
      processor.wait
    end

    before { processor } # Triggers the execution of the initialize method

    it_behaves_like 'Processor#reset'

    it 'Starts the clock thread' do
      expect(Thread).to receive(:new).and_call_original
      method_call
    end

    describe 'run' do
      before { allow(memory).to receive(:read).and_return(0x44) }

      it 'asks the decoder to decode the first instruction' do
        # The first instruction should be in the address marked by the value
        # stored in the reset vector.
        expect(decoder).to receive(:decode_at).with(0x4444)
        method_call
      end
    end
  end
end
