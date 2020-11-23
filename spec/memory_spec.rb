# frozen_string_literal: true

require_relative '../memory'

RSpec.describe Memory do
  subject(:memory) { described_class.new }

  let(:address) { rand(0..described_class::DEFAULT_SIZE) }
  let(:value) { rand(0..0xFF) }

  describe '#initialize' do
    it 'creates memory stora with default size' do
      expect(memory.size).to eq(described_class::DEFAULT_SIZE)
    end
  end

  describe '#read' do
    subject(:method_call) { memory.read(address) }

    before { memory.write(address, value) }

    it 'reads the writen value successfully' do
      expect(method_call).to eq(value)
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
