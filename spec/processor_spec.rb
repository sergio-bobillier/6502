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
  subject(:processor) { described_class.new }

  let(:memory) do
    instance_double(
      Memory,
      read: 0
    )
  end

  let(:decoder) do
    instance_double(Decoder)
  end

  before do
    allow(Memory).to receive(:new).and_return(memory)
    allow(Decoder).to receive(:new).and_return(decoder)
  end

  describe '#initialize' do
    subject(:method_call) { processor } # needed for the behaves_like

    context 'without a given memory' do
      it 'creates a new default memory storage' do
        expect(Memory).to receive(:new).with(no_args)
        processor
      end
    end

    context 'when a memory is given' do
      subject(:processor) { described_class.new(memory: memory) }

      it 'does not create a new memory' do
        expect(Memory).not_to receive(:new)
        processor
      end

      it 'assigns the given memory' do
        expect(processor.memory).to eq(memory)
      end
    end

    context 'without a given decoder' do
      it 'creates a new default decoder' do
        expect(Decoder).to receive(:new).with(no_args)
        processor
      end
    end

    context 'when a decoder is given' do
      subject(:processor) { described_class.new(decoder: decoder) }

      it 'does not create a new decoder' do
        expect(Decoder).not_to receive(:new)
        processor
      end

      it 'assigns the given decoder' do
        expect(processor.decoder).to eq(decoder)
      end
    end

    it_behaves_like 'Processor#reset'
  end

  describe '#reset' do
    subject(:method_call) { processor.reset }

    before { processor } # Triggers the execution of the initialize method

    it_behaves_like 'Processor#reset'
  end
end
