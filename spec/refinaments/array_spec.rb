# frozen_string_literal: true

require_relative '../../refinaments/array'

RSpec.describe Array do
  describe '#to_i' do
    context 'when the array contains something that is not an integer' do
      subject(:array) { [1, 3, '5'] }

      it 'raises a TypeError' do
        expect { array.to_i }.to raise_error(
          TypeError, 'Value out of bounds: "5"'
        )
      end
    end

    context 'with an 8 bit integer' do
      subject(:array) { [0x3f] }

      it 'returns the expected integer' do
        expect(array.to_i).to eq(0x3f)
      end
    end

    context 'with a 16 bits integer' do
      subject(:array) { [0x66, 0x19] }

      it 'returns the expected integer' do
        expect(array.to_i).to eq(6502)
      end
    end

    context 'with a 32 bit integer' do
      subject(:array) { [0x0d, 0x0c, 0x0b, 0x0a] }

      it 'returns the expected integer' do
        expect(array.to_i).to eq(0x0a0b0c0d)
      end
    end

    context 'with a value ouside of the byte range' do
      subject(:array) { [0x102, 0x25] }

      it 'raise a TypeError' do
        expect { array.to_i }.to raise_error(
          TypeError, "Value out of bounds: 258"
        )
      end
    end
  end
end
