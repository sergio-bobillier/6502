# frozen_string_literal: true

require_relative '../processor'

RSpec.describe Processor do
  subject(:processor) { described_class.new }

  let(:memory) do
    instance_double(Memory)
  end

  let(:decoder) do
    instance_double(Decoder)
  end

  before do
    allow(Memory).to receive(:new).and_return(memory)
    allow(Decoder).to receive(:new).and_return(decoder)
  end

  describe '#initialize' do
    context 'without a given memory' do
      it 'creates a new default memory storage' do
        expect(Memory).to receive(:new)
          .with(no_args).and_return(memory)

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
        expect(Decoder).to receive(:new)
          .with(no_args).and_return(decoder)

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

    it 'initializes the accumulator' do
      expect(processor.accumulator).to eq(0)
    end

    it 'initializes the x-index register' do
      expect(processor.x_index).to eq(0)
    end

    it 'initializes the y-index register' do
      expect(processor.y_index).to eq(0)
    end
  end
end
