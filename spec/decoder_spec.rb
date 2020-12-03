# frozen_string_literal: true

require_relative '../decoder'
require_relative '../memory'

RSpec.describe Decoder do
  subject(:decoder) { described_class.new(memory: memory) }

  let(:memory) do
    instance_double(Memory)
  end

  describe '#initialize' do
    it 'assigns the given memory' do
      expect(decoder.memory).to eq(memory)
    end
  end

  describe '#decode_at' do
    subject(:method_call) { decoder.decode_at(address) }

    let(:address) { 0x1176 }

    it 'reads one byte from the given address to get the opcode' do
      expect(memory).to receive(:read).with(address)
      method_call
    end
  end
end
