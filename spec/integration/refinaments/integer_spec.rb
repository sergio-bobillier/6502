# frozen_string_literal: true

require_relative '../../../refinaments/integer'
require_relative '../../../refinaments/array'

RSpec.describe Integer do
  describe '#to_a -> #to_i' do
    context 'with an 8-bit positive integer' do
      subject(:integer) { rand(0..255) }

      it 'returns the expected integer' do
        expect(integer.to_a.to_i).to eq(integer)
      end
    end

    context 'with an 8-bit negative integer' do
      subject(:integer) { rand(-128...0) }

      let(:expected_value) { integer + 256 }

      it "returns the Integer's two's complement" do
        expect(integer.to_a.to_i).to eq(expected_value)
      end
    end

    context 'with a 16-bit positive integer' do
      subject(:integer) { rand(256..65535) }

      it 'returns the expected integer' do
        expect(integer.to_a.to_i).to eq(integer)
      end
    end

    context 'with a 16-bit negative integer' do
      subject(:integer) { rand(-32768...0) }

      let(:expected_value) { integer + 65536 }

      it 'returns the expected integer' do
        expect(integer.to_a.to_i).to eq(expected_value)
      end
    end
  end
end
