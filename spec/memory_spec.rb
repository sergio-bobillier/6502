# frozen_string_literal: true

require_relative '../memory'

RSpec.describe Memory do
  subject(:memory) { described_class.new }

  let(:address) { rand(0..described_class::DEFAULT_TOP_ADDRESS) }
  let(:value) { rand(0..0xFF) }

  describe '#initialize' do
    context 'when no top address is specified' do
      it 'creates memory storage with expected size' do
        expect(memory.size).to eq(described_class::DEFAULT_TOP_ADDRESS + 1)
      end

      it 'creates memory with the expected address range' do
        expect(memory.address_range).to eq((0..described_class::DEFAULT_TOP_ADDRESS))
      end
    end

    context 'when a top address is specified' do
      subject(:memory) { described_class.new(top_address) }

      let(:top_address) { 0xFFF }

      it 'creates memory storage with expected size' do
        expect(memory.size).to eq(top_address + 1)
      end

      it 'creates memory with the expected address range' do
        expect(memory.address_range).to eq(0..top_address)
      end
    end
  end

  describe '#read' do
    subject(:method_call) { memory.read(address) }

    describe 'boundary addresses' do
      it 'does not raise an error when reading address 0000' do
        expect { memory.read(0x0000) }.not_to raise_error
      end

      it 'does not raise an error when reading address FFFF' do
        expect { memory.read(0xFFFF) }.not_to raise_error
      end
    end

    context 'when an out-of-bounds address is read' do
      let(:address) do
        rand(
          [
            (-described_class::DEFAULT_TOP_ADDRESS..-1),
            (described_class::DEFAULT_TOP_ADDRESS..described_class::DEFAULT_TOP_ADDRESS * 2)
          ].sample
        )
      end

      it 'raises an Errors::MemoryReadError' do
        expect { memory.read(address) }
          .to raise_error(
            Errors::MemoryReadError,
            "Memory read error when trying to read address: #{address}"
          )
      end
    end

    context 'when a valid address is read' do
      before { memory.write(address, value) }

      it 'reads the writen value successfully' do
        expect(method_call).to eq(value)
      end
    end
  end

  describe '#write' do
    subject(:method_call) { memory.write(address, value) }

    it 'writes the value to the expected address' do
      expect { method_call }
        .to change { memory.read(address) }
        .from(0).to(value)
    end
  end
end
