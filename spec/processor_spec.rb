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

    context 'without a given decoder' do
      it 'creates a new default decoder' do
        expect(Decoder).to receive(:new)
          .with(no_args).and_return(decoder)

        processor
      end
    end
  end
end
